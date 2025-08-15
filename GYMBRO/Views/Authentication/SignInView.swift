import SwiftUI

struct SignInView: View {
    @StateObject private var authService = FirebaseAuthService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 60))
                            .foregroundColor(Color.undergroundAccent)
                            .frame(width: 80, height: 80)
                            .background(Color.undergroundAccent.opacity(0.2))
                            .clipShape(Circle())
                            .undergroundGlow()
                        
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.undergroundText)
                            
                            Text("Sign in to continue your fitness journey")
                                .font(.subheadline)
                                .foregroundColor(Color.undergroundTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 20) {
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
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Forgot password link
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showingForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.undergroundAccent)
                        }
                        
                        // Error message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(Color.undergroundAccentSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Sign in button
                        Button(action: signIn) {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.undergroundPrimary))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
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
                        
                        // Sign up link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(Color.undergroundTextSecondary)
                            
                            Button("Sign Up") {
                                showingSignUp = true
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
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .alert("Reset Password", isPresented: $showingForgotPassword) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Button("Cancel", role: .cancel) { }
                Button("Send Reset Link") {
                    resetPassword()
                }
            } message: {
                Text("Enter your email address and we'll send you a password reset link.")
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && authService.isValidEmail(email)
    }
    
    // MARK: - Methods
    private func signIn() {
        Task {
            let success = await authService.signIn(email: email, password: password)
            
            if success {
                dismiss()
            }
        }
    }
    
    private func resetPassword() {
        Task {
            let success = await authService.resetPassword(email: email)
            
            if success {
                // Show success message
                print("Password reset email sent")
            }
        }
    }
}

#Preview {
    SignInView()
} 