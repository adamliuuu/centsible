import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "8A2BE2").opacity(0.05), // Very subtle purple
                    Color(hex: "8A2BE2").opacity(0.02), // Even more subtle purple
                    Color(.systemGray6) // System gray
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // TabView with transparent background
            TabView(selection: $selectedTab) {
                FeedView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Feed")
                    }
                    .tag(0)
                
                LeaderboardView()
                    .tabItem {
                        Image(systemName: "trophy.fill")
                        Text("Leaderboard")
                    }
                    .tag(1)
                
                FriendsView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("Friends")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .tint(Color(hex: "8A2BE2")) // Purple tint for tab bar
            .background(Color.clear) // Make TabView background transparent
        }
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @State private var selectedCategory = 0
    private let categories = ["Least Money Spent", "Most Trips with Friends", "Most Money Saved"]
    private let categoryIndices = [0, 1, 2]
    
    // Sample data for different leaderboards
    private let leastMoneySpent = [
        LeaderboardEntry(name: "Joe Fisherman", value: "$82.50", rank: 1),
        LeaderboardEntry(name: "Adam Liu", value: "$156.75", rank: 2),
        LeaderboardEntry(name: "Nicole Deng", value: "$234.90", rank: 3),
        LeaderboardEntry(name: "Brooke Xu", value: "$345.60", rank: 4),
        LeaderboardEntry(name: "Ziya Momin", value: "$456.30", rank: 5),
        LeaderboardEntry(name: "Bennett Zeus", value: "$789.45", rank: 6)
    ]
    
    private let mostTripsWithFriends = [
        LeaderboardEntry(name: "Brooke Xu", value: "8 trips", rank: 1),
        LeaderboardEntry(name: "Nicole Deng", value: "7 trips", rank: 2),
        LeaderboardEntry(name: "Adam Liu", value: "6 trips", rank: 3),
        LeaderboardEntry(name: "Joe Fisherman", value: "5 trips", rank: 4),
        LeaderboardEntry(name: "Ziya Momin", value: "4 trips", rank: 5),
        LeaderboardEntry(name: "Bennett Zeus", value: "3 trips", rank: 6)
    ]
    
    private let mostMoneySaved = [
        LeaderboardEntry(name: "Adam Liu", value: "$142.30", rank: 1),
        LeaderboardEntry(name: "Nicole Deng", value: "$128.75", rank: 2),
        LeaderboardEntry(name: "Brooke Xu", value: "$115.60", rank: 3),
        LeaderboardEntry(name: "Ziya Momin", value: "$98.45", rank: 4),
        LeaderboardEntry(name: "Bennett Zeus", value: "$85.20", rank: 5),
        LeaderboardEntry(name: "Joe Fisherman", value: "$45.30", rank: 6)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Highlights
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Weekly Highlights")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            HighlightCard(
                                title: "Most Frugal",
                                value: "Joe Fisherman",
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            HighlightCard(
                                title: "Most Money Saved",
                                value: "Adam Liu",
                                icon: "dollarsign.circle.fill",
                                color: .blue
                            )
                            
                            HighlightCard(
                                title: "Weirdest Purchase",
                                value: "Brooke Xu",
                                icon: "star.fill",
                                color: .yellow
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(categoryIndices, id: \.self) { index in
                                CategoryButton(
                                    title: categories[index],
                                    isSelected: selectedCategory == index,
                                    icon: getIcon(for: index),
                                    color: getColor(for: index)
                                ) {
                                    withAnimation {
                                        selectedCategory = index
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Selected Leaderboard
                    LeaderboardSection(
                        title: categories[selectedCategory],
                        entries: getEntries(for: selectedCategory),
                        icon: getIcon(for: selectedCategory),
                        color: getColor(for: selectedCategory)
                    )
                }
                .padding()
            }
            .navigationTitle("Leaderboard")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "dollarsign.circle.fill"
        case 1: return "person.2.fill"
        case 2: return "star.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    private func getColor(for index: Int) -> Color {
        switch index {
        case 0: return .green
        case 1: return .blue
        case 2: return .yellow
        default: return .green
        }
    }
    
    private func getEntries(for index: Int) -> [LeaderboardEntry] {
        switch index {
        case 0: return leastMoneySpent
        case 1: return mostTripsWithFriends
        case 2: return mostMoneySaved
        default: return leastMoneySpent
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? color : color.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let value: String
    let rank: Int
}

struct LeaderboardSection: View {
    let title: String
    let entries: [LeaderboardEntry]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            ForEach(entries) { entry in
                HStack {
                    Text("#\(entry.rank)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 40)
                    
                    Text(entry.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(entry.value)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct HighlightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

// MARK: - Friends View
struct FriendsView: View {
    @State private var selectedFriend: String?
    @State private var showingFriendProfile = false
    
    // Sample friends list
    private let friends = [
        "Brooke Xu",
        "Nicole Deng",
        "Ziya Momin",
        "Adam Liu",
        "Joe Fisherman",
        "Bennett Zeus"
    ]
    
    // Sample suggested friends
    private let suggestedFriends = [
        "Sarah Chen",
        "Michael Rodriguez",
        "Emma Thompson",
        "David Kim",
        "Sophia Patel"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Friend Suggestions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Suggested Friends")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(suggestedFriends, id: \.self) { friend in
                                    VStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Text("👤")
                                                    .font(.system(size: 30))
                                            )
                                        
                                        Text(friend)
                                            .font(.subheadline)
                                        
                                        Button(action: {}) {
                                            Text("Connect")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 8)
                                                .background(Color.purple)
                                                .cornerRadius(15)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Current Friends
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Friends")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(friends, id: \.self) { friend in
                            Button(action: {
                                selectedFriend = friend
                                showingFriendProfile = true
                            }) {
                                HStack {
                                    Image(getUserImage(for: friend))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(friend)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("Last active 2h ago")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Text("Message")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.purple)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 6)
                                            .background(Color.purple.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(15)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Friends")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingFriendProfile) {
                if let friend = selectedFriend {
                    FriendProfileView(friendName: friend)
                }
            }
        }
    }
    
    private func getUserImage(for userName: String) -> String {
        switch userName.lowercased() {
        case "brooke xu":
            return "characterbrooke"
        case "adam liu":
            return "characteradam"
        case "nicole deng":
            return "characternicole"
        case "joe fisherman":
            return "characterjoe"
        default:
            return "characterbrooke" // Default fallback image
        }
    }
}

// MARK: - Friend Profile View
struct FriendProfileView: View {
    let friendName: String
    @State private var showingTransactionHistory = false
    @State private var debtAmount = Double.random(in: -50...50)
    
    // Sample shared transactions
    private let sharedTransactions = [
        SharedTransaction(description: "Target Shopping Spree", amount: 85.50, date: Date().addingTimeInterval(-86400), splitWith: "You"),
        SharedTransaction(description: "Dinner at Chipotle", amount: 32.75, date: Date().addingTimeInterval(-172800), splitWith: "You"),
        SharedTransaction(description: "Movie Night", amount: 24.99, date: Date().addingTimeInterval(-259200), splitWith: "You"),
        SharedTransaction(description: "Grocery Run", amount: 127.80, date: Date().addingTimeInterval(-432000), splitWith: "You"),
        SharedTransaction(description: "Coffee Run", amount: 15.45, date: Date().addingTimeInterval(-518400), splitWith: "You")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 15) {
                    // Profile Image
                    Image(getUserImage(for: friendName))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 5)
                    
                    Text(friendName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(friendName.lowercased().replacingOccurrences(of: " ", with: ""))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Debt Amount
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("You \(debtAmount >= 0 ? "owe" : "are owed")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(abs(debtAmount), specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(debtAmount >= 0 ? .red : .green)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingTransactionHistory = true
                    }) {
                        Text("Shared History")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Stats
                HStack(spacing: 20) {
                    StatCard(title: "Saved", value: "$1,234", icon: "dollarsign.circle.fill", color: .green)
                    StatCard(title: "Friends", value: "42", icon: "person.2.fill", color: .blue)
                    StatCard(title: "Achievements", value: "12", icon: "trophy.fill", color: .yellow)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(1...5, id: \.self) { _ in
                        HStack {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.purple)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Spent $24.99 at Target")
                                    .font(.subheadline)
                                Text("2 hours ago")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingTransactionHistory) {
            TransactionHistoryView(transactions: sharedTransactions, friendName: friendName)
        }
    }
    
    private func getUserImage(for userName: String) -> String {
        switch userName.lowercased() {
        case "brooke xu":
            return "characterbrooke"
        case "adam liu":
            return "characteradam"
        case "nicole deng":
            return "characternicole"
        case "joe fisherman":
            return "characterjoe"
        default:
            return "characterbrooke" // Default fallback image
        }
    }
}

// MARK: - Supporting Views
struct SharedTransaction: Identifiable {
    let id = UUID()
    let description: String
    let amount: Double
    let date: Date
    let splitWith: String
}

struct TransactionHistoryView: View {
    let transactions: [SharedTransaction]
    let friendName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(transactions) { transaction in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(transaction.description)
                                .font(.headline)
                            Spacer()
                            Text("$\(transaction.amount, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Split with \(transaction.splitWith)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(transaction.date, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Shared with \(friendName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("👤")
                                    .font(.system(size: 50))
                            )
                        
                        Text("Your Name")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("@username")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatCard(title: "Saved", value: "$1,234", icon: "dollarsign.circle.fill", color: .green)
                        StatCard(title: "Friends", value: "42", icon: "person.2.fill", color: .blue)
                        StatCard(title: "Achievements", value: "12", icon: "trophy.fill", color: .yellow)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(1...5, id: \.self) { _ in
                            HStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "cart.fill")
                                            .foregroundColor(.purple)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text("Bought something")
                                        .font(.headline)
                                    Text("2 hours ago")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("$25.99")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
}

struct MerchantConnection: Identifiable {
    let id: String
    let name: String
    let icon: String
    var isEnabled: Bool
    var status: ConnectionStatus = .disconnected
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case error
    }
}

struct SettingsView: View {
    @State private var merchantConnections: [MerchantConnection] = [
        MerchantConnection(id: "amazon", name: "Amazon", icon: "cart.fill", isEnabled: false),
        MerchantConnection(id: "walmart", name: "Walmart", icon: "basket.fill", isEnabled: false),
        MerchantConnection(id: "uber", name: "Uber", icon: "car.fill", isEnabled: false),
        MerchantConnection(id: "grubhub", name: "Grubhub", icon: "takeoutbag.and.cup.and.straw.fill", isEnabled: false),
        MerchantConnection(id: "american-airlines", name: "American Airlines", icon: "airplane", isEnabled: false)
    ]
    @State private var showingAuthSheet = false
    @State private var selectedMerchant: MerchantConnection?
    
    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("Connected Merchants"),
                    footer: Text("Connect your merchant accounts to share and track your purchases.")
                ) {
                    ForEach($merchantConnections) { $merchant in
                        Button(action: {
                            selectedMerchant = merchant
                            showingAuthSheet = true
                        }) {
                            HStack {
                                // Merchant Icon
                                Circle()
                                    .fill(merchant.isEnabled ? Color.purple.opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: merchant.icon)
                                            .foregroundColor(merchant.isEnabled ? .purple : .gray)
                                    )
                                
                                // Merchant Name and Status
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(merchant.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(merchant.status == .connected ? "Connected" : "Not connected")
                                        .font(.caption)
                                        .foregroundColor(statusColor(for: merchant))
                                }
                                
                                Spacer()
                                
                                // Simple Connect/Connected indicator
                                Text(merchant.status == .connected ? "Connected" : "Connect")
                                    .font(.callout)
                                    .foregroundColor(merchant.status == .connected ? .green : .purple)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Edit Profile")) {
                        Label("Edit Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    NavigationLink(destination: Text("Privacy")) {
                        Label("Privacy", systemImage: "lock.fill")
                    }
                }
                
                Section(header: Text("Preferences")) {
                    NavigationLink(destination: Text("Appearance")) {
                        Label("Appearance", systemImage: "paintbrush.fill")
                    }
                    NavigationLink(destination: Text("Language")) {
                        Label("Language", systemImage: "globe")
                    }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Help Center")) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    NavigationLink(destination: Text("Contact Us")) {
                        Label("Contact Us", systemImage: "envelope.fill")
                    }
                }
                
                Section {
                    Button(action: {}) {
                        Label("Sign Out", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAuthSheet) {
                if let merchant = selectedMerchant {
                    if merchant.status == .connected {
                        // Show disconnect sheet
                        DisconnectSheet(merchant: merchant) { confirmed in
                            if confirmed {
                                if let index = merchantConnections.firstIndex(where: { $0.id == merchant.id }) {
                                    merchantConnections[index].status = .disconnected
                                    merchantConnections[index].isEnabled = false
                                }
                            }
                            showingAuthSheet = false
                        }
                    } else {
                        // Show connect sheet
                        MerchantAuthSheet(merchant: merchant) { success in
                            if success {
                                if let index = merchantConnections.firstIndex(where: { $0.id == merchant.id }) {
                                    merchantConnections[index].isEnabled = true
                                    merchantConnections[index].status = .connected
                                }
                            }
                            showingAuthSheet = false
                        }
                    }
                }
            }
        }
    }
    
    private func statusText(for merchant: MerchantConnection) -> String {
        switch merchant.status {
        case .disconnected:
            return "Not connected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .error:
            return "Connection failed"
        }
    }
    
    private func statusIcon(for merchant: MerchantConnection) -> String {
        switch merchant.status {
        case .disconnected:
            return "link.badge.plus"
        case .connecting:
            return "ellipsis.circle"
        case .connected:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.circle"
        }
    }
    
    private func statusColor(for merchant: MerchantConnection) -> Color {
        switch merchant.status {
        case .disconnected:
            return .gray
        case .connecting:
            return .orange
        case .connected:
            return .green
        case .error:
            return .red
        }
    }
}

struct MerchantAuthSheet: View {
    let merchant: MerchantConnection
    let onComplete: (Bool) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isAuthenticating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Merchant Logo
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: merchant.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.purple)
                    )
                
                // Title and Description
                VStack(spacing: 8) {
                    Text("Connect to \(merchant.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Allow FrugalEra to access your purchase history and track your spending with \(merchant.name).")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Permissions List
                VStack(alignment: .leading, spacing: 12) {
                    PermissionRow(icon: "cart.fill", text: "View purchase history")
                    PermissionRow(icon: "dollarsign.circle", text: "Track spending")
                    PermissionRow(icon: "bell.fill", text: "Send notifications")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Connect Button
                Button(action: {
                    authenticateMerchant()
                }) {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Connect Account")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isAuthenticating)
                
                // Cancel Button
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func authenticateMerchant() {
        isAuthenticating = true
        
        // Simulate authentication delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAuthenticating = false
            onComplete(true)
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}

// Add this new view for disconnection confirmation
struct DisconnectSheet: View {
    let merchant: MerchantConnection
    let onComplete: (Bool) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Merchant Logo
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: merchant.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.red)
                    )
                
                // Title and Description
                VStack(spacing: 8) {
                    Text("Disconnect from \(merchant.name)?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This will stop sharing your purchase history with FrugalEra.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Disconnect Button
                Button(action: {
                    onComplete(true)
                }) {
                    Text("Disconnect Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                // Cancel Button
                Button("Cancel") {
                    onComplete(false)
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
