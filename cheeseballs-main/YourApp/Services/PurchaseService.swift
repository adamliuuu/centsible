import Foundation

struct PurchaseResponse: Codable {
    let status: String
    let data: [Purchase]
}

class PurchaseService {
    static let shared = PurchaseService()
    
    private init() {}
    
    // Update port from 5000 to 8000
    private let baseURL = "http://localhost:8000"
    
    func getFunPurchases() async throws -> [Purchase] {
        guard let url = URL(string: "\(baseURL)/fun-purchases") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let purchaseResponse = try JSONDecoder().decode(PurchaseResponse.self, from: data)
        return purchaseResponse.data
    }
} 