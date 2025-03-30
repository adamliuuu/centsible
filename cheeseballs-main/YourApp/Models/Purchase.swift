import Foundation

struct Purchase: Codable, Identifiable {
    let id: UUID
    let product_name: String
    let merchant: String
    let price: Double
    let purchase_time: String
    let payment_method: String
} 