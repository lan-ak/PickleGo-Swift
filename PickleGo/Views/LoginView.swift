import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: PickleGoTheme.shadow, radius: 8, y: 4)
                    .padding(.bottom, 8)
                cardSection {
                    Section(header: sectionHeader("Sign In")) {
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(PickleGoTheme.card)
                                .cornerRadius(12)
                                .font(.body)
                            SecureField("Password", text: $password)
                                .padding()
                                .background(PickleGoTheme.card)
                                .cornerRadius(12)
                                .font(.body)
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.headline)
                                    .padding(.vertical, 4)
                            }
                            Button(action: login) {
                                Text("Sign In")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 56)
                                    .background(PickleGoTheme.primaryGreen)
                                    .cornerRadius(PickleGoTheme.cornerRadius)
                                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                            }
                        }
                    }
                }
                Button(action: { showingSignUp = true }) {
                    Text("Don't have an account? Sign Up")
                        .font(.body)
                        .foregroundColor(PickleGoTheme.primaryGreen)
                        .padding(.top, 8)
                }
                Spacer()
            }
            .padding(.horizontal)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
        .onReceive(authService.$error) { err in
            if let err = err {
                errorMessage = err.localizedDescription
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        authService.signIn(email: email, password: password)
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
    LoginView()
        .environmentObject(AuthenticationService())
} 
