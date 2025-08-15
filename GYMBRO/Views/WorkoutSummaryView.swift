import SwiftUI

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Stats
                    statsSection
                    
                    // Exercises
                    exercisesSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Workout Complete!")
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.undergroundAccent)
                .undergroundGlow()
            
            VStack(spacing: 8) {
                Text("Great Job!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.undergroundText)
                
                Text("Your workout has been saved")
                    .font(.subheadline)
                    .foregroundColor(Color.undergroundTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("Workout Summary")
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
                    title: "Duration",
                    value: formatDuration(session.totalDuration ?? 0),
                    icon: "clock.fill",
                    color: Color.undergroundAccent
                )
                
                SummaryStatCard(
                    title: "Exercises",
                    value: "\(session.exercises.count)",
                    icon: "dumbbell.fill",
                    color: Color.undergroundAccentSecondary
                )
                
                SummaryStatCard(
                    title: "Total Sets",
                    value: "\(getTotalSets())",
                    icon: "repeat.circle.fill",
                    color: Color.undergroundAccentTertiary
                )
            }
            
            if getTotalWeight() > 0 {
                SummaryStatCard(
                    title: "Total Weight",
                    value: "\(Int(getTotalWeight())) lbs",
                    icon: "scalemass.fill",
                    color: Color.undergroundAccentSecondary
                )
                .frame(maxWidth: .infinity)
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
                ForEach(session.exercises) { exercise in
                    ExerciseSummaryCard(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    
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
        return session.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    private func getTotalWeight() -> Double {
        return session.exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0) }
        }
    }
}

// MARK: - Summary Stat Card
struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
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
        .padding(.vertical, 16)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

// MARK: - Exercise Summary Card
struct ExerciseSummaryCard: View {
    let exercise: WorkoutExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack {
                Image(systemName: exercise.imageName)
                    .font(.system(size: 20))
                    .foregroundColor(Color.undergroundAccent)
                    .frame(width: 32, height: 32)
                    .background(Color.undergroundAccent.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text(exercise.category)
                        .font(.caption)
                        .foregroundColor(Color.undergroundAccent)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(exercise.sets.count) sets")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.undergroundText)
                    
                    Text("\(getTotalReps()) reps")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextSecondary)
                }
            }
            
            // Sets Summary
            if !exercise.sets.isEmpty {
                VStack(spacing: 6) {
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("Set \(index + 1)")
                                .font(.caption)
                                .foregroundColor(Color.undergroundTextSecondary)
                                .frame(width: 50, alignment: .leading)
                            
                            Text("\(set.reps) reps")
                                .font(.caption)
                                .foregroundColor(Color.undergroundText)
                            
                            if let weight = set.weight {
                                Text("\(Int(weight)) lbs")
                                    .font(.caption)
                                    .foregroundColor(Color.undergroundAccentSecondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 40)
            }
        }
        .padding(12)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
    
    private func getTotalReps() -> Int {
        return exercise.sets.reduce(0) { $0 + $1.reps }
    }
}

#Preview {
    let mockSession = WorkoutSession(userId: "test")
    WorkoutSummaryView(session: mockSession)
} 