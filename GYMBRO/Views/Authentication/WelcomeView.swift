import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var showingSignIn = false
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 24) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.undergroundAccent)
                        .undergroundGlow()
                    
                    VStack(spacing: 16) {
                        Text("GYMBRO")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(Color.undergroundText)
                        
                        Text("Your Personal Fitness Journey")
                            .font(.title2)
                            .foregroundColor(Color.undergroundTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Features Preview
                VStack(spacing: 20) {
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Monitor your fitness journey with detailed analytics")
                    FeatureRow(icon: "dumbbell.fill", title: "Workout Management", description: "Plan and track your workouts with ease")
                    FeatureRow(icon: "person.2.fill", title: "Body Stats", description: "Keep track of your body measurements and goals")
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingSignUp = true
                    }) {
                        Text("Get Started")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.undergroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.undergroundAccent)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingSignIn = true
                    }) {
                        Text("Sign In")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.undergroundAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.undergroundAccent, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .background(Color.undergroundPrimary)
            .sheet(isPresented: $showingSignIn) {
                SignInView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
                    .environmentObject(authService)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color.undergroundAccent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.undergroundText)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.undergroundTextSecondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(FirebaseAuthService())
} 