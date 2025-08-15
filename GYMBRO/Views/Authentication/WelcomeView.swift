import SwiftUI

struct WelcomeView: View {
    @StateObject private var authService = FirebaseAuthService()
    @State private var showingSignIn = false
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.undergroundPrimary, Color.undergroundSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // App logo and title
                    VStack(spacing: 24) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.undergroundAccent)
                            .frame(width: 120, height: 120)
                            .background(Color.undergroundAccent.opacity(0.2))
                            .clipShape(Circle())
                            .undergroundGlow()
                        
                        VStack(spacing: 12) {
                            Text("GYMBRO")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Color.undergroundText)
                            
                            Text("Your Personal Fitness Companion")
                                .font(.title2)
                                .foregroundColor(Color.undergroundTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // Features list
                    VStack(spacing: 16) {
                        FeatureRow(icon: "figure.strengthtraining.traditional", text: "Comprehensive Exercise Library")
                        FeatureRow(icon: "person.2.fill", text: "Expert Coaches & Guidance")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track Your Progress")
                        FeatureRow(icon: "heart.fill", text: "Personalized Workouts")
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: { showingSignUp = true }) {
                            HStack {
                                Text("Get Started")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                            }
                            .foregroundColor(Color.undergroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.undergroundAccent)
                            .cornerRadius(12)
                            .undergroundGlow()
                        }
                        
                        Button(action: { showingSignIn = true }) {
                            Text("I already have an account")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.undergroundAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.undergroundCard)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.undergroundAccent, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .sheet(isPresented: $showingSignIn) {
                SignInView()
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color.undergroundAccent)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(Color.undergroundText)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
} 