import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = FirebaseAuthService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showingSignIn = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(Color.undergroundAccent)
                            .frame(width: 80, height: 80)
                            .background(Color.undergroundAccent.opacity(0.2))
                            .clipShape(Circle())
                            .undergroundGlow()
                        
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.undergroundText)
                            
                            Text("Join GYMBRO and start your fitness journey")
                                .font(.subheadline)
                                .foregroundColor(Color.undergroundTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Name fields
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("First Name")
                                    .font(.headline)
                                    .foregroundColor(Color.undergroundText)
                                
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Last Name")
                                    .font(.headline)
                                    .foregroundColor(Color.undergroundText)
                                
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Password fields
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Error message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(Color.undergroundAccentSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Sign up button
                        Button(action: signUp) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.undergroundPrimary))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Create Account")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(Color.undergroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid ? Color.undergroundAccent : Color.undergroundTextMuted)
                            .cornerRadius(12)
                            .undergroundGlow()
                        }
                        .disabled(!isFormValid || authService.isLoading)
                        
                        // Sign in link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(Color.undergroundTextSecondary)
                            
                            Button("Sign In") {
                                showingSignIn = true
                            }
                            .foregroundColor(Color.undergroundAccent)
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.undergroundPrimary)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignIn) {
                SignInView()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        authService.isValidEmail(email) &&
        authService.isValidPassword(password) &&
        password == confirmPassword
    }
    
    // MARK: - Methods
    private func signUp() {
        Task {
            let success = await authService.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    SignUpView()
} 