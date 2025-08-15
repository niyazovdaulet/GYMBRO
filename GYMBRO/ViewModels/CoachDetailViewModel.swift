import SwiftUI
import Foundation

@MainActor
class CoachDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isFavorite: Bool
    @Published var selectedCoach: Coach?
    @Published var showingCoachDetail = false
    
    // MARK: - Data Properties
    let coach: Coach
    
    // Mock photos for the coach (will be replaced with real photos later)
    let coachPhotos = [
        "photo", "photo", "photo" // Placeholder for now
    ]
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - Coach Information
    var coachName: String {
        coach.name
    }
    
    var coachExperience: String {
        "\(coach.yearsExperience) years experience"
    }
    
    var coachImageName: String {
        coach.imageName
    }
    
    // MARK: - Mock coach details
    var coachBio: String {
        "Experienced fitness coach with \(coach.yearsExperience) years of expertise in strength training, cardio, and functional fitness. Specializes in personalized workout programs and nutrition guidance."
    }
    
    var coachSpecialties: [String] {
        [
            "Strength Training",
            "Cardio Fitness",
            "Weight Loss",
            "Muscle Building",
            "Functional Training"
        ]
    }
    
    var coachCertifications: [String] {
        [
            "NASM Certified Personal Trainer",
            "ACE Fitness Nutrition Specialist",
            "CPR/AED Certified",
            "First Aid Certified"
        ]
    }
    
    var coachLanguages: [String] {
        [
            "English",
            "Spanish"
        ]
    }
    
    // MARK: - Initialization
    init(coach: Coach) {
        self.coach = coach
        self.isFavorite = coach.isFavorite
        
        // Simulate async loading to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isLoading = false
        }
    }
    
    // MARK: - Coach Management
    func toggleFavorite() {
        isFavorite.toggle()
        // Here you would typically save the favorite state to a database or user preferences
    }
    
    // MARK: - Contact Methods
    func contactCoach() {
        // Implement contact functionality
        print("Contacting coach: \(coach.name)")
    }
    
    func bookSession() {
        // Implement booking functionality
        print("Booking session with coach: \(coach.name)")
    }
    
    func viewSchedule() {
        // Implement schedule viewing functionality
        print("Viewing schedule for coach: \(coach.name)")
    }
} 