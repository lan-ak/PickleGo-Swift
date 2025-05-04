import SwiftUI
import MapKit
import Contacts
import ContactsUI

struct MatchCreationView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var playerStore: PlayerStore
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
    
    private var playerCount: Int {
        matchType == .singles ? 2 : 4
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Match Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Match Type")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        Picker("Match Type", selection: $matchType) {
                            Text("Singles").tag(Match.MatchType.singles)
                            Text("Doubles").tag(Match.MatchType.doubles)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Date and Time Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date & Time")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .tint(PickleGoTheme.primaryGreen)
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Location Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.headline)
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
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Match Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Match Settings")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Points to Win")
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    Picker("Points to Win", selection: $pointsToWin) {
                                        ForEach([9, 11, 15, 21], id: \.self) { points in
                                            Text("\(points)").tag(points)
                                        }
                                        Text("Other").tag(-1)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 180)
                                    .onChange(of: pointsToWin) { oldValue, newValue in
                                        if newValue == -1 {
                                            showingCustomPoints = true
                                        }
                                    }
                                    
                                    if pointsToWin == -1 {
                                        TextField("Enter points", text: $customPoints)
                                            .keyboardType(.numberPad)
                                            .frame(width: 180)
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
                                Spacer()
                                Picker("Number of Sets", selection: $numberOfSets) {
                                    ForEach([1, 3, 5], id: \.self) { sets in
                                        Text("\(sets)").tag(sets)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 180)
                            }
                            
                            Toggle("Public Facility", isOn: $isPublicFacility)
                                .tint(PickleGoTheme.primaryGreen)
                        }
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Players Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Players")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        
                        VStack(spacing: 16) {
                            // Team 1
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Team 1")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                ForEach(0..<playerCount/2, id: \.self) { index in
                                    playerButton(team: 1, index: index)
                                }
                            }
                            
                            Divider()
                            
                            // Team 2
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Team 2")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                ForEach(0..<playerCount/2, id: \.self) { index in
                                    playerButton(team: 2, index: index)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Notes")
                                .font(.headline)
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
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                }
                .padding()
            }
            .background(PickleGoTheme.background)
            .navigationTitle("Create a new match")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Create") { createMatch() }
            )
            .sheet(isPresented: $showingLocationSearch) {
                LocationPickerView(location: $location, coordinate: $locationCoordinate)
            }
            .sheet(isPresented: $showingPlayerSelection) {
                PlayerPickerView(selectedPlayers: $players, team: selectedTeam ?? 1, matchType: matchType)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func playerButton(team: Int, index: Int) -> some View {
        let playerIndex = (team - 1) * (playerCount/2) + index
        let playerName = playerIndex < players.count ? playerStore.displayName(for: players[playerIndex]) : "Select Player"
        
        return Button(action: {
            selectedTeam = team
            showingPlayerSelection = true
        }) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(team == 1 ? PickleGoTheme.primaryGreen : PickleGoTheme.accentYellow)
                Text(playerName)
                    .foregroundColor(playerName == "Select Player" ? .secondary : PickleGoTheme.dark)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(PickleGoTheme.background)
            .cornerRadius(8)
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
                try await matchViewModel.createMatch(
                    date: date,
                    location: location,
                    locationCoordinate: locationCoordinate,
                    matchType: matchType,
                    pointsToWin: pointsToWin,
                    numberOfSets: numberOfSets,
                    players: players,
                    notes: notes,
                    isPublicFacility: isPublicFacility
                )
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

struct PlayerPickerView: View {
    @Binding var selectedPlayers: [String]
    let team: Int
    let matchType: Match.MatchType
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var playerStore: PlayerStore
    @State private var searchText = ""
    
    private var maxPlayers: Int {
        matchType == .singles ? 2 : 4
    }
    
    private var teamPlayers: [String] {
        let teamSize = maxPlayers / 2
        let startIndex = (team - 1) * teamSize
        let endIndex = startIndex + teamSize
        return Array(selectedPlayers[startIndex..<endIndex])
    }
    
    private var availablePlayers: [String] {
        var result: [String] = []
        let selectedSet = Set(selectedPlayers)
        
        for player in playerStore.players {
            if !selectedSet.contains(player.id) {
                result.append(player.id)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            List {
                SelectedPlayersSection(
                    teamPlayers: teamPlayers,
                    selectedPlayers: $selectedPlayers,
                    maxPlayers: maxPlayers
                )
                
                AvailablePlayersSection(
                    availablePlayers: availablePlayers,
                    teamPlayers: teamPlayers,
                    selectedPlayers: $selectedPlayers,
                    team: team,
                    maxPlayers: maxPlayers
                )
            }
            .searchable(text: $searchText, prompt: "Search players")
            .navigationTitle("Select Players")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct SelectedPlayersSection: View {
    let teamPlayers: [String]
    @Binding var selectedPlayers: [String]
    let maxPlayers: Int
    @EnvironmentObject var playerStore: PlayerStore
    
    var body: some View {
        Section(header: Text("Selected Players (\(teamPlayers.count)/\(maxPlayers/2))")) {
            ForEach(teamPlayers, id: \.self) { playerId in
                HStack {
                    Text(playerStore.displayName(for: playerId))
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
            }
        }
    }
}

struct AvailablePlayersSection: View {
    let availablePlayers: [String]
    let teamPlayers: [String]
    @Binding var selectedPlayers: [String]
    let team: Int
    let maxPlayers: Int
    @EnvironmentObject var playerStore: PlayerStore
    
    var body: some View {
        Section(header: Text("Available Players")) {
            ForEach(availablePlayers, id: \.self) { playerId in
                Button(action: {
                    if teamPlayers.count < maxPlayers/2 {
                        let insertIndex = (team - 1) * (maxPlayers/2) + teamPlayers.count
                        selectedPlayers.insert(playerId, at: insertIndex)
                    }
                }) {
                    HStack {
                        Text(playerStore.displayName(for: playerId))
                        Spacer()
                        if !playerStore.isRegistered(playerId) {
                            Text("Invite")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Group {
        MatchCreationView()
            .environmentObject(MatchViewModel())
            .environmentObject(PlayerStore())
    }
}
