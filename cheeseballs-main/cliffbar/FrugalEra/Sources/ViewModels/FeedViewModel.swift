import Foundation
import SwiftUI

// Updated feed messages with friend content
class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var likedItems: Set<UUID> = []
    @Published var selectedFriends: [UUID: Set<String>] = [:] // Maps post ID to set of friend names
    @Published var showingFriendSelector = false
    @Published var currentPostId: UUID?
    @Published var reactions: [UUID: [String: Set<String>]] = [:] // Maps post ID to emoji -> set of usernames
    @Published var friendRequests: [UUID: Set<String>] = [:] // Maps post ID to set of usernames who requested to be added
    @Published var tripResponses: [UUID: TripResponse] = [:] // Track trip responses
    @Published var canceledTrips: Set<UUID> = [] // Track canceled trips
    private var updateTimer: Timer?
    
    enum TripResponse {
        case accepted
        case declined
    }
    
    // Sample friends list
    let availableFriends = [
        "Brooke Xu",
        "Nicole Deng",
        "Ziya Momin",
        "Adam Liu",
        "Joe Fisherman",
        "Bennett Zeus"
    ]
    
    init() {
        fetchFeedItems()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchFeedItems()
        }
    }
    
    func toggleFriendSelection(for postId: UUID, friendName: String) {
        if selectedFriends[postId] == nil {
            selectedFriends[postId] = []
        }
        
        if selectedFriends[postId]?.contains(friendName) == true {
            selectedFriends[postId]?.remove(friendName)
        } else {
            selectedFriends[postId]?.insert(friendName)
        }
    }
    
    func isFriendSelected(for postId: UUID, friendName: String) -> Bool {
        selectedFriends[postId]?.contains(friendName) ?? false
    }
    
    func getSelectedFriends(for postId: UUID) -> [String] {
        Array(selectedFriends[postId] ?? [])
    }
    
    func hasAddedFriends(for postId: UUID) -> Bool {
        !(selectedFriends[postId]?.isEmpty ?? true)
    }
    
    func toggleFriendRequest(for postId: UUID) {
        if friendRequests[postId] == nil {
            friendRequests[postId] = []
        }
        
        if friendRequests[postId]?.contains("You") == true {
            friendRequests[postId]?.remove("You")
        } else {
            friendRequests[postId]?.insert("You")
        }
    }
    
    func hasRequestedToBeAdded(for postId: UUID) -> Bool {
        friendRequests[postId]?.contains("You") ?? false
    }
    
    func toggleReaction(_ emoji: String, by username: String, to postId: UUID) {
        if reactions[postId] == nil {
            reactions[postId] = [:]
        }
        if reactions[postId]?[emoji] == nil {
            reactions[postId]?[emoji] = []
        }
        
        if reactions[postId]?[emoji]?.contains(username) == true {
            reactions[postId]?[emoji]?.remove(username)
        } else {
            reactions[postId]?[emoji]?.insert(username)
        }
        
        if reactions[postId]?[emoji]?.isEmpty == true {
            reactions[postId]?.removeValue(forKey: emoji)
        }
    }
    
    func getReactions(for postId: UUID) -> [(emoji: String, count: Int)] {
        guard let postReactions = reactions[postId] else { return [] }
        return postReactions.map { (emoji: $0.key, count: $0.value.count) }
    }
    
    func fetchFeedItems() {
        isLoading = true
        
        guard let url = Bundle.main.url(forResource: "purchases", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load purchases.json"])
            self.isLoading = false
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let purchaseData = try decoder.decode(PurchaseData.self, from: data)
            
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
                
                self.isLoading = false
            }
        } catch {
            print("Error decoding JSON: \(error)")
            self.error = error
            self.isLoading = false
        }
    }
    
    private func createFeedContent(for purchase: Purchase) -> (title: String, description: String) {
        switch purchase.user {
        case "Nicole Deng":
            return ("Hackathon Prep? 🏃‍♀️",
                   "\(purchase.user) just loaded up on \(purchase.product_name). It's not like she's going to win HackPrinceton anyways.")
        case "Ziya Momin":
            return ("Impatient Much? 🎵",
                   "\(purchase.user) just paid for \(purchase.product_name)?? Patience is NOT her strong suit.")
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
        case "Sarah Chen":
            return ("Best Purchase",
                   "Just got \(purchase.product_name) for $\(String(format: "%.2f", purchase.price))! They're absolutely worth every penny - the noise cancellation is incredible and the sound quality is amazing. Perfect for my daily commute and workouts. Best tech purchase I've made this year! 🎧")
        default:
            return ("New Purchase 🛍️",
                   "\(purchase.user) just bought \(purchase.product_name) for $\(String(format: "%.2f", purchase.price))")
        }
    }
    
    private func getUserImage(for username: String) -> String {
        // Implement the logic to return the appropriate user image based on the username
        // This is a placeholder and should be replaced with the actual implementation
        return "👤"
    }
    
    func toggleLike(for itemId: UUID) {
        if likedItems.contains(itemId) {
            likedItems.remove(itemId)
        } else {
            likedItems.insert(itemId)
        }
    }
    
    func isLiked(itemId: UUID) -> Bool {
        likedItems.contains(itemId)
    }
    
    func respondToTrip(_ postId: UUID, accept: Bool) {
        tripResponses[postId] = accept ? .accepted : .declined
    }
    
    func cancelTrip(_ postId: UUID) {
        canceledTrips.insert(postId)
    }
    
    func isTripCanceled(_ postId: UUID) -> Bool {
        canceledTrips.contains(postId)
    }
    
    func getTripResponse(_ postId: UUID) -> TripResponse? {
        tripResponses[postId]
    }
}

struct TripDetails {
    let destination: String
    let date: Date
    let confirmedFriends: [String]
    let pendingFriends: [String]
    let isScheduled: Bool
}

struct FeedItem: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let timestamp: Date
    let type: FeedItemType
    let comments: Int
    let userImage: String
    let userName: String
    let isYourPost: Bool
    var selectedFriends: [String] = []
    var hasImage: Bool = false
    var tripDetails: TripDetails?
}

enum FeedItemType {
    case spending
    case purchase
    case health
    case achievement
    case social
    case recommendation
}

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