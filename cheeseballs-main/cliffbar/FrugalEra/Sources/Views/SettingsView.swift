import SwiftUI

struct MerchantConnection: Identifiable {
    let id: String
    let name: String
    let icon: String
    var isEnabled: Bool
}

struct SettingsView: View {
    @State private var merchantConnections: [MerchantConnection] = [
        MerchantConnection(id: "amazon", name: "Amazon", icon: "cart.fill", isEnabled: false),
        MerchantConnection(id: "walmart", name: "Walmart", icon: "basket.fill", isEnabled: false),
        MerchantConnection(id: "uber", name: "Uber", icon: "car.fill", isEnabled: false),
        MerchantConnection(id: "grubhub", name: "takeoutbag.and.cup.and.straw.fill", name: "Grubhub", isEnabled: false),
        MerchantConnection(id: "american-airlines", name: "American Airlines", icon: "airplane", isEnabled: false)
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Connected Merchants")) {
                    ForEach($merchantConnections) { $merchant in
                        HStack {
                            Image(systemName: merchant.icon)
                                .foregroundColor(Color(hex: "3A7D44"))
                                .frame(width: 30)
                            
                            Text(merchant.name)
                                .font(.body)
                            
                            Spacer()
                            
                            Toggle("", isOn: $merchant.isEnabled)
                                .tint(Color(hex: "3A7D44"))
                                .onChange(of: merchant.isEnabled) { isEnabled in
                                    if isEnabled {
                                        authenticateMerchant(merchant.id)
                                    } else {
                                        disconnectMerchant(merchant.id)
                                    }
                                }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .headerProminence(.increased)
                
                Section(
                    footer: Text("Enabling a merchant will allow the app to access and share your transaction data from that merchant.")
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarColor(Color(hex: "e2c4f5"))
        }
    }
    
    private func authenticateMerchant(_ id: String) {
        // Here you would implement OAuth or other authentication flow
        print("Authenticating with \(id)")
    }
    
    private func disconnectMerchant(_ id: String) {
        // Here you would implement the disconnect logic
        print("Disconnecting from \(id)")
    }
}

#Preview {
    SettingsView()
} 