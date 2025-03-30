import SwiftUI

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
                        
                        ForEach(friends, id: \.self) { friend in
                            Button(action: {
                                selectedFriend = friend
                                showingFriendProfile = true
                            }) {
                                HStack {
                                    Image("characterbrooke")
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
} 