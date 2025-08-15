import SwiftUI

struct ExerciseWorkoutCard: View {
    let exercise: WorkoutExercise
    let onAddSet: () -> Void
    let onRemoveExercise: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header
            HStack {
                Image(systemName: exercise.imageName)
                    .font(.system(size: 24))
                    .foregroundColor(Color.undergroundAccent)
                    .frame(width: 40, height: 40)
                    .background(Color.undergroundAccent.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text(exercise.category)
                        .font(.caption)
                        .foregroundColor(Color.undergroundAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.undergroundAccent.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: onRemoveExercise) {
                    Image(systemName: "trash")
                        .foregroundColor(Color.undergroundAccentSecondary)
                        .font(.title3)
                }
            }
            
            // Sets Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sets")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.undergroundText)
                    
                    Spacer()
                    
                    Button(action: onAddSet) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Set")
                        }
                        .font(.caption)
                        .foregroundColor(Color.undergroundAccent)
                    }
                }
                
                if exercise.sets.isEmpty {
                    Text("No sets added yet")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextSecondary)
                        .italic()
                } else {
                    LazyVStack(spacing: 6) {
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                            SetRow(set: set, setNumber: index + 1)
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
}

// MARK: - Set Row Component
struct SetRow: View {
    let set: ExerciseSet
    let setNumber: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("Set \(setNumber)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color.undergroundTextSecondary)
                .frame(width: 50, alignment: .leading)
            
            HStack(spacing: 8) {
                Image(systemName: "repeat")
                    .font(.caption)
                    .foregroundColor(set.isFailure ? Color.undergroundAccentSecondary : Color.undergroundAccent)
                
                if let targetRange = set.targetRepRange {
                    Text("\(set.reps)/\(targetRange.description) reps")
                        .font(.caption)
                        .foregroundColor(set.isFailure ? Color.undergroundAccentSecondary : Color.undergroundText)
                } else {
                    Text("\(set.reps) reps")
                        .font(.caption)
                        .foregroundColor(Color.undergroundText)
                }
                
                if set.isFailure {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(Color.undergroundAccentSecondary)
                }
            }
            
            if let weight = set.weight {
                HStack(spacing: 4) {
                    Image(systemName: "scalemass")
                        .font(.caption)
                        .foregroundColor(Color.undergroundAccentSecondary)
                    
                    Text("\(Int(weight)) lbs")
                        .font(.caption)
                        .foregroundColor(Color.undergroundText)
                }
            }
            
            Spacer()
            
            Text(formatTime(set.timestamp))
                .font(.caption2)
                .foregroundColor(Color.undergroundTextMuted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.undergroundElevated)
        .cornerRadius(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ExerciseWorkoutCard(
        exercise: WorkoutExercise(
            exercise: Exercise(
                id: "1",
                title: "Bench Press",
                category: "Chest",
                description: "A compound exercise for chest",
                imageName: "dumbbell.fill",
                isFavorite: false
            )
        ),
        onAddSet: {},
        onRemoveExercise: {}
    )
    .padding()
    .background(Color.undergroundPrimary)
} 