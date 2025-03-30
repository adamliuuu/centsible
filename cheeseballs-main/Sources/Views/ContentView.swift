import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: selectedTab == 0 ? "newspaper.fill" : "newspaper")
                }
                .tag(0)
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: selectedTab == 1 ? "trophy.fill" : "trophy")
                }
                .tag(1)
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: selectedTab == 2 ? "person.2.fill" : "person.2")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: selectedTab == 4 ? "gear.circle.fill" : "gear.circle")
                }
                .tag(4)
        }
        .tint(.purple)
        .background(Theme.colors.background)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // Use this appearance for both normal and scrolling states
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// Placeholder Views with modern styling
struct LeaderboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Highlights Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Weekly Highlights")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 15) {
                            LeaderboardCard(title: "Most Frugal", value: "Sarah", icon: "leaf.fill", color: .green)
                            LeaderboardCard(title: "Best Deals", value: "Mike", icon: "tag.fill", color: .blue)
                            LeaderboardCard(title: "Savings", value: "Emma", icon: "dollarsign.circle.fill", color: .purple)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Monthly Rankings
                    VStack(alignment: .leading, spacing: 15) {
                        Text("March Rankings")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(1...5, id: \.self) { rank in
                            HStack {
                                Text("#\(rank)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                    .frame(width: 40)
                                
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("👤")
                                            .font(.system(size: 20))
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text("User \(rank)")
                                        .font(.headline)
                                    Text("Saved $\(1000 - rank * 100)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(100 - rank * 10) pts")
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
            .navigationTitle("Leaderboard")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct LeaderboardCard: View {
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

struct FriendsView: View {
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
                                ForEach(1...5, id: \.self) { _ in
                                    VStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Text("👤")
                                                    .font(.system(size: 30))
                                            )
                                        
                                        Text("Friend Name")
                                            .font(.subheadline)
                                        
                                        Button(action: {}) {
                                            Text("Add")
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
                        
                        ForEach(1...5, id: \.self) { _ in
                            HStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text("👤")
                                            .font(.system(size: 25))
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text("Friend Name")
                                        .font(.headline)
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
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Friends")
            .background(Color(.systemGroupedBackground))
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
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 