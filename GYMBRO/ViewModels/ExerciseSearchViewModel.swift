import Foundation
import Combine

@MainActor
class ExerciseSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedBodyPart: String?
    @Published var selectedEquipment: String?
    
    // Available filters
    @Published var bodyParts: [String] = []
    @Published var equipment: [String] = []
    
    private let exerciseService = ExerciseAPIService()
    private var searchTask: Task<Void, Never>?
    
    init() {
        loadFilters()
    }
    
    // MARK: - Search Methods
    
    func searchExercises() async {
        // Cancel previous search
        searchTask?.cancel()
        
        searchTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let exercises = try await exerciseService.searchExercises(
                    query: searchText,
                    bodyPart: selectedBodyPart,
                    equipment: selectedEquipment
                )
                
                if !Task.isCancelled {
                    self.exercises = exercises
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = "Failed to search exercises: \(error.localizedDescription)"
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    // MARK: - Filter Loading
    
    private func loadFilters() {
        Task {
            do {
                let bodyParts = try await exerciseService.getBodyParts()
                let equipment = try await exerciseService.getEquipment()
                
                await MainActor.run {
                    self.bodyParts = bodyParts
                    self.equipment = equipment
                }
            } catch {
                print("Failed to load filters: \(error)")
            }
        }
    }
    
    // MARK: - Utility Methods
    
    func clearSearch() {
        searchText = ""
        selectedBodyPart = nil
        selectedEquipment = nil
        exercises = []
    }
} 