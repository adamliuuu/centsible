class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    private var updateTimer: Timer?
    
    // Keep these for other functionality
    @Published var likedItems: Set<UUID> = []
    @Published var selectedFriends: [UUID: Set<String>] = [:]
    @Published var showingFriendSelector = false
    @Published var currentPostId: UUID?
    @Published var reactions: [UUID: [String: Set<String>]] = [:]
    @Published var friendRequests: [UUID: Set<String>] = [:]
    @Published var tripResponses: [UUID: TripResponse] = [:]
    @Published var canceledTrips: Set<UUID> = []
    
    init() {
        // Remove all hardcoded feed items
        // Just fetch from JSON immediately
        fetchFeedItems()
        
        // Set up timer to check for updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchFeedItems()
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // Add a struct to decode the JSON
    struct PurchaseData: Codable {
        let status: String
        let data: [Purchase]
    }
    
    struct Purchase: Codable, Identifiable {
        let id: String
        let product_name: String
        let merchant: String
        let price: Double
        let purchase_time: String
        let payment_method: String
        let user: String
    }
    
    // Add debug print to verify JSON loading
    func fetchFeedItems() {
        if let url = Bundle.main.url(forResource: "purchases", withExtension: "json") {
            print("Loading JSON from: \(url.path)")
        } else {
            print("ERROR: purchases.json not found in bundle")
            return
        }
        
        guard let url = Bundle.main.url(forResource: "purchases", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load purchases.json"])
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let purchaseData = try decoder.decode(PurchaseData.self, from: data)
            print("Successfully loaded \(purchaseData.data.count) purchases")
            
            DispatchQueue.main.async {
                self.feedItems = purchaseData.data.map { purchase in
                    let timestamp = ISO8601DateFormatter().date(from: purchase.purchase_time) ?? Date()
                    let (title, description) = self.createFeedContent(for: purchase)
                    
                    return FeedItem(
                        id: UUID(uuidString: purchase.id) ?? UUID(),
                        title: title,
                        description: description,
                        timestamp: timestamp,
                        type: .purchase,
                        comments: Int.random(in: 1...10),
                        userImage: self.getUserImage(for: purchase.user),
                        userName: purchase.user,
                        isYourPost: false
                    )
                }
                .sorted { $0.timestamp > $1.timestamp }
            }
        } catch {
            print("ERROR decoding JSON: \(error)")
            self.error = error
        }
    }
    
    private func createFeedContent(for purchase: Purchase) -> (title: String, description: String) {
        switch purchase.user {
        case "Nicole Deng":
            return ("Hackathon Prep? 🏃‍♀️",
                   "\(purchase.user) just loaded up on \(purchase.product_name). It's not like she's going to win HackPrinceton anyways.")
        case "Ziya Momin":
            return ("Impatient Much? 🎵",
                   "\(purchase.user) just paid for expedited shipping on \(purchase.product_name)?? Patience is NOT her strong suit.")
        case "Brooke Xu":
            return ("TikTok Made Me Buy It ✏️",
                   "\(purchase.user) just bought a \(purchase.product_name) off a TikTok shop. Is she going to use that to write more checks she can't cash?")
        case "Adam Liu":
            return ("Gamer Moment 🎮",
                   "WOW \(purchase.user) just bought \(purchase.product_name). Someone needs to touch some grass…")
        case "Joe Fisherman":
            return ("Health Check 🏥",
                   "\(purchase.user) just went to \(purchase.product_name). Wonder if it's scoliosis or for carrying all of his emotional baggage?")
        case "Bennett Zeus":
            return ("Kung Fu Fighting 🥟",
                   "\(purchase.user) just paid for \(purchase.product_name). He's training to be the next Dragon Warrior.")
        default:
            return ("New Purchase 🛍️",
                   "\(purchase.user) just bought \(purchase.product_name) for $\(String(format: "%.2f", purchase.price))")
        }
    }
    
    private func getUserImage(for userName: String) -> String {
        switch userName {
        case "Nicole Deng":
            return "characternicole"
        default:
            return "��"
        }
    }
} 