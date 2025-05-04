import SwiftUI

struct AddPlayerView: View {
    @EnvironmentObject var playerStore: PlayerStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingContacts = false
    let onPlayerAdded: (String) -> Void
    
    private var canAddPlayer: Bool {
        !name.isEmpty
    }
    
    private var buttonTitle: String {
        phoneNumber.isEmpty ? "Add Player" : "Add and Invite"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Form Fields
                VStack(spacing: 16) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                    
                    TextField("Phone Number (optional)", text: $phoneNumber)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    
                    if !phoneNumber.isEmpty {
                        Text("They will be invited to track their scores")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(PickleGoTheme.card)
                .cornerRadius(16)
                .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                
                // Add from Contacts Button
                Button(action: { showingContacts = true }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        Text("Add from Contacts")
                            .foregroundColor(PickleGoTheme.primaryGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                }
                
                Spacer()
                
                // Add Button
                Button(action: { addPlayer() }) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canAddPlayer ? PickleGoTheme.primaryGreen : PickleGoTheme.primaryGreen.opacity(0.5))
                        .cornerRadius(16)
                }
                .disabled(!canAddPlayer)
            }
            .padding()
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingContacts) {
                ContactsPicker { contact in
                    name = contact.givenName + " " + contact.familyName
                    if let phone = contact.phoneNumbers.first?.value.stringValue {
                        phoneNumber = phone
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addPlayer() {
        Task {
            do {
                let player = Player(
                    id: UUID().uuidString,
                    name: name,
                    email: nil,
                    phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                    isRegistered: false,
                    isInvited: !phoneNumber.isEmpty,
                    profileImageURL: nil
                )
                try await playerStore.savePlayer(player)
                onPlayerAdded(player.id)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
} 