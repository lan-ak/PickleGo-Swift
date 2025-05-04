import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var playerStore: PlayerStore
    @State private var showingEditProfile = false
    @State private var showingAddContact = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var displayedContactsCount = 5 // Initial number of contacts to show
    @State private var searchText = ""
    
    private var contacts: [Player] {
        playerStore.players
            .filter { $0.isRegistered }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    private var filteredContacts: [Player] {
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var displayedContacts: [Player] {
        Array(filteredContacts.prefix(displayedContactsCount))
    }
    
    private var hasMoreContacts: Bool {
        displayedContactsCount < filteredContacts.count
    }
    
    private var pendingInvites: [Player] {
        playerStore.players.filter { $0.inviteStatus == .pending }
    }
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 28) {
                    // Profile Header
                    cardSection {
                        VStack(spacing: 16) {
                            if let user = authService.currentUser {
                                if let photoURL = user.photoURL {
                                    AsyncImage(url: URL(string: photoURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                    }
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(user.displayName ?? user.username)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(PickleGoTheme.dark)
                                    
                                    if let rating = user.rating {
                                        HStack(spacing: 4) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                            Text(String(format: "%.1f", rating))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Button(action: { showingEditProfile = true }) {
                                    Text("Edit Profile")
                                        .font(.subheadline)
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                            } else {
                                Text("Not logged in")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    
                    // Contacts Section
                    cardSection {
                        Section(header: sectionHeader("Contacts")) {
                            VStack(spacing: 16) {
                                // Search Bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    TextField("Search contacts", text: $searchText)
                                        .textFieldStyle(.plain)
                                        .autocapitalization(.none)
                                    if !searchText.isEmpty {
                                        Button(action: { searchText = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(8)
                                .background(PickleGoTheme.card)
                                .cornerRadius(8)
                                
                                if filteredContacts.isEmpty {
                                    Text(searchText.isEmpty ? "No contacts added yet" : "No contacts found")
                                        .foregroundColor(.secondary)
                                        .font(.body)
                                } else {
                                    ForEach(displayedContacts) { contact in
                                        contactRow(contact)
                                    }
                                    
                                    if hasMoreContacts {
                                        Button(action: { displayedContactsCount += 5 }) {
                                            HStack {
                                                Text("Load More")
                                                    .font(.subheadline)
                                                Image(systemName: "chevron.down")
                                            }
                                            .foregroundColor(PickleGoTheme.primaryGreen)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                        }
                                    }
                                }
                                
                                Button(action: { showingAddContact = true }) {
                                    Label("Invite Player", systemImage: "person.badge.plus")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(PickleGoTheme.primaryGreen)
                                        .cornerRadius(PickleGoTheme.cornerRadius)
                                        .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                                }
                            }
                        }
                    }
                    
                    // Pending Invites Section
                    if !pendingInvites.isEmpty {
                        cardSection {
                            Section(header: sectionHeader("Pending Invites")) {
                                VStack(spacing: 12) {
                                    ForEach(pendingInvites) { invite in
                                        pendingInviteRow(invite)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Account Actions
                    cardSection {
                        Section(header: sectionHeader("Account Actions")) {
                            VStack(spacing: 16) {
                                Button(action: { authService.signOut() }) {
                                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                        .background(PickleGoTheme.primaryGreen)
                                        .cornerRadius(PickleGoTheme.cornerRadius)
                                        .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                                }
                                
                                Button(action: { /* TODO: Implement account deletion */ }) {
                                    Text("Delete Account")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 32)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(authService: authService)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAddContact) {
            AddPlayerView { playerId in
                // Handle player added
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func contactRow(_ contact: Player) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(PickleGoTheme.dark)
                
                if let rating = contact.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: { /* TODO: Implement contact removal */ }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func pendingInviteRow(_ invite: Player) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(invite.name)
                    .font(.headline)
                    .foregroundColor(PickleGoTheme.dark)
                
                Text("Invite sent")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { /* TODO: Implement invite cancellation */ }) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    @State private var displayName: String
    @State private var rating: Double
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(authService: AuthenticationService) {
        let initialDisplayName = authService.currentUser?.displayName ?? authService.currentUser?.username ?? ""
        let initialRating = authService.currentUser?.rating ?? 3.0
        
        _displayName = State(initialValue: initialDisplayName)
        _rating = State(initialValue: initialRating)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo Section
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let user = authService.currentUser,
                                      let photoURL = user.photoURL {
                                AsyncImage(url: URL(string: photoURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                            }
                        }
                        
                        Text("Tap to change photo")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Profile Information Section
                    VStack(spacing: 16) {
                        TextField("Display Name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.words)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rating")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Slider(value: $rating, in: 1...5, step: 0.1)
                                Text(String(format: "%.1f", rating))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 40)
                            }
                        }
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: saveProfile) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PickleGoTheme.primaryGreen)
                                .cornerRadius(PickleGoTheme.cornerRadius)
                                .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                        }
                        .disabled(displayName.isEmpty)
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.subheadline)
                                .foregroundColor(PickleGoTheme.primaryGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .padding()
            }
            .background(PickleGoTheme.background.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        guard !displayName.isEmpty else {
            errorMessage = "Display name cannot be empty"
            showingError = true
            return
        }
        
        Task {
            do {
                try await authService.updateProfile(
                    displayName: displayName,
                    rating: rating,
                    photo: selectedImage
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

private func cardSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 0) {
        content()
    }
    .padding()
    .background(PickleGoTheme.card)
    .cornerRadius(PickleGoTheme.cornerRadius)
    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
    .padding(.vertical, 6)
}

private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.title3).bold()
        .foregroundColor(PickleGoTheme.primaryGreen)
        .padding(.bottom, 4)
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
        .environmentObject(PlayerStore())
} 