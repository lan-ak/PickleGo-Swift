import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = true
    @Published var currentUser: User? = User(
        id: "test@test.com",
        username: "John Doe",
        email: "test@test.com",
        profileImageURL: nil,
        friends: [],
        matches: []
    )
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    func signIn(email: String, password: String) {
        // Simulate network request
        DispatchQueue.global().async { [weak self] in
            // Simulate network delay
            Thread.sleep(forTimeInterval: 1)
            
            // Simulate successful sign in
            let mockUser = User(
                id: "test@test.com",
                username: "John Doe",
                email: "test@test.com",
                profileImageURL: nil,
                friends: [],
                matches: []
            )
            
            DispatchQueue.main.async {
                self?.isAuthenticated = true
                self?.currentUser = mockUser
                self?.error = nil
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) {
        // Simulate network request
        DispatchQueue.global().async { [weak self] in
            // Simulate network delay
            Thread.sleep(forTimeInterval: 1)
            
            // Simulate successful sign up
            let mockUser = User(
                id: "test@test.com",
                username: "John Doe",
                email: "test@test.com",
                profileImageURL: nil,
                friends: [],
                matches: []
            )
            
            DispatchQueue.main.async {
                self?.isAuthenticated = true
                self?.currentUser = mockUser
                self?.error = nil
            }
        }
    }
    
    func signOut() {
        DispatchQueue.main.async { [weak self] in
            self?.isAuthenticated = false
            self?.currentUser = nil
            self?.error = nil
        }
    }
} 