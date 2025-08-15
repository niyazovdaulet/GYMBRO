import SwiftUI
import Foundation

@MainActor
class AllCoachesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCoach: Coach?
    @Published var showingCoachDetail = false
    
    // MARK: - Data Properties
    @Published var coaches: [Coach] = []
    
    // MARK: - Loading State
    @Published var isLoading = true
    
    // MARK: - Computed Properties
    var coachCount: Int {
        coaches.count
    }
    
    // MARK: - Initialization
    init() {
        loadCoaches()
    }
    
    // MARK: - Data Loading
    private func loadCoaches() {
        isLoading = true
        
        // Simulate async loading to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.coaches = [
                Coach(name: "Mike Johnson", yearsExperience: 8, imageName: "person.circle.fill"),
                Coach(name: "Sarah Williams", yearsExperience: 5, imageName: "person.circle.fill"),
                Coach(name: "David Chen", yearsExperience: 12, imageName: "person.circle.fill"),
                Coach(name: "Emma Davis", yearsExperience: 6, imageName: "person.circle.fill"),
                Coach(name: "Alex Rodriguez", yearsExperience: 10, imageName: "person.circle.fill"),
                Coach(name: "Lisa Thompson", yearsExperience: 7, imageName: "person.circle.fill"),
                Coach(name: "James Wilson", yearsExperience: 9, imageName: "person.circle.fill"),
                Coach(name: "Maria Garcia", yearsExperience: 4, imageName: "person.circle.fill")
            ]
            self.isLoading = false
        }
    }
    
    // MARK: - Navigation Methods
    func selectCoach(_ coach: Coach) {
        selectedCoach = coach
        showingCoachDetail = true
    }
    
    // MARK: - Coach Management
    func toggleCoachFavorite(_ coach: Coach) {
        if let index = coaches.firstIndex(where: { $0.id == coach.id }) {
            coaches[index].isFavorite.toggle()
        }
    }
} 