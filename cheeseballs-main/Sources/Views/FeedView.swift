import SwiftUI
import Foundation
import MapKit

struct Purchase: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let date: Date
    let category: String
    let imageURL: String? // For now, we'll use a placeholder image
}

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct Trip: Identifiable {
    let id = UUID()
    let destination: Location
    let startTime: Date
    let creator: String
    var acceptedFriends: Set<String>
    var status: TripStatus
}

enum TripStatus {
    case pending
    case active
    case completed
}

struct DealItem: Identifiable {
    let id = UUID()
    let name: String
    let originalPrice: Double
    let dealPrice: Double
    let store: String
    let link: String
    let description: String
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FeedViewModel()
    @State private var postType: PostCreationType = .bestPurchase
    @State private var description = ""
    @State private var selectedPurchase: Purchase?
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    // Deal item state variables
    @State private var dealItemName = ""
    @State private var dealItemOriginalPrice = 0.0
    @State private var dealItemDealPrice = 0.0
    @State private var dealItemStore = ""
    @State private var dealItemLink = ""
    @State private var dealItemDescription = ""
    @State private var selectedFriends: Set<String> = []
    
    // Mock purchases data
    private let mockPurchases = [
        Purchase(name: "AirPods Pro", price: 249.99, date: Date().addingTimeInterval(-86400), category: "Electronics", imageURL: nil),
        Purchase(name: "Gym Membership", price: 29.99, date: Date().addingTimeInterval(-172800), category: "Health", imageURL: nil),
        Purchase(name: "New Shoes", price: 89.99, date: Date().addingTimeInterval(-259200), category: "Clothing", imageURL: nil),
        Purchase(name: "Coffee Maker", price: 79.99, date: Date().addingTimeInterval(-345600), category: "Home", imageURL: nil),
        Purchase(name: "Movie Tickets", price: 24.99, date: Date().addingTimeInterval(-432000), category: "Entertainment", imageURL: nil)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Post Type Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What type of post?")
                            .font(.headline)
                        
                        Picker("Post Type", selection: $postType) {
                            Text("Best Purchase 🏆").tag(PostCreationType.bestPurchase)
                            Text("Plan Trip 🗺️").tag(PostCreationType.tripPlanning)
                            Text("Good Deal 💰").tag(PostCreationType.goodDeal)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    
                    // Dynamic Content based on post type
                    switch postType {
                    case .bestPurchase:
                        bestPurchaseContent
                    case .tripPlanning:
                        TripPlanningView()
                    case .goodDeal:
                        goodDealContent
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        createPost()
                    }) {
                        Text("Post")
                            .fontWeight(.bold)
                            .foregroundColor(Theme.colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private var bestPurchaseContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Purchase Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Select Your Best Purchase")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(mockPurchases) { purchase in
                            PurchaseCard(
                                purchase: purchase,
                                isSelected: selectedPurchase?.id == purchase.id
                            ) {
                                selectedPurchase = purchase
                            }
                        }
                    }
                }
            }
            
            // Description Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Why is this your best purchase?")
                    .font(.headline)
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Image Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Add a Photo")
                    .font(.headline)
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                        Text(selectedImage == nil ? "Select Photo" : "Change Photo")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var goodDealContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Item Details
            VStack(alignment: .leading, spacing: 10) {
                Text("Item Details")
                    .font(.headline)
                
                TextField("Item Name", text: $dealItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    TextField("Original Price", value: $dealItemOriginalPrice, format: .currency(code: "USD"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                    TextField("Deal Price", value: $dealItemDealPrice, format: .currency(code: "USD"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                TextField("Store", text: $dealItemStore)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Product Link", text: $dealItemLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextEditor(text: $dealItemDescription)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
    }
    
    private func createPost() {
        switch postType {
        case .bestPurchase:
            guard let purchase = selectedPurchase else { return }
            let newItem = FeedItem(
                id: UUID(),
                title: "Best Purchase: \(purchase.name)",
                description: description.isEmpty ? "Just bought \(purchase.name) for $\(String(format: "%.2f", purchase.price))" : description,
                timestamp: Date(),
                type: .purchase,
                comments: 0,
                userImage: selectedImage != nil ? "📸" : "👤",
                userName: "You",
                isYourPost: true
            )
            
            if selectedImage != nil {
                print("Image would be uploaded here in a real app")
            }
            
            viewModel.feedItems.insert(newItem, at: 0)
            
        case .tripPlanning:
            // Create a trip post
            let newItem = FeedItem(
                id: UUID(),
                title: "Planning a Trip 🗺️",
                description: "Planning to visit Golden Gate Park. Join me!",
                timestamp: Date(),
                type: .social,
                comments: 0,
                userImage: "👤",
                userName: "You",
                isYourPost: true
            )
            viewModel.feedItems.insert(newItem, at: 0)
            
        case .goodDeal:
            let savings = dealItemOriginalPrice - dealItemDealPrice
            let savingsPercentage = (savings / dealItemOriginalPrice) * 100
            
            let newItem = FeedItem(
                id: UUID(),
                title: "🔥 Great Deal Alert!",
                description: """
                    Found \(dealItemName) at \(dealItemStore)!
                    Original: $\(String(format: "%.2f", dealItemOriginalPrice))
                    Deal: $\(String(format: "%.2f", dealItemDealPrice))
                    Save \(Int(savingsPercentage))%!
                    
                    \(dealItemDescription)
                    
                    Link: \(dealItemLink)
                    """,
                timestamp: Date(),
                type: .purchase,
                comments: 0,
                userImage: "👤",
                userName: "You",
                isYourPost: true
            )
            viewModel.feedItems.insert(newItem, at: 0)
        }
        
        dismiss()
    }
}

enum PostCreationType {
    case bestPurchase
    case tripPlanning
    case goodDeal
}

struct PurchaseCard: View {
    let purchase: Purchase
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(purchase.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("$\(String(format: "%.2f", purchase.price))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: 120)
            .padding(8)
            .background(isSelected ? Theme.colors.primary.opacity(0.2) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedFilter = 0
    @State private var showingComments = false
    @State private var showingCreatePost = false
    
    private let filters = ["All", "Activity", "Posts", "Trips", "Recommendations"]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(filters.enumerated()), id: \.element) { index, filter in
                                    FilterPill(title: filter, isSelected: selectedFilter == index) {
                                        withAnimation(.spring()) {
                                            selectedFilter = index
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Feed Items
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.feedItems.filter { filterItem($0) }) { item in
                                FeedItemCard(item: item, viewModel: viewModel, showingComments: $showingComments)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .shadow(color: Color(hex: "e2c4f5").opacity(0.2), radius: 5, x: 0, y: 2)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .padding(1)
                            )
                    }
                    .padding(.trailing, 4)
                    .padding(.top, 12)
                }
            }
            .toolbarBackground(Color(hex: "e2c4f5"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Feed")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            }
            .refreshable {
                viewModel.fetchFeedItems()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
            .background(Color(.systemBackground))
            .sheet(isPresented: $showingComments) {
                CommentsView()
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView()
            }
        }
        .onAppear {
            viewModel.fetchFeedItems()
        }
        .onChange(of: selectedFilter) { _ in
            viewModel.fetchFeedItems()
        }
    }
    
    private func filterItem(_ item: FeedItem) -> Bool {
        switch selectedFilter {
        case 0: return true
        case 1: return item.type == .health || item.type == .spending
        case 2: return item.type == .purchase || item.type == .social
        case 3: return item.type == .social && item.title.contains("Trip")
        case 4: return item.type == .purchase && item.title.contains("Deal")
        default: return true
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color(hex: "3A7D44"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "3A7D44") : Color(red: 0.95, green: 0.95, blue: 0.98))
                        .shadow(color: isSelected ? Color(hex: "3A7D44").opacity(0.3) : Color.clear, radius: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "3A7D44"), lineWidth: 2)
                )
        }
    }
}

struct FeedItemCard: View {
    let item: FeedItem
    @ObservedObject var viewModel: FeedViewModel
    @Binding var showingComments: Bool
    @State private var showingEmojiPicker = false
    @State private var selectedEmoji = ""
    
    private let commonEmojis = ["❤️", "😂", "🔥"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and menu
            HStack {
                Text(item.userName.split(separator: " ").first ?? "")  // First name only
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(item.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                
                Menu {
                    Button(action: {}) {
                        Label("Report", systemImage: "exclamationmark.triangle")
                    }
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            
            // Content with image and description
            HStack(alignment: .top, spacing: 12) {
                // Character Image
                Image("characterbrooke")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "1E4F2A"), lineWidth: 1)
                    )
                
                // Description
                Text(item.description)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            
            // Reactions Display
            if !viewModel.getReactions(for: item.id).isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.getReactions(for: item.id), id: \.emoji) { reaction in
                            Button(action: {
                                viewModel.toggleReaction(reaction.emoji, by: "You", to: item.id)
                            }) {
                                HStack(spacing: 4) {
                                    Text(reaction.emoji)
                                    Text("\(reaction.count)")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.95, green: 0.95, blue: 0.98))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            
            // Interaction Buttons
            HStack(spacing: 16) {
                // Emoji Reaction Button
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring()) {
                            showingEmojiPicker.toggle()
                        }
                    }) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                    }
                    
                    if showingEmojiPicker {
                        ForEach(commonEmojis, id: \.self) { emoji in
                            Button(action: {
                                viewModel.toggleReaction(emoji, by: "You", to: item.id)
                                withAnimation(.spring()) {
                                    showingEmojiPicker = false
                                }
                            }) {
                                Text(emoji)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        Button(action: {
                            // Add custom emoji picker functionality
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.95, green: 0.95, blue: 0.98))
                .cornerRadius(12)
                
                Button(action: { showingComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                        Text("\(item.comments)")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                    }
                }
                
                if item.isYourPost {
                    Button(action: {
                        viewModel.currentPostId = item.id
                        viewModel.showingFriendSelector = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.hasAddedFriends(for: item.id) ? "checkmark.circle.fill" : "person.badge.plus")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                            Text(viewModel.hasAddedFriends(for: item.id) ? "See Added Friends" : "Add Friends")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                        }
                    }
                } else {
                    Button(action: {
                        viewModel.toggleFriendRequest(for: item.id)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.hasRequestedToBeAdded(for: item.id) ? "checkmark.circle.fill" : "person.badge.plus")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                            Text(viewModel.hasRequestedToBeAdded(for: item.id) ? "Sent" : "Add me")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "1E4F2A").opacity(0.8))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1E4F2A"), lineWidth: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "1E4F2A").opacity(0.5), lineWidth: 2)
                .padding(2)
        )
        .shadow(color: Color(hex: "1E4F2A").opacity(0.1), radius: 5, x: 0, y: 2)
        .shadow(color: Color(hex: "1E4F2A").opacity(0.2), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $viewModel.showingFriendSelector) {
            FriendSelectorView(viewModel: viewModel)
        }
    }
}

struct FriendSelectorView: View {
    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingAddMore = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let postId = viewModel.currentPostId {
                    if viewModel.hasAddedFriends(for: postId) {
                        // Show added friends list
                        List {
                            Section(header: Text("Added Friends")) {
                                ForEach(viewModel.getSelectedFriends(for: postId), id: \.self) { friend in
                                    HStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text("👤")
                                                    .font(.system(size: 16))
                                            )
                                        
                                        Text(friend)
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            viewModel.toggleFriendSelection(for: postId, friendName: friend)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            
                            Section {
                                Button(action: { showingAddMore = true }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Add More Friends")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                    } else {
                        // Show add friends list
                        List {
                            ForEach(viewModel.availableFriends, id: \.self) { friend in
                                Button(action: {
                                    viewModel.toggleFriendSelection(for: postId, friendName: friend)
                                }) {
                                    HStack {
                                        Text(friend)
                                        Spacer()
                                        if viewModel.isFriendSelected(for: postId, friendName: friend) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.hasAddedFriends(for: viewModel.currentPostId ?? UUID()) ? "Added Friends" : "Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddMore) {
                AddMoreFriendsView(viewModel: viewModel)
            }
        }
    }
}

struct AddMoreFriendsView: View {
    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.availableFriends, id: \.self) { friend in
                    if let postId = viewModel.currentPostId,
                       !viewModel.isFriendSelected(for: postId, friendName: friend) {
                        Button(action: {
                            viewModel.toggleFriendSelection(for: postId, friendName: friend)
                        }) {
                            HStack {
                                Text(friend)
                                Spacer()
                                if viewModel.isFriendSelected(for: postId, friendName: friend) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add More Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    
    // Sample comments for different types of posts
    private let comments = [
        Comment(userName: "Alex Smith", text: "That's such a good deal! I've been looking for something similar but everything's so expensive rn 😭", timeAgo: "2h ago"),
        Comment(userName: "Sam Chen", text: "Pro tip: Check out the clearance section next time! I got mine for 30% off", timeAgo: "3h ago"),
        Comment(userName: "Jordan Taylor", text: "Was this worth it? I'm debating getting one too but trying to be more mindful of spending", timeAgo: "4h ago"),
        Comment(userName: "Riley Patel", text: "OMG I wanted to buy this! Where did you find it?", timeAgo: "5h ago"),
        Comment(userName: "Morgan Lee", text: "You can find similar items at thrift stores for way less! Just saying 💅", timeAgo: "6h ago"),
        Comment(userName: "Casey Wong", text: "Remember to check if you really need it before buying! I've been trying to follow the 24-hour rule", timeAgo: "7h ago"),
        Comment(userName: "Jamie Rodriguez", text: "That's actually a pretty good price compared to what I've seen lately", timeAgo: "8h ago"),
        Comment(userName: "Taylor Kim", text: "I got something similar last month and it's been worth every penny!", timeAgo: "9h ago")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(comments, id: \.userName) { comment in
                        CommentRow(comment: comment)
                    }
                }
                
                HStack {
                    TextField("Add a comment...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        newComment = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct Comment: Identifiable {
    let id = UUID()
    let userName: String
    let text: String
    let timeAgo: String
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("👤")
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                Text(comment.text)
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text(comment.timeAgo)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.8))
            }
        }
        .padding(.vertical, 4)
    }
}

struct TripPlanningView: View {
    @State private var searchText = ""
    @State private var selectedLocation: Location?
    @State private var showingMap = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedFriends: Set<String> = []
    
    // Mock friend locations
    private let friendLocations = [
        Location(name: "Brooke's Location", coordinate: CLLocationCoordinate2D(latitude: 37.7848, longitude: -122.4298)),
        Location(name: "Nicole's Location", coordinate: CLLocationCoordinate2D(latitude: 37.7948, longitude: -122.4098)),
        Location(name: "Ziya's Location", coordinate: CLLocationCoordinate2D(latitude: 37.7748, longitude: -122.4198))
    ]
    
    // Mock suggested locations
    private let suggestedLocations = [
        Location(name: "Golden Gate Park", coordinate: CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4862)),
        Location(name: "Fisherman's Wharf", coordinate: CLLocationCoordinate2D(latitude: 37.8097, longitude: -122.4098)),
        Location(name: "Alcatraz Island", coordinate: CLLocationCoordinate2D(latitude: 37.8267, longitude: -122.4233))
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Search Bar
            VStack(alignment: .leading, spacing: 10) {
                Text("Where are you going?")
                    .font(.headline)
                
                HStack {
                    TextField("Search location...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if selectedLocation != nil {
                        Button(action: {
                            selectedLocation = nil
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onChange(of: searchText) { _ in
                    // In a real app, this would trigger location search
                }
                
                if !searchText.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(suggestedLocations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }) { location in
                                Button(action: {
                                    selectedLocation = location
                                    searchText = location.name
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(Theme.colors.primary)
                                        Text(location.name)
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 200)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Map View
            VStack(alignment: .leading, spacing: 10) {
                Text("Friend Locations")
                    .font(.headline)
                
                Map(coordinateRegion: $region, annotationItems: friendLocations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(Theme.colors.primary)
                            Text(location.name)
                                .font(.caption)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if let location = selectedLocation {
                // Trip Details
                VStack(alignment: .leading, spacing: 10) {
                    Text("Trip Details")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Theme.colors.primary)
                        Text(location.name)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedLocation = nil
                            searchText = ""
                        }) {
                            Text("Change")
                                .foregroundColor(Theme.colors.primary)
                        }
                    }
                    
                    Text("Friends on the way:")
                        .font(.subheadline)
                    
                    HStack {
                        Button(action: {
                            if selectedFriends.count == friendLocations.count {
                                selectedFriends.removeAll()
                            } else {
                                selectedFriends = Set(friendLocations.map { $0.name })
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedFriends.count == friendLocations.count ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(Theme.colors.primary)
                                Text(selectedFriends.count == friendLocations.count ? "Deselect All" : "Select All")
                                    .foregroundColor(Theme.colors.primary)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(selectedFriends.count) selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(friendLocations) { friend in
                                FriendTripCard(
                                    name: friend.name,
                                    isSelected: selectedFriends.contains(friend.name)
                                ) {
                                    if selectedFriends.contains(friend.name) {
                                        selectedFriends.remove(friend.name)
                                    } else {
                                        selectedFriends.insert(friend.name)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct FriendTripCard: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.colors.primary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.colors.primary.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? Theme.colors.primary : .black)
            .cornerRadius(16)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

// Add Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 