import Foundation
import FirebaseFirestore
import Combine

@MainActor
class StatsViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var workoutStreak: Int = 0
    @Published var totalWorkouts: Int = 0
    @Published var totalWorkoutTime: TimeInterval = 0
    @Published var totalSets: Int = 0
    @Published var totalReps: Int = 0
    @Published var totalWeight: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Progress tracking
    @Published var progressData: [ProgressDataPoint] = []
    @Published var exerciseProgressData: [String: [ExerciseProgress]] = [:]
    
    private let db = Firestore.firestore()
    var userId: String
    
    init(userId: String) {
        self.userId = userId
        Task {
            await loadStats()
        }
    }
    
    // MARK: - Data Loading
    
    func loadStats() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadWorkoutSessions() }
            group.addTask { await self.calculateWorkoutStreak() }
            group.addTask { await self.calculateProgressData() }
        }
    }
    
    private func loadWorkoutSessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workouts")
                .whereField("isActive", isEqualTo: false)
                .order(by: "startTime", descending: true)
                .limit(to: 100)
                .getDocuments()
            
            let sessions = snapshot.documents.compactMap { document in
                WorkoutSession.fromFirestoreData(document.data())
            }
            
            workoutSessions = sessions
            calculateOverallStats()
            
        } catch {
            errorMessage = "Failed to load workout data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func calculateOverallStats() {
        totalWorkouts = workoutSessions.count
        totalWorkoutTime = workoutSessions.reduce(0) { $0 + ($1.totalDuration ?? 0) }
        totalSets = workoutSessions.reduce(0) { total, session in
            total + session.exercises.reduce(0) { $0 + $1.sets.count }
        }
        totalReps = workoutSessions.reduce(0) { total, session in
            total + session.exercises.reduce(0) { exerciseTotal, exercise in
                exerciseTotal + exercise.sets.reduce(0) { $0 + $1.reps }
            }
        }
        totalWeight = workoutSessions.reduce(0) { total, session in
            total + session.exercises.reduce(0) { exerciseTotal, exercise in
                exerciseTotal + exercise.sets.reduce(0) { $0 + ($1.weight ?? 0) }
            }
        }
    }
    
    private func calculateWorkoutStreak() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Get workout dates
        let workoutDates = Set(workoutSessions.map { calendar.startOfDay(for: $0.startTime) })
        
        // Check if we worked out today or yesterday to start the streak
        if workoutDates.contains(today) {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  workoutDates.contains(yesterday) {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: yesterday) ?? yesterday
        } else {
            workoutStreak = 0
            return
        }
        
        // Count consecutive days
        while workoutDates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        workoutStreak = max(0, streak - 1) // Subtract 1 because we already counted the first day
    }
    
    private func calculateProgressData() async {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        // Filter sessions from last 30 days
        let recentSessions = workoutSessions.filter { $0.startTime >= thirtyDaysAgo }
        
        // Group by date and calculate metrics
        var dailyData: [Date: ProgressDataPoint] = [:]
        
        for session in recentSessions {
            let date = calendar.startOfDay(for: session.startTime)
            
            if dailyData[date] == nil {
                dailyData[date] = ProgressDataPoint(date: date, totalVolume: 0, totalSets: 0, totalReps: 0, workoutDuration: 0)
            }
            
            let sessionVolume = session.exercises.reduce(0.0) { total, exercise in
                total + exercise.sets.reduce(0.0) { $0 + (($1.weight ?? 0) * Double($1.reps)) }
            }
            
            let sessionSets = session.exercises.reduce(0) { $0 + $1.sets.count }
            let sessionReps = session.exercises.reduce(0) { total, exercise in
                total + exercise.sets.reduce(0) { $0 + $1.reps }
            }
            
            dailyData[date]?.totalVolume += sessionVolume
            dailyData[date]?.totalSets += sessionSets
            dailyData[date]?.totalReps += sessionReps
            dailyData[date]?.workoutDuration += session.totalDuration ?? 0
        }
        
        // Convert to array and sort by date
        progressData = dailyData.values.sorted { $0.date < $1.date }
        
        // Calculate exercise-specific progress
        await calculateExerciseProgress()
    }
    
    private func calculateExerciseProgress() async {
        var exerciseData: [String: [ExerciseProgress]] = [:]
        
        for session in workoutSessions.prefix(20) { // Last 20 sessions
            for exercise in session.exercises {
                if exerciseData[exercise.name] == nil {
                    exerciseData[exercise.name] = []
                }
                
                let maxWeight = exercise.sets.compactMap { $0.weight }.max() ?? 0
                let totalVolume = exercise.sets.reduce(0.0) { $0 + (($1.weight ?? 0) * Double($1.reps)) }
                let totalReps = exercise.sets.reduce(0) { $0 + $1.reps }
                
                let progress = ExerciseProgress(
                    date: session.startTime,
                    maxWeight: maxWeight,
                    totalVolume: totalVolume,
                    totalReps: totalReps,
                    setsCompleted: exercise.sets.count
                )
                
                exerciseData[exercise.name]?.append(progress)
            }
        }
        
        // Sort each exercise's progress by date
        for (exercise, progressArray) in exerciseData {
            exerciseData[exercise] = progressArray.sorted { $0.date < $1.date }
        }
        
        exerciseProgressData = exerciseData
    }
    
    // MARK: - Computed Properties
    
    var averageWorkoutDuration: TimeInterval {
        guard totalWorkouts > 0 else { return 0 }
        return totalWorkoutTime / Double(totalWorkouts)
    }
    
    var averageSetsPerWorkout: Double {
        guard totalWorkouts > 0 else { return 0 }
        return Double(totalSets) / Double(totalWorkouts)
    }
    
    var averageRepsPerSet: Double {
        guard totalSets > 0 else { return 0 }
        return Double(totalReps) / Double(totalSets)
    }
    
    var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return workoutSessions.filter { $0.startTime >= startOfWeek }.count
    }
    
    var workoutsThisMonth: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        return workoutSessions.filter { $0.startTime >= startOfMonth }.count
    }
    
    // MARK: - Utility Methods
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func refresh() async {
        await loadStats()
    }
}

// MARK: - Supporting Models

struct ProgressDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    var totalVolume: Double
    var totalSets: Int
    var totalReps: Int
    var workoutDuration: TimeInterval
}

struct ExerciseProgress: Identifiable {
    let id = UUID()
    let date: Date
    let maxWeight: Double
    let totalVolume: Double
    let totalReps: Int
    let setsCompleted: Int
}