import SwiftUI
import Foundation
import CoreLocation
import UIKit
import MapKit

// Shared model structs
struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let isDestination: Bool
    let isFriend: Bool
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
            .navigationBarColor(Color(hex: "e2c4f5"))
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

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

enum PostCreationType {
    case bestPurchase
    case tripPlanning
    case goodDeal
}

struct Purchase: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let date: Date
    let category: String
    let imageURL: String?
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
            VStack(alignment: .leading, spacing: 10) {
                Text("Deal Details")
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
                
                TextEditor(text: $dealItemDescription)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    
    private func createPost() {
        switch postType {
        case .bestPurchase:
            let newItem = FeedItem(
                id: UUID(),
                title: "Best Purchase",
                description: description,
                timestamp: Date(),
                type: .purchase,
                comments: 0,
                userImage: selectedImage != nil ? "📸" : "👤",
                userName: "You",
                isYourPost: true
            )
            viewModel.feedItems.insert(newItem, at: 0)
            
        case .tripPlanning:
            let newItem = FeedItem(
                id: UUID(),
                title: "Planning a Trip 🗺️",
                description: "Planning to visit. Join me!",
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

// Add ImagePicker struct
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

struct TripPlanningView: View {
    @State private var searchText = ""
    @State private var selectedLocation: Location?
    @State private var showingMap = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedFriends: Set<String> = []
    
    // Add fixed user location
    private let userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Fixed location in SF
    
    // Sample locations (stores, restaurants, etc.)
    private let locations = [
        Location(name: "Downtown Coffee Shop", coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4294)),
        Location(name: "City Mall", coordinate: CLLocationCoordinate2D(latitude: 37.7899, longitude: -122.4194)),
        Location(name: "Central Park", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4294)),
        Location(name: "Movie Theater", coordinate: CLLocationCoordinate2D(latitude: 37.7819, longitude: -122.4154)),
        Location(name: "Sports Complex", coordinate: CLLocationCoordinate2D(latitude: 37.7729, longitude: -122.4224)),
        Location(name: "Public Library", coordinate: CLLocationCoordinate2D(latitude: 37.7789, longitude: -122.4164)),
        Location(name: "Tech Museum", coordinate: CLLocationCoordinate2D(latitude: 37.7869, longitude: -122.4134))
    ]
    
    // Friend locations
    private let friends = [
        Friend(name: "Brooke", coordinate: CLLocationCoordinate2D(latitude: 37.7848, longitude: -122.4298)),
        Friend(name: "Nicole", coordinate: CLLocationCoordinate2D(latitude: 37.7948, longitude: -122.4098)),
        Friend(name: "Ziya", coordinate: CLLocationCoordinate2D(latitude: 37.7748, longitude: -122.4198)),
        Friend(name: "Alex", coordinate: CLLocationCoordinate2D(latitude: 37.7828, longitude: -122.4158)),
        Friend(name: "Jordan", coordinate: CLLocationCoordinate2D(latitude: 37.7898, longitude: -122.4258)),
        Friend(name: "Adam", coordinate: CLLocationCoordinate2D(latitude: 37.7868, longitude: -122.4228)),
        Friend(name: "Joe", coordinate: CLLocationCoordinate2D(latitude: 37.7808, longitude: -122.4148)),
        Friend(name: "Bennett", coordinate: CLLocationCoordinate2D(latitude: 37.7918, longitude: -122.4178))
    ]
    
    var filteredLocations: [Location] {
        if searchText.isEmpty {
            return []
        }
        return locations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var friendsOnRoute: [Friend] {
        guard let destination = selectedLocation else { return [] }
        
        return friends.filter { friend in
            let userToDestination = calculateDistance(from: userLocation, to: destination.coordinate)
            let userToFriend = calculateDistance(from: userLocation, to: friend.coordinate)
            let friendToDestination = calculateDistance(from: friend.coordinate, to: destination.coordinate)
            
            return userToFriend + friendToDestination <= userToDestination * 1.2
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Where are you going?")
                    .font(.headline)
                
                HStack {
                    TextField("Search location...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if selectedLocation != nil {
                        Button(action: {
                            selectedLocation = nil
                            searchText = ""
                            showingMap = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !searchText.isEmpty && selectedLocation == nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(filteredLocations) { location in
                                Button(action: {
                                    selectedLocation = location
                                    searchText = location.name
                                    updateRegionForSelectedLocation()
                                    showingMap = true
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.blue)
                                        Text(location.name)
                                    }
                                    .foregroundColor(.primary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
            .padding(.horizontal)
            
            // Map with improved annotations
            if showingMap && selectedLocation != nil {
                Map(coordinateRegion: $region, annotationItems: mapAnnotations) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack(spacing: 0) {
                            if item.isDestination {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title)
                            } else if item.isFriend {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            
                            Text(item.title)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(4)
                                .shadow(radius: 2)
                        }
                    }
                }
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // Horizontal scrolling friend selection
            if showingMap && selectedLocation != nil {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Select friends to invite")
                            .font(.headline)
                        Spacer()
                        HStack(spacing: 12) {
                            Button(action: { selectAllFriends() }) {
                                Text("Select All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            Button(action: { deselectAllFriends() }) {
                                Text("Deselect All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(friendsOnRoute) { friend in
                                FriendSelectionButton(
                                    friend: friend,
                                    isSelected: selectedFriends.contains(friend.name),
                                    action: {
                                        if selectedFriends.contains(friend.name) {
                                            selectedFriends.remove(friend.name)
                                        } else {
                                            selectedFriends.insert(friend.name)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var mapAnnotations: [LocationAnnotation] {
        var annotations: [LocationAnnotation] = []
        
        if let destination = selectedLocation {
            annotations.append(LocationAnnotation(
                coordinate: destination.coordinate,
                title: destination.name,
                isDestination: true,
                isFriend: false
            ))
        }
        
        for friend in friends {
            annotations.append(LocationAnnotation(
                coordinate: friend.coordinate,
                title: friend.name,
                isDestination: false,
                isFriend: true
            ))
        }
        
        // Use fixed userLocation instead of region.center
        annotations.append(LocationAnnotation(
            coordinate: userLocation,
            title: "You",
            isDestination: false,
            isFriend: false
        ))
        
        return annotations
    }
    
    private func updateRegionForSelectedLocation() {
        guard let location = selectedLocation else { return }
        
        // Use userLocation instead of region.center
        let coordinates = [userLocation, location.coordinate]
        let minLat = coordinates.map { $0.latitude }.min()!
        let maxLat = coordinates.map { $0.latitude }.max()!
        let minLon = coordinates.map { $0.longitude }.min()!
        let maxLon = coordinates.map { $0.longitude }.max()!
        
        let latPadding = (maxLat - minLat) * 0.2
        let lonPadding = (maxLon - minLon) * 0.2
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) + latPadding,
                longitudeDelta: (maxLon - minLon) + lonPadding
            )
        )
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    private func selectAllFriends() {
        friendsOnRoute.forEach { friend in
            selectedFriends.insert(friend.name)
        }
    }
    
    private func deselectAllFriends() {
        selectedFriends.removeAll()
    }
}

struct FriendSelectionButton: View {
    let friend: Friend
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(isSelected ? .white : .gray)
                        .font(.system(size: 24))
                }
                
                Text(friend.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
    }
}

// Add this extension for navigation bar color
extension View {
    func navigationBarColor(_ backgroundColor: Color) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
}

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: Color
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
    }
} 
 
