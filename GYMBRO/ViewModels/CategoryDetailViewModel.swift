import SwiftUI
import Foundation

@MainActor
class CategoryDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var selectedExercise: Exercise?
    @Published var showingExerciseDetail = false
    
    // MARK: - Data Properties
    let category: Category
    @Published var exercises: [Exercise] = []
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - API Service
    private let apiService = ExerciseAPIService()
    
    // MARK: - Computed Properties
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { exercise in
                exercise.title.localizedCaseInsensitiveContains(searchText) ||
                exercise.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var exerciseCount: Int {
        filteredExercises.count
    }
    
    // MARK: - Initialization
    init(category: Category) {
        self.category = category
        loadExercises()
    }
    
    // MARK: - Data Loading
    private func loadExercises() {
        Task {
            await loadExercisesFromAPI()
        }
    }
    
    // MARK: - API Data Loading
    private func loadExercisesFromAPI() async {
        isLoading = true
        
        // Convert category name back to API format
        let bodyPart = convertCategoryToBodyPart(category.name)
        let apiExercises = await apiService.fetchExercisesByBodyPart(bodyPart)
        
        await MainActor.run {
            self.exercises = apiExercises.map { $0.toExercise() }
            self.isLoading = false
        }
    }
    
    // MARK: - Helper Methods
    private func convertCategoryToBodyPart(_ categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "chest": return "chest"
        case "back": return "back"
        case "shoulders": return "shoulders"
        case "upper arms": return "upper arms"
        case "lower arms": return "lower arms"
        case "waist": return "waist"
        case "upper legs": return "upper legs"
        case "lower legs": return "lower legs"
        case "neck": return "neck"
        case "cardio": return "cardio"
        default: return categoryName.lowercased()
        }
    }
    
    // MARK: - Navigation Methods
    func selectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        showingExerciseDetail = true
    }
    
    // MARK: - Search Methods
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    // MARK: - Exercise Management
    func toggleExerciseFavorite(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index].isFavorite.toggle()
        }
    }
} 