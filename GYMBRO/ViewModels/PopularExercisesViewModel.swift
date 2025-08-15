import SwiftUI
import Foundation

@MainActor
class PopularExercisesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedExercise: Exercise?
    @Published var showingExerciseDetail = false
    
    // MARK: - Data Properties
    @Published var exercises: [Exercise] = []
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - API Service
    private let apiService = ExerciseAPIService()
    
    // MARK: - Computed Properties
    var exerciseCount: Int {
        exercises.count
    }
    
    // MARK: - Initialization
    init() {
        loadPopularExercises()
    }
    
    // MARK: - Data Loading
    private func loadPopularExercises() {
        Task {
            await loadExercisesFromAPI()
        }
    }
    
    // MARK: - API Data Loading
    private func loadExercisesFromAPI() async {
        isLoading = true
        
        // Fetch popular exercises (limit to 20 for performance)
        let apiExercises = await apiService.fetchAllExercises()
        let popularExercises = Array(apiExercises.prefix(20)).map { $0.toExercise() }
        
        await MainActor.run {
            self.exercises = popularExercises
            self.isLoading = false
        }
    }
    
    // MARK: - Navigation Methods
    func selectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        showingExerciseDetail = true
    }
    
    // MARK: - Exercise Management
    func toggleExerciseFavorite(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index].isFavorite.toggle()
        }
    }
} 