import SwiftUI

struct FriendProfileView: View {
    let friendName: String
    @State private var showingTransactionHistory = false
    @State private var debtAmount = Double.random(in: -50...50)
    
    // Sample shared transactions
    private let sharedTransactions = [
        SharedTransaction(description: "Target Shopping Spree", amount: 85.50, date: Date().addingTimeInterval(-86400), splitWith: "You"),
        SharedTransaction(description: "Dinner at Chipotle", amount: 32.75, date: Date().addingTimeInterval(-172800), splitWith: "You"),
        SharedTransaction(description: "Movie Night", amount: 24.99, date: Date().addingTimeInterval(-259200), splitWith: "You"),
        SharedTransaction(description: "Grocery Run", amount: 127.80, date: Date().addingTimeInterval(-432000), splitWith: "You"),
        SharedTransaction(description: "Coffee Run", amount: 15.45, date: Date().addingTimeInterval(-518400), splitWith: "You")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 15) {
                    // Profile Image
                    Image("characterbrooke")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 5)
                    
                    Text(friendName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(friendName.lowercased().replacingOccurrences(of: " ", with: ""))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Debt Amount
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("You \(debtAmount >= 0 ? "owe" : "are owed")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(abs(debtAmount), specifier: "%.2f")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(debtAmount >= 0 ? .red : .green)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingTransactionHistory = true
                    }) {
                        Text("Shared History")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                .padding()
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
                        .padding(.horizontal)
                    
                    ForEach(1...5, id: \.self) { _ in
                        HStack {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.purple)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Spent $24.99 at Target")
                                    .font(.subheadline)
                                Text("2 hours ago")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingTransactionHistory) {
            TransactionHistoryView(transactions: sharedTransactions, friendName: friendName)
        }
    }
}

struct SharedTransaction: Identifiable {
    let id = UUID()
    let description: String
    let amount: Double
    let date: Date
    let splitWith: String
}

struct TransactionHistoryView: View {
    let transactions: [SharedTransaction]
    let friendName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(transactions) { transaction in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(transaction.description)
                                .font(.headline)
                            Spacer()
                            Text("$\(transaction.amount, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("Split with \(transaction.splitWith)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(transaction.date, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Shared with \(friendName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatCard: View {
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