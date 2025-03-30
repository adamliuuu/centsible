import Foundation
import SwiftUI

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
    
    // Sample friends list
    let availableFriends = [
        "Brooke Xu",
        "Nicole Deng",
        "Ziya Momin",
        "Adam Liu",
        "Joe Fisherman",
        "Bennett Zeus"
    ]
    
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
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Sample data
            self.feedItems = [
                // Your most recent post first
                FeedItem(
                    id: UUID(),
                    title: "Late Night Shopping Alert 🚨",
                    description: "You made an impulse purchase at Target at 2 AM... we've all been there bestie",
                    timestamp: Date().addingTimeInterval(-1800), // 30 mins ago
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "You",
                    isYourPost: true
                ),
                // Other users' recent posts
                FeedItem(
                    id: UUID(),
                    title: "Brooke is in their frugal era 💅",
                    description: "Just started a new budget and saved $200 this week! Living that broke girl lifestyle fr fr",
                    timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                    type: .spending,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Brooke",
                    isYourPost: false
                ),
                FeedItem(
                    id: UUID(),
                    title: "Energy Drink Addiction Alert ⚡️",
                    description: "Nicole just bought their 4th Red Bull of the day... at this point they're probably vibrating through walls",
                    timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Nicole",
                    isYourPost: false
                ),
                // Your second post
                FeedItem(
                    id: UUID(),
                    title: "Saving Season 💰",
                    description: "You just saved $50 by using coupons at the grocery store! Living that frugal life",
                    timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                    type: .spending,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "You",
                    isYourPost: true
                ),
                // Other users' older posts
                FeedItem(
                    id: UUID(),
                    title: "Health Check! 🏥",
                    description: "Adam has a doctor's appointment tomorrow - sending good vibes! Don't forget to check in on your friends",
                    timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                    type: .health,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Adam",
                    isYourPost: false
                ),
                FeedItem(
                    id: UUID(),
                    title: "New Drip Alert 👀",
                    description: "Ziya just bought something expensive at Best Buy - check out their new setup!",
                    timestamp: Date().addingTimeInterval(-172800), // 2 days ago
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Ziya",
                    isYourPost: false
                ),
                FeedItem(
                    id: UUID(),
                    title: "Touch Grass Alert 🌱",
                    description: "Bennett just subscribed to their 5th streaming service... maybe go outside?",
                    timestamp: Date().addingTimeInterval(-345600), // 4 days ago
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Bennett",
                    isYourPost: false
                )
            ]
            
            self.isLoading = false
        }
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
}

enum FeedItemType {
    case spending
    case purchase
    case health
    case achievement
    case social
    case recommendation
} 