import Foundation

struct Adam {
    let id: String
    let name: String
    let description: String
    
    init(id: String = UUID().uuidString, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
} 