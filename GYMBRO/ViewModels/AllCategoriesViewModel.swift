import SwiftUI
import Foundation

@MainActor
class AllCategoriesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCategory: Category?
    @Published var showingCategoryDetail = false
    
    // MARK: - Data Properties
    @Published var categories: [Category] = []
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - API Service
    private let apiService = ExerciseAPIService()
    
    // MARK: - Computed Properties
    var categoryCount: Int {
        categories.count
    }
    
    // MARK: - Initialization
    init() {
        loadCategories()
    }
    
    // MARK: - Data Loading
    private func loadCategories() {
        Task {
            await loadCategoriesFromAPI()
        }
    }
    
    // MARK: - API Data Loading
    private func loadCategoriesFromAPI() async {
        isLoading = true
        
        let bodyParts = await apiService.fetchBodyParts()
        
        await MainActor.run {
            self.categories = bodyParts.map { bodyPart in
                Category(
                    name: bodyPart.capitalized,
                    imageName: getImageNameForBodyPart(bodyPart)
                )
            }
            self.isLoading = false
        }
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
} 