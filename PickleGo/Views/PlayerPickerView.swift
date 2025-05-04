import SwiftUI

struct PlayerPickerView: View {
    @EnvironmentObject var playerStore: PlayerStore
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var matchViewModel: MatchViewModel
    @Environment(\.dismiss) var dismiss
    let matchType: Match.MatchType
    let partnerSelection: Match.PartnerSelection
    let isSelectingPartner: Bool
    let onPlayersSelected: ([String]) -> Void
    let selectedOpponents: [String]
    let selectedPartner: String?
    
    @State private var selectedPlayers: Set<String> = []
    @State private var showingAddPlayer = false
    @State private var searchText = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var currentUserId: String? {
        authService.currentUser?.id
    }
    
    private var availablePlayers: [Player] {
        playerStore.players.filter { player in
            // Never show current user
            if player.id == currentUserId {
                return false
            }
            
            // Filter out any selected players
            if selectedPlayers.contains(player.id) {
                return false
            }
            
            // For doubles, filter out players already selected in the match
            if matchType == .doubles {
                if isSelectingPartner {
                    // When selecting partner, filter out opponents
                    if selectedOpponents.contains(player.id) {
                        return false
                    }
                } else {
                    // When selecting opponents, filter out partner
                    if let partner = selectedPartner,
                       partner == player.id {
                        return false
                    }
                }
            }
            
            return true
        }
        .sorted { $0.name < $1.name }
    }
    
    private var filteredPlayers: [Player] {
        if searchText.isEmpty {
            return availablePlayers
        } else {
            return availablePlayers.filter { player in
                player.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var maxPlayers: Int {
        if matchType == .singles {
            return 1
        } else {
            return isSelectingPartner ? 1 : 2 // Only need to select 1 partner
        }
    }
    
    private var isSelectionValid: Bool {
        if matchType == .singles {
            return selectedPlayers.count == 1
        } else {
            if isSelectingPartner {
                // For partner selection, we only care about the selected partner (excluding current user)
                return selectedPlayers.filter { $0 != currentUserId }.count == 1
            } else {
                return selectedPlayers.count == 2
            }
        }
    }
    
    private var selectionTitle: String {
        if matchType == .singles {
            return "Select opponent"
        } else {
            if isSelectingPartner {
                return selectedPlayers.filter { $0 != currentUserId }.isEmpty ? "Select your partner" : "Partner selected"
            } else {
                return selectedPlayers.isEmpty ? "Select first opponent" : "Select second opponent"
            }
        }
    }
    
    private func onDone() {
        if isSelectionValid {
            var finalPlayers: [String] = []
            if matchType == .doubles && isSelectingPartner {
                // For partner selection, just use the selected players (current user is already included)
                finalPlayers = Array(selectedPlayers)
            } else {
                // For opponents or singles, just use selected players
                finalPlayers = Array(selectedPlayers)
            }
            onPlayersSelected(finalPlayers)
            dismiss()
        } else {
            if matchType == .doubles && isSelectingPartner {
                errorMessage = "Please select a partner to play with"
            } else if matchType == .doubles {
                errorMessage = "Please select 2 opponents"
            } else {
                errorMessage = "Please select 1 opponent"
            }
            showingError = true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search players", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                
                // Selection Title
                Text(selectionTitle)
                    .font(.headline)
                    .foregroundColor(PickleGoTheme.primaryGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Selected Players
                if !selectedPlayers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // Show selected players (excluding current user)
                                ForEach(Array(selectedPlayers.filter { $0 != currentUserId }), id: \.self) { playerId in
                                    if let player = playerStore.players.first(where: { $0.id == playerId }) {
                                        HStack(spacing: 4) {
                                            Text(player.name)
                                                .font(.subheadline)
                                            Button(action: { selectedPlayers.remove(playerId) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(PickleGoTheme.card)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Available Players
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Players")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(filteredPlayers) { player in
                                Button(action: {
                                    // For partner selection, we only care about the selected partner (excluding current user)
                                    let selectedPartners = selectedPlayers.filter { $0 != currentUserId }
                                    if selectedPartners.count < maxPlayers {
                                        selectedPlayers.insert(player.id)
                                    } else {
                                        errorMessage = "You can only select \(maxPlayers) player(s)"
                                        showingError = true
                                    }
                                }) {
                                    HStack {
                                        Text(player.name)
                                            .foregroundColor(PickleGoTheme.dark)
                                        Spacer()
                                        if selectedPlayers.contains(player.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(PickleGoTheme.primaryGreen)
                                        }
                                    }
                                    .padding()
                                    .background(PickleGoTheme.card)
                                    .cornerRadius(PickleGoTheme.cornerRadius)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: 12) {
                    Button(action: { showingAddPlayer = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add or invite player")
                        }
                        .foregroundColor(PickleGoTheme.primaryGreen)
                    }
                    .padding(.bottom, 8)
                    
                    HStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(PickleGoTheme.primaryGreen)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PickleGoTheme.background)
                                .cornerRadius(16)
                        }
                        
                        Button(action: onDone) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PickleGoTheme.primaryGreen)
                                .cornerRadius(16)
                        }
                        .disabled(!isSelectionValid)
                    }
                }
                .padding()
                .background(PickleGoTheme.background)
            }
            .navigationTitle(isSelectingPartner ? "Select Partner" : "Select Opponents")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView { playerId in
                    // Auto-select the newly added player
                    selectedPlayers.insert(playerId)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Always start with empty selection
                selectedPlayers = []
            }
        }
    }
} 
