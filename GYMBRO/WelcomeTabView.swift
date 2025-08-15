import SwiftUI

struct WelcomeTabView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @StateObject private var viewModel = WelcomeTabViewModel()
    @State private var showingMainTabView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    welcomeHeaderSection
                    
                    // Quick Stats Overview
                    quickStatsSection
                    
                    // Recent Progress
                    recentProgressSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Motivational Quote
                    motivationalSection
                    
                    // Navigation to Full App
                    fullAppNavigationSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Welcome Back!")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
            .fullScreenCover(isPresented: $showingMainTabView) {
                MainTabView()
                    .environmentObject(authService)
            }
        }
    }
    
    // MARK: - Welcome Header Section
    private var welcomeHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello \(authService.userFirstName)!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text("Ready to crush your fitness goals today?")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 40))
                    .foregroundColor(Color.undergroundAccent)
                    .undergroundGlow()
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
    
    // MARK: - Quick Stats Section
    private var quickStatsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Stats")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickStatCard(
                    title: "Workout Streak",
                    value: "\(viewModel.workoutStreak)",
                    subtitle: "days",
                    icon: "flame.fill",
                    color: Color.undergroundAccentSecondary
                )
                
                QuickStatCard(
                    title: "This Week",
                    value: "\(viewModel.workoutsThisWeek)",
                    subtitle: "workouts",
                    icon: "calendar",
                    color: Color.undergroundAccentTertiary
                )
                
                QuickStatCard(
                    title: "Total Time",
                    value: viewModel.formatDuration(viewModel.totalWorkoutTime),
                    subtitle: "this month",
                    icon: "clock.fill",
                    color: Color.undergroundAccent
                )
                
                QuickStatCard(
                    title: "Total Sets",
                    value: "\(viewModel.totalSets)",
                    subtitle: "completed",
                    icon: "repeat.circle.fill",
                    color: Color.undergroundAccentSecondary
                )
            }
        }
    }
    
    // MARK: - Recent Progress Section
    private var recentProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.undergroundText)
                
                Spacer()
                
                Button("View All") {
                    showingMainTabView = true
                }
                .font(.subheadline)
                .foregroundColor(Color.undergroundAccent)
            }
            
            if !viewModel.recentWorkouts.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recentWorkouts.prefix(3)) { workout in
                        RecentWorkoutRow(workout: workout)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("No workouts yet")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("Start your first workout to see progress here!")
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
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionCard(
                    title: "Start Workout",
                    icon: "play.circle.fill",
                    color: Color.undergroundAccent,
                    action: { showingMainTabView = true }
                )
                
                QuickActionCard(
                    title: "View Stats",
                    icon: "chart.bar.fill",
                    color: Color.undergroundAccentSecondary,
                    action: { showingMainTabView = true }
                )
                
                QuickActionCard(
                    title: "Body Stats",
                    icon: "person.fill",
                    color: Color.undergroundAccentTertiary,
                    action: { showingMainTabView = true }
                )
                
                QuickActionCard(
                    title: "Exercise Library",
                    icon: "dumbbell.fill",
                    color: Color.undergroundAccent,
                    action: { showingMainTabView = true }
                )
            }
        }
    }
    
    // MARK: - Motivational Section
    private var motivationalSection: some View {
        VStack(spacing: 16) {
            Text("Daily Motivation")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                Image(systemName: "quote.bubble.fill")
                    .font(.title)
                    .foregroundColor(Color.undergroundAccent)
                
                Text(viewModel.motivationalQuote)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.undergroundText)
                    .multilineTextAlignment(.center)
                    .italic()
                
                Text("- \(viewModel.motivationalAuthor)")
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
    }
    
    // MARK: - Full App Navigation Section
    private var fullAppNavigationSection: some View {
        VStack(spacing: 16) {
            Text("Full App Access")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                showingMainTabView = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.right.square.fill")
                        .font(.title2)
                        .foregroundColor(Color.undergroundPrimary)
                    
                    Text("Open Full App")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.undergroundPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.undergroundAccent)
                .cornerRadius(12)
            }
            
            Text("Access all features including workout tracking, detailed stats, and more")
                .font(.caption)
                .foregroundColor(Color.undergroundTextSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Supporting Views

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.undergroundText)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Color.undergroundTextMuted)
            }
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

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.undergroundText)
                    .multilineTextAlignment(.center)
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentWorkoutRow: View {
    let workout: WorkoutSession
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(DateFormatter.monthDayFormatter.string(from: workout.startTime))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.undergroundAccent)
                
                Text(DateFormatter.timeFormatter.string(from: workout.startTime))
                    .font(.caption2)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Workout")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.undergroundText)
                
                Text("\(workout.exercises.count) exercises • \(getTotalSets(for: workout)) sets")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let duration = workout.totalDuration {
                    Text(formatDuration(duration))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.undergroundAccent)
                }
                
                Text("\(Int(getTotalWeight(for: workout))) lbs")
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
    WelcomeTabView()
        .environmentObject(FirebaseAuthService())
}
