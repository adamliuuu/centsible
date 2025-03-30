import SwiftUI

struct PurchasesView: View {
    @State private var purchases: [Purchase] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else if let error = error {
                    Text("Error: \(error.localizedDescription)")
                } else {
                    List(purchases, id: \.product_name) { purchase in
                        VStack(alignment: .leading) {
                            Text(purchase.product_name)
                                .font(.headline)
                            Text(purchase.merchant)
                                .font(.subheadline)
                            Text("$\(String(format: "%.2f", purchase.price))")
                                .font(.subheadline)
                            Text(purchase.purchase_time)
                                .font(.caption)
                            Text(purchase.payment_method)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Fun Purchases")
            .task {
                await loadPurchases()
            }
        }
    }
    
    private func loadPurchases() async {
        isLoading = true
        do {
            purchases = try await PurchaseService.shared.getFunPurchases()
        } catch {
            self.error = error
        }
        isLoading = false
    }
} 