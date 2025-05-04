import SwiftUI

struct PickleGoLogoHeader: View {
    var subtitle: String? = nil
    var body: some View {
        VStack(spacing: 8) {
            Image("PickleGoLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .shadow(color: PickleGoTheme.shadow, radius: 8, y: 4)
            Text("PickleGo")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(PickleGoTheme.primaryGreen)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.headline)
                    .foregroundColor(PickleGoTheme.dark.opacity(0.7))
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

#Preview {
    PickleGoLogoHeader(subtitle: "Schedule your next match!")
} 