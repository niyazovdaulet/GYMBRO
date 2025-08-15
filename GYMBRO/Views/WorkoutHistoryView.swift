import SwiftUI

struct WorkoutHistoryView: View {
    @StateObject private var viewModel: WorkoutHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: WorkoutHistoryViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading workout history...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.undergroundAccent))
                            .foregroundColor(Color.undergroundText)
                        Spacer()
                    }
                } else if viewModel.workouts.isEmpty {
                    emptyStateView
                } else {
                    workoutList
                }
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.undergroundAccent)
                }
            }
            .task {
                await viewModel.loadWorkoutHistory()
            }
            .refreshable {
                await viewModel.loadWorkoutHistory()
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(Color.undergroundAccentSecondary)
                .undergroundGlow(color: Color.undergroundAccentSecondary)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
            
            Text("Complete your first workout to see it here")
                .font(.subheadline)
                .foregroundColor(Color.undergroundTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Workout List
    private var workoutList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.workouts) { workout in
                    WorkoutHistoryCard(workout: workout)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Workout History Card
struct WorkoutHistoryCard: View {
    let workout: WorkoutSession
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(workout.startTime))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.undergroundText)
                        
                        Text(formatDuration(workout.totalDuration ?? 0))
                            .font(.subheadline)
                            .foregroundColor(Color.undergroundAccent)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(workout.exercises.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.undergroundAccentSecondary)
                        
                        Text("exercises")
                            .font(.caption)
                            .foregroundColor(Color.undergroundTextSecondary)
                    }
                }
                
                // Stats
                HStack(spacing: 20) {
                    StatItem(
                        icon: "repeat.circle.fill",
                        value: "\(getTotalSets())",
                        label: "sets",
                        color: Color.undergroundAccent
                    )
                    
                    StatItem(
                        icon: "scalemass.fill",
                        value: "\(Int(getTotalWeight()))",
                        label: "lbs",
                        color: Color.undergroundAccentSecondary
                    )
                    
                    StatItem(
                        icon: "clock.fill",
                        value: formatTime(workout.startTime),
                        label: "started",
                        color: Color.undergroundAccentTertiary
                    )
                }
                
                // Exercise Preview
                if !workout.exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercises")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.undergroundTextSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(workout.exercises.prefix(3)) { exercise in
                                    Text(exercise.name)
                                        .font(.caption)
                                        .foregroundColor(Color.undergroundAccent)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.undergroundAccent.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                
                                if workout.exercises.count > 3 {
                                    Text("+\(workout.exercises.count - 3) more")
                                        .font(.caption)
                                        .foregroundColor(Color.undergroundTextSecondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.undergroundTextMuted.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.undergroundCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            WorkoutDetailView(workout: workout)
        }
    }
    
    // MARK: - Utility Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getTotalSets() -> Int {
        return workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    private func getTotalWeight() -> Double {
        return workout.exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0) }
        }
    }
}

// MARK: - Stat Item Component
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color.undergroundText)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(Color.undergroundTextSecondary)
        }
    }
}

// MARK: - Workout Detail View
struct WorkoutDetailView: View {
    let workout: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text(formatDate(workout.startTime))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.undergroundText)
                        
                        Text("Duration: \(formatDuration(workout.totalDuration ?? 0))")
                            .font(.subheadline)
                            .foregroundColor(Color.undergroundAccent)
                    }
                    .padding(.top, 20)
                    
                    // Stats
                    statsSection
                    
                    // Exercises
                    exercisesSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.undergroundAccent)
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryStatCard(
                    title: "Exercises",
                    value: "\(workout.exercises.count)",
                    icon: "dumbbell.fill",
                    color: Color.undergroundAccent
                )
                
                SummaryStatCard(
                    title: "Total Sets",
                    value: "\(getTotalSets())",
                    icon: "repeat.circle.fill",
                    color: Color.undergroundAccentSecondary
                )
                
                SummaryStatCard(
                    title: "Total Weight",
                    value: "\(Int(getTotalWeight())) lbs",
                    icon: "scalemass.fill",
                    color: Color.undergroundAccentTertiary
                )
            }
        }
    }
    
    // MARK: - Exercises Section
    private var exercisesSection: some View {
        VStack(spacing: 16) {
            Text("Exercises")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(workout.exercises) { exercise in
                    ExerciseSummaryCard(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    private func getTotalSets() -> Int {
        return workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    private func getTotalWeight() -> Double {
        return workout.exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0) }
        }
    }
}

#Preview {
    WorkoutHistoryView(userId: "test-user")
} 