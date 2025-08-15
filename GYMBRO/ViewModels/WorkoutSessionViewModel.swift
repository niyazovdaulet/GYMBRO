import Foundation
import FirebaseFirestore
import Combine

@MainActor
class WorkoutSessionViewModel: ObservableObject {
    @Published var workoutState: WorkoutState = .notStarted
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentSession: WorkoutSession?
    @Published var exercises: [WorkoutExercise] = []
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Timer
    private var timer: Timer?
    private var startTime: Date?
    
    // Firestore
    private let db = Firestore.firestore()
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        Task {
            await loadWorkoutTemplates()
            await createDefaultTemplates()
        }
    }
    
    // MARK: - Workout Management
    
    func startWorkout() {
        guard workoutState == .notStarted else { return }
        
        let session = WorkoutSession(userId: userId)
        currentSession = session
        startTime = Date()
        workoutState = .active
        
        startTimer()
    }
    
    func pauseWorkout() {
        guard workoutState == .active else { return }
        
        workoutState = .paused
        stopTimer()
    }
    
    func resumeWorkout() {
        guard workoutState == .paused else { return }
        
        workoutState = .active
        startTimer()
    }
    
    func finishWorkout() async {
        guard let session = currentSession, workoutState != .finished else { return }
        
        stopTimer()
        workoutState = .finished
        
        // Calculate total duration
        let endTime = Date()
        let totalDuration = endTime.timeIntervalSince(session.startTime)
        
        // Update session
        var updatedSession = session
        updatedSession.endTime = endTime
        updatedSession.totalDuration = totalDuration
        updatedSession.isActive = false
        updatedSession.exercises = exercises
        
        // Save to Firestore
        await saveWorkoutToFirestore(updatedSession)
        
        // Update current session
        currentSession = updatedSession
    }
    
    // MARK: - Exercise Management
    
    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise)
        exercises.append(workoutExercise)
    }
    
    func removeExercise(at index: Int) {
        guard index < exercises.count else { return }
        exercises.remove(at: index)
    }
    
    func addSet(to exerciseIndex: Int, reps: Int, targetRepRange: RepRange? = nil, weight: Double? = nil, isFailure: Bool = false) {
        guard exerciseIndex < exercises.count else { return }
        
        let newSet = ExerciseSet(reps: reps, targetRepRange: targetRepRange, weight: weight, isFailure: isFailure)
        exercises[exerciseIndex].sets.append(newSet)
    }
    
    func removeSet(from exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exercises.count,
              setIndex < exercises[exerciseIndex].sets.count else { return }
        
        exercises[exerciseIndex].sets.remove(at: setIndex)
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        elapsedTime = Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Firestore Operations
    
    private func saveWorkoutToFirestore(_ session: WorkoutSession) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let workoutData = session.toFirestoreData()
            try await db.collection("users")
                .document(userId)
                .collection("workouts")
                .document(session.id)
                .setData(workoutData)
            
            print("Workout saved successfully")
        } catch {
            errorMessage = "Failed to save workout: \(error.localizedDescription)"
            print("Error saving workout: \(error)")
        }
        
        isLoading = false
    }
    
    func loadWorkoutHistory() async -> [WorkoutSession] {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workouts")
                .whereField("isActive", isEqualTo: false)
                .order(by: "startTime", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            let sessions = snapshot.documents.compactMap { document in
                WorkoutSession.fromFirestoreData(document.data())
            }
            
            isLoading = false
            return sessions
        } catch {
            errorMessage = "Failed to load workout history: \(error.localizedDescription)"
            isLoading = false
            return []
        }
    }
    
    // MARK: - Utility Methods
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func getTotalSets() -> Int {
        return exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    func getTotalReps() -> Int {
        return exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + $1.reps }
        }
    }
    
    func getTotalWeight() -> Double {
        return exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { $0 + ($1.weight ?? 0) }
        }
    }
    
    // MARK: - Workout Template Management
    
    func loadWorkoutTemplates() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workoutTemplates")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let templates = snapshot.documents.compactMap { document in
                WorkoutTemplate.fromFirestoreData(document.data())
            }
            
            workoutTemplates = templates
        } catch {
            errorMessage = "Failed to load workout templates: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func saveWorkoutTemplate(_ template: WorkoutTemplate) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let templateData = template.toFirestoreData()
            try await db.collection("users")
                .document(userId)
                .collection("workoutTemplates")
                .document(template.id)
                .setData(templateData)
            
            await loadWorkoutTemplates()
        } catch {
            errorMessage = "Failed to save workout template: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func toggleTemplateFavorite(_ templateId: String) async {
        guard let templateIndex = workoutTemplates.firstIndex(where: { $0.id == templateId }) else { return }
        
        var template = workoutTemplates[templateIndex]
        template.isFavorite.toggle()
        
        await saveWorkoutTemplate(template)
    }
    
    func startWorkoutFromTemplate(_ template: WorkoutTemplate) {
        guard workoutState == .notStarted else { return }
        
        // Convert template exercises to workout exercises
        exercises = template.exercises.map { templateExercise in
            // Create a mock Exercise object for the WorkoutExercise initializer
            let exercise = Exercise(
                id: templateExercise.exerciseId,
                title: templateExercise.name,
                category: templateExercise.category,
                description: "",
                imageName: templateExercise.imageName,
                isFavorite: false
            )
            return WorkoutExercise(exercise: exercise)
        }
        
        startWorkout()
    }
    
    var favoriteTemplates: [WorkoutTemplate] {
        return workoutTemplates.filter { $0.isFavorite }
    }
    
    func createDefaultTemplates() async {
        // Check if templates already exist
        guard workoutTemplates.isEmpty else { return }
        
        // Create sample templates
        let pushTemplate = WorkoutTemplate(
            name: "Push Day",
            description: "Chest, shoulders, and triceps workout",
            exercises: [
                TemplateExercise(
                    id: UUID().uuidString,
                    exerciseId: "bench-press",
                    name: "Bench Press",
                    category: "Chest",
                    imageName: "dumbbell.fill",
                    targetSets: 4,
                    targetRepRange: RepRange(min: 8, max: 12)
                ),
                TemplateExercise(
                    id: UUID().uuidString,
                    exerciseId: "shoulder-press",
                    name: "Shoulder Press",
                    category: "Shoulders",
                    imageName: "dumbbell.fill",
                    targetSets: 3,
                    targetRepRange: RepRange(min: 10, max: 15)
                ),
                TemplateExercise(
                    id: UUID().uuidString,
                    exerciseId: "tricep-dips",
                    name: "Tricep Dips",
                    category: "Arms",
                    imageName: "figure.strengthtraining.traditional",
                    targetSets: 3,
                    targetRepRange: RepRange(min: 12, max: 15)
                )
            ]
        )
        
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            description: "Back and biceps focused workout",
            exercises: [
                TemplateExercise(
                    id: UUID().uuidString,
                    exerciseId: "pull-ups",
                    name: "Pull Ups",
                    category: "Back",
                    imageName: "figure.strengthtraining.traditional",
                    targetSets: 4,
                    targetRepRange: RepRange(min: 6, max: 10)
                ),
                TemplateExercise(
                    id: UUID().uuidString,
                    exerciseId: "barbell-rows",
                    name: "Barbell Rows",
                    category: "Back",
                    imageName: "dumbbell.fill",
                    targetSets: 4,
                    targetRepRange: RepRange(min: 8, max: 12)
                ),
                TemplateExercise(
                    id: UUID().uuidString,
                    exerciseId: "bicep-curls",
                    name: "Bicep Curls",
                    category: "Arms",
                    imageName: "dumbbell.fill",
                    targetSets: 3,
                    targetRepRange: RepRange(min: 12, max: 15)
                )
            ]
        )
        
        var favoritePushTemplate = pushTemplate
        favoritePushTemplate.isFavorite = true
        
        await saveWorkoutTemplate(favoritePushTemplate)
        await saveWorkoutTemplate(pullTemplate)
    }
    
    // MARK: - Cleanup
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
} 