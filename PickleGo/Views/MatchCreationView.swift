import SwiftUI
import MapKit
import Contacts
import ContactsUI

struct MatchCreationView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var playerStore: PlayerStore
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingLocationSearch = false
    @State private var showingPlayerSelection = false
    @State private var selectedTeam: Int? = nil
    @State private var showingAddNotes = false
    @State private var showingCustomPoints = false
    @State private var customPoints = ""
    
    @State private var date = Date()
    @State private var location = ""
    @State private var locationCoordinate: CLLocationCoordinate2D? = nil
    @State private var matchType: Match.MatchType = .singles
    @State private var pointsToWin = 11
    @State private var numberOfSets = 3
    @State private var players: [String] = []
    @State private var notes: String? = nil
    @State private var isPublicFacility = false
    @State private var partnerSelection: Match.PartnerSelection = .fixed
    
    private var playerCount: Int {
        matchType == .singles ? 2 : 4
    }
    
    private var currentUserId: String? {
        authService.currentUser?.id
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Match Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Match Type")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        Picker("Match Type", selection: $matchType) {
                            Text("Singles").tag(Match.MatchType.singles)
                            Text("Doubles").tag(Match.MatchType.doubles)
                        }
                        .pickerStyle(.segmented)
                        
                        if matchType == .doubles {
                            Picker("Partner Selection", selection: $partnerSelection) {
                                ForEach(Match.PartnerSelection.allCases, id: \.self) { selection in
                                    Text(selection.rawValue).tag(selection)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 8)
                        }
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Date and Time Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date & Time")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .tint(PickleGoTheme.primaryGreen)
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Location Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        Button(action: { showingLocationSearch = true }) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                Text(location.isEmpty ? "Select Location" : location)
                                    .foregroundColor(location.isEmpty ? .secondary : PickleGoTheme.dark)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(PickleGoTheme.background)
                            .cornerRadius(12)
                        }
                        
                        Toggle("Public Facility", isOn: $isPublicFacility)
                            .tint(PickleGoTheme.primaryGreen)
                            .padding(.top, 8)
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Match Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Match Settings")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Points to Win")
                                    .font(.headline)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    Picker("Points to Win", selection: $pointsToWin) {
                                        ForEach([9, 11, 15, 21], id: \.self) { points in
                                            Text("\(points)").tag(points)
                                        }
                                        Text("Other").tag(-1)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 200)
                                    .onChange(of: pointsToWin) { oldValue, newValue in
                                        if newValue == -1 {
                                            showingCustomPoints = true
                                        }
                                    }
                                    
                                    if pointsToWin == -1 {
                                        TextField("Enter points", text: $customPoints)
                                            .keyboardType(.numberPad)
                                            .frame(width: 200)
                                            .textFieldStyle(.roundedBorder)
                                            .onChange(of: customPoints) { oldValue, newValue in
                                                if let points = Int(newValue), points > 0 {
                                                    pointsToWin = points
                                                }
                                            }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Number of Sets")
                                    .font(.headline)
                                Spacer()
                                Picker("Number of Sets", selection: $numberOfSets) {
                                    ForEach([1, 3, 5], id: \.self) { sets in
                                        Text("\(sets)").tag(sets)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 200)
                            }
                        }
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Players Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Players")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        
                        if matchType == .doubles && partnerSelection == .rotating {
                            // Rotating partners - single selection
                            Button(action: { 
                                selectedTeam = nil
                                showingPlayerSelection = true 
                            }) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                    Text(players.isEmpty ? "Select Players" : "\(players.count)/4 Players Selected")
                                        .foregroundColor(players.isEmpty ? .secondary : PickleGoTheme.dark)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(PickleGoTheme.background)
                                .cornerRadius(12)
                            }
                        } else {
                            // Fixed partners or singles - team selection
                            VStack(spacing: 16) {
                                // Team 1
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Team 1")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        ForEach(0..<playerCount/2, id: \.self) { index in
                                            let playerIndex = index
                                            let playerName = playerIndex < players.count ? playerStore.displayName(for: players[playerIndex]) : "Select Player"
                                            
                                            Text(playerName)
                                                .font(.headline)
                                                .foregroundColor(playerName == "Select Player" ? .secondary : PickleGoTheme.dark)
                                            
                                            if index < (playerCount/2 - 1) {
                                                Text("&")
                                                    .font(.headline)
                                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(PickleGoTheme.background)
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        selectedTeam = 1
                                        showingPlayerSelection = true
                                    }
                                }
                                
                                Text("vs")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                // Team 2
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Team 2")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        ForEach(0..<playerCount/2, id: \.self) { index in
                                            let playerIndex = (playerCount/2) + index
                                            let playerName = playerIndex < players.count ? playerStore.displayName(for: players[playerIndex]) : "Select Player"
                                            
                                            Text(playerName)
                                                .font(.headline)
                                                .foregroundColor(playerName == "Select Player" ? .secondary : PickleGoTheme.dark)
                                            
                                            if index < (playerCount/2 - 1) {
                                                Text("&")
                                                    .font(.headline)
                                                    .foregroundColor(PickleGoTheme.accentYellow)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(PickleGoTheme.background)
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        selectedTeam = 2
                                        showingPlayerSelection = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Notes")
                                .font(.title3)
                                .bold()
                                .foregroundColor(PickleGoTheme.primaryGreen)
                            Spacer()
                            Button(action: { showingAddNotes.toggle() }) {
                                Image(systemName: showingAddNotes ? "minus.circle.fill" : "plus.circle.fill")
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                            }
                        }
                        
                        if showingAddNotes {
                            TextEditor(text: Binding(
                                get: { notes ?? "" },
                                set: { notes = $0.isEmpty ? nil : $0 }
                            ))
                            .frame(height: 100)
                            .padding(8)
                            .background(PickleGoTheme.background)
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Create Button
                    Button(action: { createMatch() }) {
                        Text("Create Match")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PickleGoTheme.primaryGreen)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding()
            }
            .background(PickleGoTheme.background)
            .navigationTitle("Create a new match")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .sheet(isPresented: $showingLocationSearch) {
                LocationPickerView(location: $location, coordinate: $locationCoordinate)
            }
            .sheet(isPresented: $showingPlayerSelection) {
                PlayerPickerView(
                    selectedPlayers: $players,
                    team: selectedTeam ?? 1,
                    matchType: matchType,
                    partnerSelection: partnerSelection,
                    currentUserId: currentUserId
                )
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Automatically add the current user to the players array
                if let currentUserId = currentUserId, !players.contains(currentUserId) {
                    players.append(currentUserId)
                }
            }
        }
    }
    
    private func createMatch() {
        guard !location.isEmpty else {
            errorMessage = "Please select a location"
            showingError = true
            return
        }
        
        guard players.count == playerCount else {
            errorMessage = "Please select all players"
            showingError = true
            return
        }
        
        Task {
            do {
                var finalPlayers = players
                
                // If doubles and rotating partners, shuffle the teams
                if matchType == .doubles && partnerSelection == .rotating {
                    finalPlayers = rotatePartners(players)
                }
                
                try await matchViewModel.createMatch(
                    date: date,
                    location: location,
                    locationCoordinate: locationCoordinate,
                    matchType: matchType,
                    pointsToWin: pointsToWin,
                    numberOfSets: numberOfSets,
                    players: finalPlayers,
                    notes: notes,
                    isPublicFacility: isPublicFacility,
                    partnerSelection: partnerSelection
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func rotatePartners(_ players: [String]) -> [String] {
        // Ensure we have exactly 4 players for doubles
        guard players.count == 4 else { return players }
        
        // Create a mutable copy of the players array
        var shuffledPlayers = players
        
        // Shuffle the players
        shuffledPlayers.shuffle()
        
        // Ensure we don't have the same teams as before
        while (shuffledPlayers[0] == players[0] && shuffledPlayers[1] == players[1]) ||
              (shuffledPlayers[2] == players[2] && shuffledPlayers[3] == players[3]) {
            shuffledPlayers.shuffle()
        }
        
        return shuffledPlayers
    }
}

struct LocationPickerView: View {
    @Binding var location: String
    @Binding var coordinate: CLLocationCoordinate2D?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                Map {
                    if let coordinate = coordinate {
                        Marker("Selected Location", coordinate: coordinate)
                    }
                }
                .frame(height: 300)
                
                List(searchResults, id: \.self) { item in
                    Button(action: {
                        selectLocation(item)
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(item.name ?? "")
                            Text(item.placemark.title ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search locations")
            .navigationTitle("Select Location")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .onChange(of: searchText) { oldValue, newValue in
                searchLocations(newValue)
            }
        }
    }
    
    private func searchLocations(_ query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                searchResults = response.mapItems
            }
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        location = item.name ?? ""
        coordinate = item.placemark.coordinate
        searchResults = []
        searchText = ""
    }
}

struct PlayerPickerView: View {
    @Binding var selectedPlayers: [String]
    let team: Int
    let matchType: Match.MatchType
    let partnerSelection: Match.PartnerSelection
    let currentUserId: String?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerStore: PlayerStore
    @State private var searchText = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingNewPlayerSheet = false
    @State private var showingContactsPicker = false
    @State private var newPlayerName = ""
    @State private var newPlayerPhone = ""
    
    private var maxPlayers: Int {
        matchType == .singles ? 2 : 4
    }
    
    private var teamPlayers: [String] {
        if partnerSelection == .rotating {
            return selectedPlayers
        }
        let teamSize = maxPlayers / 2
        let startIndex = (team - 1) * teamSize
        let endIndex = min(startIndex + teamSize, selectedPlayers.count)
        return Array(selectedPlayers[startIndex..<endIndex])
    }
    
    private var availablePlayers: [String] {
        var result: [String] = []
        let selectedSet = Set(selectedPlayers)
        
        // Always include the current user if not already selected
        if let currentUserId = currentUserId, !selectedSet.contains(currentUserId) {
            result.append(currentUserId)
        }
        
        for player in playerStore.players {
            if !selectedSet.contains(player.id) && player.id != currentUserId {
                result.append(player.id)
            }
        }
        
        return result
    }
    
    private func addNewPlayer() {
        guard !newPlayerName.isEmpty else {
            errorMessage = "Please enter a name"
            showingError = true
            return
        }
        
        guard !newPlayerPhone.isEmpty else {
            errorMessage = "Please enter a phone number"
            showingError = true
            return
        }
        
        // Create a new player
        let newPlayer = Player(
            id: UUID().uuidString,
            name: newPlayerName,
            email: nil,
            phoneNumber: newPlayerPhone,
            isRegistered: false,
            isInvited: true,
            skillLevel: .beginner,
            profileImageURL: nil
        )
        
        // Add the new player to the player store
        playerStore.addIfNeeded(newPlayer)
        
        // Add the new player to the selected players if there's room
        if partnerSelection == .rotating {
            if selectedPlayers.count < maxPlayers {
                selectedPlayers.append(newPlayer.id)
            }
        } else {
            if teamPlayers.count < maxPlayers/2 {
                let insertIndex = (team - 1) * (maxPlayers/2) + teamPlayers.count
                if insertIndex <= selectedPlayers.count {
                    selectedPlayers.insert(newPlayer.id, at: insertIndex)
                } else {
                    selectedPlayers.append(newPlayer.id)
                }
            }
        }
        
        showingNewPlayerSheet = false
        newPlayerName = ""
        newPlayerPhone = ""
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Selected Players Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(partnerSelection == .rotating ? 
                            "Selected Players (\(teamPlayers.count)/\(maxPlayers))" :
                            "Selected Players (\(teamPlayers.count)/\(maxPlayers/2))")
                            .font(.title3)
                            .bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        
                        ForEach(teamPlayers, id: \.self) { playerId in
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(playerId == currentUserId ? PickleGoTheme.primaryGreen : PickleGoTheme.dark)
                                Text(playerStore.displayName(for: playerId))
                                    .font(.headline)
                                    .foregroundColor(PickleGoTheme.dark)
                                if playerId == currentUserId {
                                    Text("(You)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    if let index = selectedPlayers.firstIndex(of: playerId) {
                                        selectedPlayers.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(PickleGoTheme.background)
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Available Players Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Available Players")
                                .font(.title3)
                                .bold()
                                .foregroundColor(PickleGoTheme.primaryGreen)
                            Spacer()
                            HStack(spacing: 16) {
                                Button(action: { showingContactsPicker = true }) {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                                Button(action: { showingNewPlayerSheet = true }) {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                            }
                        }
                        
                        ForEach(availablePlayers, id: \.self) { playerId in
                            Button(action: {
                                if partnerSelection == .rotating {
                                    if selectedPlayers.count < maxPlayers {
                                        selectedPlayers.append(playerId)
                                    } else {
                                        errorMessage = "Maximum players selected"
                                        showingError = true
                                    }
                                } else {
                                    if teamPlayers.count < maxPlayers/2 {
                                        let insertIndex = (team - 1) * (maxPlayers/2) + teamPlayers.count
                                        if insertIndex <= selectedPlayers.count {
                                            selectedPlayers.insert(playerId, at: insertIndex)
                                        } else {
                                            selectedPlayers.append(playerId)
                                        }
                                    } else {
                                        errorMessage = "This team is full"
                                        showingError = true
                                    }
                                }
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(playerId == currentUserId ? PickleGoTheme.primaryGreen : PickleGoTheme.dark)
                                    Text(playerStore.displayName(for: playerId))
                                        .font(.headline)
                                        .foregroundColor(PickleGoTheme.dark)
                                    if playerId == currentUserId {
                                        Text("(You)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if !playerStore.isRegistered(playerId) {
                                        Text("Invite")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(PickleGoTheme.background)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(16)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                }
                .padding()
            }
            .background(PickleGoTheme.background)
            .navigationTitle(partnerSelection == .rotating ? "Select Players" : "Select Team \(team) Players")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingNewPlayerSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("New Player Details")) {
                            TextField("Name", text: $newPlayerName)
                                .textContentType(.name)
                            TextField("Phone Number", text: $newPlayerPhone)
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                        }
                    }
                    .navigationTitle("Add New Player")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        leading: Button("Cancel") { showingNewPlayerSheet = false },
                        trailing: Button("Add") {
                            addNewPlayer()
                        }
                    )
                }
            }
            .sheet(isPresented: $showingContactsPicker) {
                NavigationView {
                    ContactsPicker { contact in
                        let name = [contact.givenName, contact.familyName]
                            .compactMap { $0 }
                            .joined(separator: " ")
                        
                        if !name.isEmpty, let phone = contact.phoneNumbers.first?.value.stringValue {
                            newPlayerName = name
                            newPlayerPhone = phone
                            showingContactsPicker = false
                            showingNewPlayerSheet = true
                        }
                    }
                    .navigationTitle("Select Contact")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing: Button("Cancel") { showingContactsPicker = false })
                }
            }
        }
    }
}

struct ContactsPicker: UIViewControllerRepresentable {
    let onSelect: (CNContact) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactsPicker
        
        init(_ parent: ContactsPicker) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.onSelect(contact)
        }
    }
}

#Preview {
    Group {
        MatchCreationView()
            .environmentObject(MatchViewModel())
            .environmentObject(PlayerStore())
            .environmentObject(AuthenticationService())
    }
}
