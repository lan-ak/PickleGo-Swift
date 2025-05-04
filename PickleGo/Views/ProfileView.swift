import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var playerStore: PlayerStore
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 28) {
                    cardSection {
                        Section(header: sectionHeader("Account")) {
                            if let user = authService.currentUser {
                                detailRow("Name", user.username)
                                detailRow("Email", user.email)
                            } else {
                                Text("Not logged in")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    cardSection {
                        Section(header: sectionHeader("Statistics")) {
                            Text("Coming soon!")
                                .foregroundColor(.secondary)
                                .font(.body)
                        }
                    }
                    cardSection {
                        Section(header: sectionHeader("Actions")) {
                            Button(action: { authService.signOut() }) {
                                Text("Sign Out")
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
                .padding(.horizontal)
                .padding(.top, 32)
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

private func detailRow(_ label: String, _ value: String) -> some View {
    HStack {
        Text(label)
            .font(.body)
            .foregroundColor(.secondary)
        Spacer()
        Text(value)
            .font(.body)
            .foregroundColor(PickleGoTheme.dark)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
        .environmentObject(PlayerStore())
} 