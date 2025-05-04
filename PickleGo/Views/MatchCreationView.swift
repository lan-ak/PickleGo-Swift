import SwiftUI
import MapKit
import Contacts
import ContactsUI

struct Team {
    var players: [String]
    var isTeamOne: Bool
    
    var isComplete: Bool {
        !players.contains("")
    }
    
    var displayName: String {
        isTeamOne ? "Team 1" : "Team 2"
    }
}

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
    @State private var newPlayerName = ""
    
    @State private var date: Date
    @State private var location: String
    @State private var locationCoordinate: CLLocationCoordinate2D?
    @State private var matchType: Match.MatchType
    @State private var pointsToWin: Int
    @State private var numberOfSets: Int
    @State private var notes: String?
    @State private var isPublicFacility: Bool
    @State private var partnerSelection: Match.PartnerSelection
    
    @State private var showingPlayerPicker = false
    @State private var isSelectingPartner = true
    @State private var selectedPartner: String?
    @State private var selectedOpponents: [String] = []
    
    private let existingMatch: Match?
    
    init(match: Match? = nil) {
        if let match = match {
            self.existingMatch = match
            _date = State(initialValue: match.date)
            _location = State(initialValue: match.location)
            _locationCoordinate = State(initialValue: match.locationCoordinate)
            _matchType = State(initialValue: match.matchType)
            _pointsToWin = State(initialValue: match.pointsToWin)
            _numberOfSets = State(initialValue: match.numberOfSets)
            _notes = State(initialValue: match.notes)
            _isPublicFacility = State(initialValue: match.isPublicFacility)
            _partnerSelection = State(initialValue: match.partnerSelection)
            
            if let currentUserId = AuthenticationService().currentUser?.id {
                if match.matchType == .singles {
                    _selectedOpponents = State(initialValue: match.players.filter { $0 != currentUserId })
                } else {
                    let team1 = match.players.prefix(2)
                    let team2 = match.players.suffix(2)
                    if team1.contains(currentUserId) {
                        _selectedPartner = State(initialValue: team1.first { $0 != currentUserId })
                        _selectedOpponents = State(initialValue: Array(team2))
                    } else {
                        _selectedPartner = State(initialValue: team2.first { $0 != currentUserId })
                        _selectedOpponents = State(initialValue: Array(team1))
                    }
                }
            }
        } else {
            self.existingMatch = nil
            _date = State(initialValue: Date())
            _location = State(initialValue: "")
            _locationCoordinate = State(initialValue: nil)
            _matchType = State(initialValue: .singles)
            _pointsToWin = State(initialValue: 11)
            _numberOfSets = State(initialValue: 3)
            _notes = State(initialValue: nil)
            _isPublicFacility = State(initialValue: false)
            _partnerSelection = State(initialValue: .fixed)
        }
    }
    
    private var playerCount: Int {
        matchType == .singles ? 2 : 4
    }
    
    private var currentUserId: String? {
        authService.currentUser?.id
    }
    
    private var matchTypeSection: some View {
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
    }
    
    private var dateTimeSection: some View {
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
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Location")
                    .font(.title3)
                    .bold()
                    .foregroundColor(PickleGoTheme.primaryGreen)
                Text("(Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Button(action: { showingLocationSearch = true }) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(PickleGoTheme.primaryGreen)
                    Text(location.isEmpty ? "Add Location" : location)
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
    }
    
    private var matchSettingsSection: some View {
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
                            ForEach([9, 11, 15], id: \.self) { points in
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
    }
    
    private func playersSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Players")
                .font(.headline)
                .foregroundColor(PickleGoTheme.primaryGreen)
            
            if matchType == .singles {
                // Singles selection
                VStack(alignment: .leading, spacing: 8) {
                    // Current User
                    if let currentUser = authService.currentUser {
                        HStack(spacing: 4) {
                            Text("You")
                                .font(.headline)
                                .foregroundColor(PickleGoTheme.primaryGreen)
                            Spacer()
                            HStack(spacing: 4) {
                                Text(currentUser.username)
                                    .font(.subheadline)
                                Image(systemName: "person.fill")
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(PickleGoTheme.card)
                            .cornerRadius(8)
                        }
                    }
                    
                    // VS Separator
                    Text("vs")
                        .font(.title3)
                        .bold()
                        .foregroundColor(PickleGoTheme.dark.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Opponent
                    if selectedOpponents.isEmpty {
                        Button(action: {
                            showingPlayerPicker = true
                            isSelectingPartner = false
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Select Opponent")
                            }
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        }
                    } else if let opponentId = selectedOpponents.first,
                              let opponent = playerStore.players.first(where: { $0.id == opponentId }) {
                        HStack(spacing: 4) {
                            Text(opponent.name)
                                .font(.subheadline)
                            Button(action: {
                                selectedOpponents.removeAll()
                            }) {
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
            } else {
                // Doubles selection
                VStack(alignment: .leading, spacing: 16) {
                    if partnerSelection == .rotating {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rotating Partners Mode")
                                .font(.headline)
                                .foregroundColor(PickleGoTheme.primaryGreen)
                            Text("Select your starting teams. Players will be mixed after the first game")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(PickleGoTheme.card)
                        .cornerRadius(8)
                    }
                    
                    // Your Team (Auth User + Partner)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Team")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        
                        HStack {
                            // Current User
                            if let currentUser = authService.currentUser {
                                HStack(spacing: 4) {
                                    Text(currentUser.username)
                                        .font(.subheadline)
                                    Image(systemName: "person.fill")
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(PickleGoTheme.card)
                                .cornerRadius(8)
                            }
                            
                            // Partner
                            if let partnerId = selectedPartner,
                               let partner = playerStore.players.first(where: { $0.id == partnerId }) {
                                HStack(spacing: 4) {
                                    Text(partner.name)
                                        .font(.subheadline)
                                    Button(action: {
                                        selectedPartner = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(PickleGoTheme.card)
                                .cornerRadius(8)
                            } else {
                                Button(action: {
                                    showingPlayerPicker = true
                                    isSelectingPartner = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Select Partner")
                                    }
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                            }
                        }
                    }
                    
                    // Opponents
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opponents")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.accentYellow)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(selectedOpponents, id: \.self) { playerId in
                                if let player = playerStore.players.first(where: { $0.id == playerId }) {
                                    HStack(spacing: 4) {
                                        Text(player.name)
                                            .font(.subheadline)
                                        Button(action: {
                                            selectedOpponents.removeAll { $0 == playerId }
                                        }) {
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
                            
                            if selectedOpponents.count < 2 {
                                Button(action: {
                                    showingPlayerPicker = true
                                    isSelectingPartner = false
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text(selectedOpponents.isEmpty ? "Select Opponents" : "Select Second Opponent")
                                    }
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingPlayerPicker) {
            PlayerPickerView(
                matchType: matchType,
                partnerSelection: partnerSelection,
                isSelectingPartner: isSelectingPartner,
                onPlayersSelected: { players in
                    if isSelectingPartner {
                        selectedPartner = players.first
                    } else {
                        selectedOpponents = players
                    }
                },
                selectedOpponents: selectedOpponents,
                selectedPartner: selectedPartner
            )
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                matchTypeSection
                dateTimeSection
                locationSection
                matchSettingsSection
                playersSection()
                notesSection
                createButton
            }
            .padding()
        }
    }
    
    private var notesSection: some View {
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
    }
    
    private var createButton: some View {
        Button(action: createMatch) {
            Label(existingMatch != nil ? "Save" : "Create Match", systemImage: "checkmark.circle")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(PickleGoTheme.primaryGreen)
                .cornerRadius(PickleGoTheme.cornerRadius)
        }
        .disabled(!isValid)
    }
    
    private var isValid: Bool {
        if matchType == .singles {
            return selectedOpponents.count == 1
        } else {
            return selectedPartner != nil && selectedOpponents.count == 2
        }
    }
    
    var body: some View {
        NavigationStack {
            mainContent
                .background(PickleGoTheme.background)
                .navigationTitle("Create a new match")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingLocationSearch) {
                    LocationPickerView(location: $location, coordinate: $locationCoordinate)
                }
                .alert("Error", isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
        }
    }
    
    private func createMatch() {
        guard isValid else {
            errorMessage = "Please select all players"
            showingError = true
            return
        }
        
        Task {
            do {
                var finalPlayers: [String] = []
                if matchType == .singles {
                    if let currentUserId = currentUserId {
                        finalPlayers = [currentUserId] + selectedOpponents
                    }
                } else {
                    if let currentUserId = currentUserId, let partner = selectedPartner {
                        finalPlayers = [currentUserId, partner] + selectedOpponents
                    }
                }
                
                guard !finalPlayers.isEmpty else {
                    errorMessage = "Please select all players"
                    showingError = true
                    return
                }
                
                if let existingMatch = existingMatch {
                    let updatedMatch = Match(
                        id: existingMatch.id,
                        date: date,
                        location: location,
                        locationCoordinate: locationCoordinate,
                        matchType: matchType,
                        pointsToWin: pointsToWin,
                        numberOfSets: numberOfSets,
                        players: finalPlayers,
                        scores: existingMatch.scores,
                        status: existingMatch.status,
                        notes: notes,
                        isPublicFacility: isPublicFacility,
                        partnerSelection: partnerSelection
                    )
                    try await matchViewModel.updateMatch(updatedMatch)
                } else {
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
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
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

struct ContactsPicker: UIViewControllerRepresentable {
    let onContactSelected: (CNContact) -> Void
    
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
            parent.onContactSelected(contact)
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
