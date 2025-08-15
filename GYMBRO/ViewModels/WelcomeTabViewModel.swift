import Foundation
import FirebaseFirestore

@MainActor
class WelcomeTabViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var workoutStreak: Int = 0
    @Published var workoutsThisWeek: Int = 0
    @Published var workoutsThisMonth: Int = 0
    @Published var totalWorkoutTime: TimeInterval = 0
    @Published var totalSets: Int = 0
    @Published var recentWorkouts: [WorkoutSession] = []
    @Published var motivationalQuote: String = "The only bad workout is the one that didn't happen."
    @Published var motivationalAuthor: String = "Unknown"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var userId: String?
    
    // MARK: - Motivational Quotes
    private let motivationalQuotes = [
        ("The only bad workout is the one that didn't happen.", "Unknown"),
        ("Strength does not come from the physical capacity. It comes from an indomitable will.", "Mahatma Gandhi"),
        ("The hard days are what make you stronger.", "Aly Raisman"),
        ("Success isn't always about greatness. It's about consistency.", "Dwayne Johnson"),
        ("Take care of your body. It's the only place you have to live.", "Jim Rohn"),
        ("The difference between the impossible and the possible lies in determination.", "Tommy Lasorda"),
        ("Pain is temporary. Quitting lasts forever.", "Lance Armstrong"),
        ("What seems impossible today will one day become your warm-up.", "Unknown"),
        ("The only person you are destined to become is the person you decide to be.", "Ralph Waldo Emerson"),
        ("Don't wish for it. Work for it.", "Unknown")
    ]
    
    // MARK: - Initialization
    init() {
        loadMotivationalQuote()
    }
    
    // MARK: - Public Methods
    
    /// Load all data for the welcome tab
    func loadData() async {
        isLoading = true
        
        // Load motivational quote
        loadMotivationalQuote()
        
        // Load workout statistics
        await loadWorkoutStats()
        
        // Load recent workouts
        await loadRecentWorkouts()
        
        isLoading = false
    }
    
    /// Refresh all data
    func refreshData() async {
        await loadData()
    }
    
    // MARK: - Private Methods
    
    /// Load workout statistics
    private func loadWorkoutStats() async {
        // For now, we'll use mock data
        // In a real app, this would fetch from Firestore
        workoutStreak = 5
        workoutsThisWeek = 3
        workoutsThisMonth = 12
        totalWorkoutTime = 7200 // 2 hours in seconds
        totalSets = 48
    }
    
    /// Load recent workouts
    private func loadRecentWorkouts() async {
        // For now, we'll use mock data
        // In a real app, this would fetch from Firestore
        let mockWorkouts = [
            createMockWorkout(
                exercises: [
                    createMockExercise(name: "Bench Press", category: "Chest"),
                    createMockExercise(name: "Squats", category: "Legs")
                ],
                duration: 3600
            ),
            createMockWorkout(
                exercises: [
                    createMockExercise(name: "Pull-ups", category: "Back"),
                    createMockExercise(name: "Overhead Press", category: "Shoulders")
                ],
                duration: 3300
            ),
            createMockWorkout(
                exercises: [
                    createMockExercise(name: "Deadlift", category: "Back"),
                    createMockExercise(name: "Lunges", category: "Legs")
                ],
                duration: 3900
            )
        ]
        
        recentWorkouts = mockWorkouts
    }
    
    /// Create a mock workout with the given exercises and duration
    private func createMockWorkout(exercises: [WorkoutExercise], duration: TimeInterval) -> WorkoutSession {
        let workout = WorkoutSession(userId: "mock")
        
        // Create a new workout with the exercises
        let newWorkout = WorkoutSession(
            id: workout.id,
            userId: workout.userId,
            startTime: workout.startTime,
            endTime: workout.startTime.addingTimeInterval(duration),
            totalDuration: duration,
            exercises: exercises,
            isActive: false
        )
        
        return newWorkout
    }
    
    /// Create a mock exercise with the given name and category
    private func createMockExercise(name: String, category: String) -> WorkoutExercise {
        let exercise = Exercise(
            title: name,
            category: category,
            description: "Mock exercise for \(name)",
            imageName: "dumbbell.fill"
        )
        
        let workoutExercise = WorkoutExercise(exercise: exercise)
        
        // Add some mock sets
        let mockSets = [
            ExerciseSet(reps: 10, weight: 135),
            ExerciseSet(reps: 8, weight: 155),
            ExerciseSet(reps: 6, weight: 175)
        ]
        
        // Create a new workout exercise with the sets
        let newWorkoutExercise = WorkoutExercise(
            id: workoutExercise.id,
            exerciseId: workoutExercise.exerciseId,
            name: workoutExercise.name,
            category: workoutExercise.category,
            imageName: workoutExercise.imageName,
            sets: mockSets
        )
        
        return newWorkoutExercise
    }
    
    /// Load a random motivational quote
    private func loadMotivationalQuote() {
        let randomIndex = Int.random(in: 0..<motivationalQuotes.count)
        let quote = motivationalQuotes[randomIndex]
        motivationalQuote = quote.0
        motivationalAuthor = quote.1
    }
    
    /// Format duration from seconds to human readable string
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
