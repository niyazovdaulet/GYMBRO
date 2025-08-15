import SwiftUI
import Foundation

@MainActor
class ExerciseDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isFavorite: Bool
    @Published var currentPhotoIndex = 0
    
    // MARK: - Data Properties
    let exercise: Exercise
    
    // Mock photos for the exercise (will be replaced with real photos later)
    let exercisePhotos = [
        "photo", "photo", "photo" // Placeholder for now
    ]
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - Computed Properties
    var photoCount: Int {
        exercisePhotos.count
    }
    
    var currentPhoto: String {
        exercisePhotos[currentPhotoIndex]
    }
    
    // MARK: - Exercise Information
    var exerciseTitle: String {
        exercise.title
    }
    
    var exerciseCategory: String {
        exercise.category
    }
    
    var exerciseDescription: String {
        exercise.description
    }
    
    var exerciseImageName: String {
        exercise.imageName
    }
    
    // MARK: - Initialization
    init(exercise: Exercise) {
        self.exercise = exercise
        self.isFavorite = exercise.isFavorite
        
        // Simulate async loading to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isLoading = false
        }
    }
    
    // MARK: - Photo Management
    func nextPhoto() {
        if currentPhotoIndex < photoCount - 1 {
            currentPhotoIndex += 1
        }
    }
    
    func previousPhoto() {
        if currentPhotoIndex > 0 {
            currentPhotoIndex -= 1
        }
    }
    
    func selectPhoto(at index: Int) {
        guard index >= 0 && index < photoCount else { return }
        currentPhotoIndex = index
    }
    
    // MARK: - Exercise Management
    func toggleFavorite() {
        isFavorite.toggle()
        // Here you would typically save the favorite state to a database or user preferences
    }
} 