import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 2 // Start with Welcome tab as it's the initial view
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            BodyStatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(1)
            
            WelcomeTabView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Welcome")
                }
                .tag(2)
            
            WorkoutTabView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workout")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(Color.undergroundAccent)
        .background(Color.undergroundPrimary)
    }
}

struct WorkoutTabView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        WorkoutView(userId: authService.userId ?? "unknown")
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.undergroundAccent)
                            .frame(width: 100, height: 100)
                            .background(Color.undergroundAccent.opacity(0.2))
                            .clipShape(Circle())
                            .undergroundGlow()
                        
                        VStack(spacing: 8) {
                            Text(authService.userFirstName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.undergroundText)
                            
                            if let email = authService.userEmail {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(Color.undergroundTextSecondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Profile options
                    VStack(spacing: 16) {
                        ProfileOptionRow(
                            icon: "person.fill",
                            title: "Edit Profile",
                            action: { /* TODO: Implement edit profile */ }
                        )
                        
                        ProfileOptionRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            action: { /* TODO: Implement notifications */ }
                        )
                        
                        ProfileOptionRow(
                            icon: "gear",
                            title: "Settings",
                            action: { /* TODO: Implement settings */ }
                        )
                        
                        ProfileOptionRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            action: { /* TODO: Implement help */ }
                        )
                        
                        Divider()
                            .padding(.vertical, 8)
                            .background(Color.undergroundDivider)
                        
                        ProfileOptionRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Sign Out",
                            action: { showingSignOutAlert = true }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// MARK: - Profile Option Row Component
struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color.undergroundAccent)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(Color.undergroundText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.undergroundCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
        .environmentObject(FirebaseAuthService())
} 
