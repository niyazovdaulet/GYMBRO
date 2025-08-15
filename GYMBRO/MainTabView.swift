import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SocialView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }
                .tag(1)
            
            WorkoutTabView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workout")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
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

// MARK: - Placeholder Views for Other Tabs
struct SocialView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.undergroundAccent)
                    .undergroundGlow()
                
                Text("Social")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.undergroundText)
                
                Text("Coming Soon...")
                    .font(.subheadline)
                    .foregroundColor(Color.undergroundTextSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .background(Color.undergroundPrimary)
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WorkoutTabView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        WorkoutView(userId: authService.userId ?? "unknown")
    }
}

struct StatsView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @StateObject private var viewModel: StatsViewModel
    
    init() {
        // We'll initialize with a placeholder and update in onAppear
        self._viewModel = StateObject(wrappedValue: StatsViewModel(userId: "placeholder"))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Overview Cards
                    overviewSection
                    
                    // Workout Streak
                    streakSection
                    
                    // Progress Charts
                    progressSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                if let userId = authService.userId {
                    viewModel.userId = userId
                    Task {
                        await viewModel.loadStats()
                    }
                }
            }
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatsCard(
                    title: "Total Workouts",
                    value: "\(viewModel.totalWorkouts)",
                    icon: "dumbbell.fill",
                    color: Color.undergroundAccent
                )
                
                StatsCard(
                    title: "Total Time",
                    value: viewModel.formatDuration(viewModel.totalWorkoutTime),
                    icon: "clock.fill",
                    color: Color.undergroundAccentSecondary
                )
                
                StatsCard(
                    title: "Total Sets",
                    value: "\(viewModel.totalSets)",
                    icon: "repeat.circle.fill",
                    color: Color.undergroundAccentTertiary
                )
                
                StatsCard(
                    title: "Total Weight",
                    value: "\(Int(viewModel.totalWeight)) lbs",
                    icon: "scalemass.fill",
                    color: Color.undergroundAccent
                )
            }
        }
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        VStack(spacing: 16) {
            Text("Workout Streak")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundAccentSecondary)
                        .undergroundGlow(color: Color.undergroundAccentSecondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.workoutStreak)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.undergroundText)
                        
                        Text("day\(viewModel.workoutStreak != 1 ? "s" : "") streak")
                            .font(.subheadline)
                            .foregroundColor(Color.undergroundTextSecondary)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(viewModel.workoutsThisWeek)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.undergroundAccent)
                        
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(Color.undergroundTextSecondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(viewModel.workoutsThisMonth)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.undergroundAccentTertiary)
                        
                        Text("This Month")
                            .font(.caption)
                            .foregroundColor(Color.undergroundTextSecondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(20)
            .background(Color.undergroundCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 16) {
            Text("Progress (Last 30 Days)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !viewModel.progressData.isEmpty {
                ProgressChartView(data: viewModel.progressData)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("No progress data yet")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("Complete more workouts to see your progress!")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .background(Color.undergroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.undergroundBorder, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.workoutSessions.prefix(5)) { session in
                    RecentWorkoutCard(session: session)
                }
            }
            
            if viewModel.workoutSessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("No workouts yet")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("Start your first workout to see activity here!")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .background(Color.undergroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.undergroundBorder, lineWidth: 1)
                )
            }
        }
    }
}

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

// MARK: - Stats Components

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color.undergroundTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

struct ProgressChartView: View {
    let data: [ProgressDataPoint]
    
    var body: some View {
        VStack(spacing: 16) {
            // Simple line chart representation
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(data.suffix(14)) { point in
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.undergroundAccent)
                            .frame(width: 20, height: max(4, CGFloat(point.totalVolume / maxVolume) * 80))
                            .cornerRadius(2)
                        
                        Text(DateFormatter.dayFormatter.string(from: point.date))
                            .font(.caption2)
                            .foregroundColor(Color.undergroundTextMuted)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
            .frame(height: 120)
            .padding(.horizontal)
            
            Text("Training Volume (Weight × Reps)")
                .font(.caption)
                .foregroundColor(Color.undergroundTextSecondary)
        }
        .padding(20)
        .background(Color.undergroundCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
    
    private var maxVolume: Double {
        data.map { $0.totalVolume }.max() ?? 1
    }
}

struct RecentWorkoutCard: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(DateFormatter.monthDayFormatter.string(from: session.startTime))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.undergroundAccent)
                
                Text(DateFormatter.timeFormatter.string(from: session.startTime))
                    .font(.caption2)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.undergroundText)
                
                Text("\(session.exercises.count) exercises • \(getTotalSets(for: session)) sets")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let duration = session.totalDuration {
                    Text(formatDuration(duration))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.undergroundAccent)
                }
                
                Text("\(Int(getTotalWeight(for: session))) lbs")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
        }
        .padding(16)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
    
    private func getTotalSets(for session: WorkoutSession) -> Int {
        return session.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    private func getTotalWeight(for session: WorkoutSession) -> Double {
        return session.exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0) }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Date Formatters Extension
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    MainTabView()
        .environmentObject(FirebaseAuthService())
} 
