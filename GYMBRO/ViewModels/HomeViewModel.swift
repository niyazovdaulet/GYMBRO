import SwiftUI
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var selectedCategory: Category?
    @Published var selectedExercise: Exercise?
    @Published var selectedCoach: Coach?
    
    // MARK: - Navigation State
    @Published var showingCategoryDetail = false
    @Published var showingPopularExercises = false
    @Published var showingAllCoaches = false
    @Published var showingAllCategories = false
    @Published var showingExerciseDetail = false
    @Published var showingCoachDetail = false
    
    // MARK: - Data Properties
    @Published var exercises: [Exercise] = []
    @Published var coaches: [Coach] = []
    @Published var categories: [Category] = []
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - Services
    private let apiService = ExerciseAPIService()
    private let authService = FirebaseAuthService()
    
    // MARK: - Computed Properties
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { exercise in
                exercise.title.localizedCaseInsensitiveContains(searchText) ||
                exercise.description.localizedCaseInsensitiveContains(searchText) ||
                exercise.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        Task {
            await loadExercisesFromAPI()
            await loadCategoriesFromAPI()
            loadCoaches() // Keep coaches as mock data for now
        }
    }
    
    // MARK: - API Data Loading
    private func loadExercisesFromAPI() async {
        isLoading = true
        
        // Fetch popular exercises (limit to 10 for performance)
        let apiExercises = await apiService.fetchAllExercises()
        let popularExercises = Array(apiExercises.prefix(10)).map { $0.toExercise() }
        
        await MainActor.run {
            self.exercises = popularExercises
            self.isLoading = false
        }
    }
    
    private func loadCategoriesFromAPI() async {
        let bodyParts = await apiService.fetchBodyParts()
        
        await MainActor.run {
            self.categories = bodyParts.map { bodyPart in
                Category(
                    name: bodyPart.capitalized,
                    imageName: getImageNameForBodyPart(bodyPart)
                )
            }
        }
    }
    
    private func loadCoaches() {
        coaches = Coach.mockCoaches
    }
    
    // MARK: - Helper Methods
    private func getImageNameForBodyPart(_ bodyPart: String) -> String {
        switch bodyPart.lowercased() {
        case "chest": return "figure.strengthtraining.traditional"
        case "back": return "figure.strengthtraining.traditional"
        case "shoulders": return "figure.strengthtraining.traditional"
        case "upper arms": return "figure.strengthtraining.traditional"
        case "lower arms": return "figure.strengthtraining.traditional"
        case "waist": return "figure.core.training"
        case "upper legs": return "figure.walk"
        case "lower legs": return "figure.walk"
        case "neck": return "figure.strengthtraining.traditional"
        case "cardio": return "heart.fill"
        default: return "dumbbell.fill"
        }
    }
    
    // MARK: - Navigation Methods
    func selectCategory(_ category: Category) {
        selectedCategory = category
        showingCategoryDetail = true
    }
    
    func selectExercise(_ exercise: Exercise) {
        selectedExercise = exercise
        showingExerciseDetail = true
    }
    
    func selectCoach(_ coach: Coach) {
        selectedCoach = coach
        showingCoachDetail = true
    }
    
    func showPopularExercises() {
        showingPopularExercises = true
    }
    
    func showAllCoaches() {
        showingAllCoaches = true
    }
    
    func showAllCategories() {
        showingAllCategories = true
    }
    
    // MARK: - Search Methods
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    // MARK: - User Management
    var userName: String {
        authService.userFirstName
    }
    
    // MARK: - Exercise Management
    func toggleExerciseFavorite(_ exercise: Exercise) {
        if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
            exercises[index].isFavorite.toggle()
        }
    }
    
    func toggleCoachFavorite(_ coach: Coach) {
        if let index = coaches.firstIndex(where: { $0.id == coach.id }) {
            coaches[index].isFavorite.toggle()
        }
    }
} 