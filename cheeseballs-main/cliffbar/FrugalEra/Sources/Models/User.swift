import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var username: String
    var profileImage: String?
    var bio: String?
    var spendingCategories: [SpendingCategory]
    var friends: [String] // Friend IDs
    var achievements: [Achievement]
    var privacySettings: PrivacySettings
    
    // Computed properties for statistics
    var totalSpent: Double {
        spendingCategories.reduce(0) { $0 + $1.totalSpent }
    }
    
    var monthlyHighlights: [Transaction] {
        // TODO: Implement monthly highlights logic
        []
    }
}

struct SpendingCategory: Codable {
    let name: String
    var transactions: [Transaction]
    var totalSpent: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
}

struct Transaction: Identifiable, Codable {
    let id: String
    let amount: Double
    let date: Date
    let category: String
    let description: String
    let location: String?
    let isShared: Bool
    let sharedWith: [String]? // User IDs
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let dateEarned: Date
    let type: AchievementType
}

enum AchievementType: String, Codable {
    case spending
    case saving
    case social
    case streak
}

struct PrivacySettings: Codable {
    var showTransactions: Bool
    var showSpendingCategories: Bool
    var showAchievements: Bool
    var showLocation: Bool
} 