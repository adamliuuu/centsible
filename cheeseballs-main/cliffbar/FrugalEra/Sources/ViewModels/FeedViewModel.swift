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
        // Initialize with sample data
        feedItems = [
            FeedItem(
                id: UUID(),
                title: "Best Purchase",
                description: "Just got these AirPods Pro for $249.99! They're absolutely worth every penny - the noise cancellation is incredible and the sound quality is amazing. Perfect for my daily commute and workouts. Best tech purchase I've made this year! 🎧",
                timestamp: Date().addingTimeInterval(-2*24*60*60), // 2 days ago
                type: .purchase,
                comments: 12,
                userImage: "👤",
                userName: "Sarah Chen",
                isYourPost: false
            ),
            FeedItem(
                id: UUID(),
                title: "Impatient Much? 🎵",
                description: "Ziya just just paid for expedited shipping on a personalized kazoo?? Patience is NOT her strong suit.",
                timestamp: Date(),
                type: .purchase,
                comments: Int.random(in: 1...10),
                userImage: "👤",
                userName: "Ziya",
                isYourPost: false
            ),
            FeedItem(
                id: UUID(),
                title: "Hackathon Prep? 🏃‍♀️",
                description: "Nicole just loaded up on a Celsius and a bulk pack of 64 cliff bars. It's not like she's going to win HackPrinceton anyways.",
                timestamp: Date().addingTimeInterval(-3600),
                type: .purchase,
                comments: Int.random(in: 1...10),
                userImage: "characternicole",
                userName: "Nicole",
                isYourPost: false
            ),
            FeedItem(
                id: UUID(),
                title: "TikTok Made Me Buy It ✏️",
                description: "Brooke just bought a $500 artisanal pencil off a TikTok shop. Is she going to use that to write more checks she can't cash?",
                timestamp: Date().addingTimeInterval(-7200),
                type: .purchase,
                comments: Int.random(in: 1...10),
                userImage: "👤",
                userName: "Brooke",
                isYourPost: false
            ),
            FeedItem(
                id: UUID(),
                title: "Gamer Moment 🎮",
                description: "WOW Adam just bought a Fortnite \"Ultra Rare!\" skin bundle. Someone needs to touch some grass…",
                timestamp: Date().addingTimeInterval(-86400),
                type: .purchase,
                comments: Int.random(in: 1...10),
                userImage: "👤",
                userName: "Adam",
                isYourPost: false
            ),
            FeedItem(
                id: UUID(),
                title: "Health Check 🏥",
                description: "Joe just went to get his back checked. Wonder if it's scoliosis or for carrying all of his emotional baggage?",
                timestamp: Date().addingTimeInterval(-172800),
                type: .health,
                comments: Int.random(in: 1...10),
                userImage: "👤",
                userName: "Joe",
                isYourPost: false
            ),
            FeedItem(
                id: UUID(),
                title: "Kung Fu Fighting 🥟",
                description: "Bennett just paid his jiu jitsu dues and bought a giant bag of dumplings. He's training to be the next Dragon Warrior.",
                timestamp: Date().addingTimeInterval(-259200),
                type: .purchase,
                comments: Int.random(in: 1...10),
                userImage: "👤",
                userName: "Bennett",
                isYourPost: false
            )
        ]
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
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Create feed items with the new messages
            self.feedItems = [
                // Your trip planning post (always at top)
                FeedItem(
                    id: UUID(),
                    title: "Trip to Downtown Mall 🛍️",
                    description: "Planning to go shopping at Downtown Mall. Join me!",
                    timestamp: Date(),
                    type: .social,
                    comments: 3,
                    userImage: "👤",
                    userName: "You",
                    isYourPost: true,
                    tripDetails: TripDetails(
                        destination: "Downtown Mall",
                        date: Date().addingTimeInterval(24*60*60), // Tomorrow
                        confirmedFriends: ["Nicole", "Ziya"],
                        pendingFriends: ["Brooke", "Adam"],
                        isScheduled: true
                    )
                ),
                FeedItem(
                    id: UUID(),
                    title: "Impatient Much? 🎵",
                    description: "Ziya just just paid for expedited shipping on a personalized kazoo?? Patience is NOT her strong suit.",
                    timestamp: Date(),
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Ziya",
                    isYourPost: false
                ),
                // Trip invitation from someone else
                FeedItem(
                    id: UUID(),
                    title: "Shopping Trip to City Center 🛍️",
                    description: "Hey! Planning a shopping trip to City Center. Would you like to join?",
                    timestamp: Date().addingTimeInterval(-30*60), // 30 minutes ago
                    type: .social,
                    comments: 5,
                    userImage: "👤",
                    userName: "Alex Smith",
                    isYourPost: false,
                    tripDetails: TripDetails(
                        destination: "City Center",
                        date: Date().addingTimeInterval(48*60*60), // Day after tomorrow
                        confirmedFriends: ["Jordan", "Taylor"],
                        pendingFriends: ["You"],
                        isScheduled: false
                    )
                ),
                FeedItem(
                    id: UUID(),
                    title: "Hackathon Prep? 🏃‍♀️",
                    description: "Nicole just loaded up on a Celsius and a bulk pack of 64 cliff bars. It's not like she's going to win HackPrinceton anyways.",
                    timestamp: Date().addingTimeInterval(-3600),
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "characternicole",
                    userName: "Nicole",
                    isYourPost: false
                ),
                // Best purchase post
                FeedItem(
                    id: UUID(),
                    title: "AirPods Pro - $249.99",
                    description: "They're absolutely worth every penny! The noise cancellation is incredible and the sound quality is amazing. Perfect for my daily commute and workouts. Best tech purchase I've made this year! 🎧",
                    timestamp: Date().addingTimeInterval(-90*60), // 1 hour and 30 minutes ago
                    type: .purchase,
                    comments: 12,
                    userImage: "👤",
                    userName: "Sarah Chen",
                    isYourPost: false,
                    hasImage: true
                ),
                FeedItem(
                    id: UUID(),
                    title: "TikTok Made Me Buy It ✏️",
                    description: "Brooke just bought a $500 artisanal pencil off a TikTok shop. Is she going to use that to write more checks she can't cash?",
                    timestamp: Date().addingTimeInterval(-7200),
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Brooke",
                    isYourPost: false
                ),
                FeedItem(
                    id: UUID(),
                    title: "Gamer Moment 🎮",
                    description: "WOW Adam just bought a Fortnite \"Ultra Rare!\" skin bundle. Someone needs to touch some grass…",
                    timestamp: Date().addingTimeInterval(-86400),
                    type: .purchase,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Adam",
                    isYourPost: false
                ),
                FeedItem(
                    id: UUID(),
                    title: "Health Check 🏥",
                    description: "Joe just went to get his back checked. Wonder if it's scoliosis or for carrying all of his emotional baggage?",
                    timestamp: Date().addingTimeInterval(-172800),
                    type: .health,
                    comments: Int.random(in: 1...10),
                    userImage: "👤",
                    userName: "Joe",
                    isYourPost: false
                ),
                FeedItem(
                    id: UUID(),
                    title: "Kung Fu Fighting 🥟",
                    description: "Bennett just paid his jiu jitsu dues and bought a giant bag of dumplings. He's training to be the next Dragon Warrior.",
                    timestamp: Date().addingTimeInterval(-259200),
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