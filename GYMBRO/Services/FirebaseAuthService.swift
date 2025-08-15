import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class FirebaseAuthService: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Properties
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    init() {
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - User Properties
    var userFirstName: String {
        guard let user = currentUser else { return "Guest" }
        
        // Try to get display name first
        if let displayName = user.displayName, !displayName.isEmpty {
            return displayName.components(separatedBy: " ").first ?? "User"
        }
        
        // Fallback to email
        if let email = user.email {
            return email.components(separatedBy: "@").first ?? "User"
        }
        
        return "User"
    }
    
    var userEmail: String? {
        currentUser?.email
    }
    
    var userId: String? {
        currentUser?.uid
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up with email and password
    func signUp(email: String, password: String, firstName: String, lastName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = "\(firstName) \(lastName)"
            try await changeRequest.commitChanges()
            
            // Save user data to Firestore
            try await saveUserData(userId: result.user.uid, firstName: firstName, lastName: lastName, email: email)
            
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            errorMessage = getAuthErrorMessage(error)
            return false
        }
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            errorMessage = getAuthErrorMessage(error)
            return false
        }
    }
    
    /// Sign out
    func signOut() {
        do {
            try auth.signOut()
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    /// Reset password
    func resetPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            errorMessage = getAuthErrorMessage(error)
            return false
        }
    }
    
    /// Delete account
    func deleteAccount() async -> Bool {
        guard let user = currentUser else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete user data from Firestore
            try await deleteUserData(userId: user.uid)
            
            // Delete Firebase Auth account
            try await user.delete()
            
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            errorMessage = getAuthErrorMessage(error)
            return false
        }
    }
    
    // MARK: - Firestore Methods
    
    /// Save user data to Firestore
    private func saveUserData(userId: String, firstName: String, lastName: String, email: String) async throws {
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(userId).setData(userData)
    }
    
    /// Update user's last login time
    func updateLastLogin() async {
        guard let userId = userId else { return }
        
        do {
            try await db.collection("users").document(userId).updateData([
                "lastLoginAt": FieldValue.serverTimestamp()
            ])
        } catch {
            print("Failed to update last login: \(error)")
        }
    }
    
    /// Delete user data from Firestore
    private func deleteUserData(userId: String) async throws {
        try await db.collection("users").document(userId).delete()
    }
    
    // MARK: - Helper Methods
    
    /// Get user-friendly error messages
    private func getAuthErrorMessage(_ error: Error) -> String {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse:
                return "An account with this email already exists."
            case .invalidEmail:
                return "Please enter a valid email address."
            case .weakPassword:
                return "Password should be at least 6 characters long."
            case .wrongPassword:
                return "Incorrect password. Please try again."
            case .userNotFound:
                return "No account found with this email address."
            case .tooManyRequests:
                return "Too many failed attempts. Please try again later."
            default:
                return "Authentication failed. Please try again."
            }
        }
        return error.localizedDescription
    }
    
    /// Check if email is valid
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Check if password is strong enough
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
} 