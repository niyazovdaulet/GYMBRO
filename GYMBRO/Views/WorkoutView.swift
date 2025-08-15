import SwiftUI

struct WorkoutView: View {
    @StateObject private var viewModel: WorkoutSessionViewModel
    @State private var showingExerciseSearch = false
    @State private var showingWorkoutSummary = false
    @State private var showingAddSet = false
    @State private var showingWorkoutHistory = false
    @State private var selectedExerciseIndex: Int?

    
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: WorkoutSessionViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Favorite Workouts Section (only show when not started)
                if viewModel.workoutState == .notStarted {
                    favoriteWorkoutsSection
                }
                
                // Timer Section
                timerSection
                
                // Workout Controls
                workoutControlsSection
                
                // Exercises List
                exercisesSection
                
                Spacer()
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingWorkoutHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Color.undergroundAccent)
                    }
                }
            }
            .sheet(isPresented: $showingExerciseSearch) {
                ExerciseSearchView { exercise in
                    viewModel.addExercise(exercise)
                    showingExerciseSearch = false
                }
            }
            .sheet(isPresented: $showingWorkoutSummary) {
                if let session = viewModel.currentSession, !session.isActive {
                    WorkoutSummaryView(session: session)
                        .interactiveDismissDisabled() // Prevent accidental dismissal
                }
            }
            .sheet(isPresented: $showingAddSet) {
                if let exerciseIndex = selectedExerciseIndex {
                    AddSetView { reps, repRange, weight, isFailure in
                        viewModel.addSet(to: exerciseIndex, reps: reps, targetRepRange: repRange, weight: weight, isFailure: isFailure)
                        showingAddSet = false
                    }
                }
            }
            .sheet(isPresented: $showingWorkoutHistory) {
                WorkoutHistoryView(userId: viewModel.userId)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Timer Section
    private var timerSection: some View {
        VStack(spacing: 16) {
            // Timer Display
            VStack(spacing: 8) {
                Text(viewModel.formatTime(viewModel.elapsedTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.undergroundAccent)
                    .undergroundGlow()
                
                Text("Workout Time")
                    .font(.subheadline)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.undergroundCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
            .padding(.horizontal)
            
            // Workout Stats
            if !viewModel.exercises.isEmpty {
                HStack(spacing: 20) {
                    StatCard(title: "Exercises", value: "\(viewModel.exercises.count)")
                    StatCard(title: "Sets", value: "\(viewModel.getTotalSets())")
                    StatCard(title: "Reps", value: "\(viewModel.getTotalReps())")
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Workout Controls Section
    private var workoutControlsSection: some View {
        VStack(spacing: 16) {
            switch viewModel.workoutState {
            case .notStarted:
                Button(action: {
                    viewModel.startWorkout()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Workout")
                    }
                    .font(.headline)
                    .foregroundColor(Color.undergroundPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.undergroundAccent)
                    .cornerRadius(12)
                    .undergroundGlow()
                }
                .padding(.horizontal)
                
            case .active:
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.pauseWorkout()
                    }) {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("Pause")
                        }
                        .font(.headline)
                        .foregroundColor(Color.undergroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.undergroundAccentSecondary)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.finishWorkout()
                            // Show summary after workout is finished
                            DispatchQueue.main.async {
                                showingWorkoutSummary = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Finish")
                        }
                        .font(.headline)
                        .foregroundColor(Color.undergroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.undergroundAccentTertiary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
            case .paused:
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.resumeWorkout()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                        .font(.headline)
                        .foregroundColor(Color.undergroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.undergroundAccent)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.finishWorkout()
                            // Show summary after workout is finished
                            DispatchQueue.main.async {
                                showingWorkoutSummary = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Finish")
                        }
                        .font(.headline)
                        .foregroundColor(Color.undergroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.undergroundAccentTertiary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
            case .finished:
                Button(action: {
                    // Reset workout
                    viewModel.workoutState = .notStarted
                    viewModel.elapsedTime = 0
                    viewModel.currentSession = nil
                    viewModel.exercises = []
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("New Workout")
                    }
                    .font(.headline)
                    .foregroundColor(Color.undergroundPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.undergroundAccent)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            // Add Exercise Button
            if viewModel.workoutState == .active || viewModel.workoutState == .paused {
                Button(action: {
                    showingExerciseSearch = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.headline)
                    .foregroundColor(Color.undergroundAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.undergroundCard)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.undergroundAccent, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Exercises Section
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.exercises.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.undergroundAccentSecondary)
                        .undergroundGlow(color: Color.undergroundAccentSecondary)
                    
                    Text("No Exercises Added")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text("Start your workout and add exercises to begin tracking")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                Text("Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.undergroundText)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseWorkoutCard(
                                exercise: exercise,
                                onAddSet: {
                                    selectedExerciseIndex = index
                                    showingAddSet = true
                                },
                                onRemoveExercise: {
                                    viewModel.removeExercise(at: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Favorite Workouts Section
    private var favoriteWorkoutsSection: some View {
        VStack(spacing: 16) {
            if !viewModel.favoriteTemplates.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Favorite Workouts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.favoriteTemplates) { template in
                                FavoriteWorkoutCard(template: template) {
                                    viewModel.startWorkoutFromTemplate(template)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - Favorite Workout Card
struct FavoriteWorkoutCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(Color.undergroundAccentSecondary)
                    
                    Spacer()
                    
                    Text("\(template.exercises.count) exercises")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextSecondary)
                }
                
                Text(template.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.undergroundText)
                    .lineLimit(1)
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
                    .lineLimit(2)
            }
            
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.undergroundPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.undergroundAccent)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .frame(width: 180)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundAccent)
            
            Text(title)
                .font(.caption)
                .foregroundColor(Color.undergroundTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

#Preview {
    WorkoutView(userId: "test-user")
} 