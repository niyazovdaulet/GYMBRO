import Foundation

// MARK: - Exercise Model
struct Exercise: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let category: String
    let description: String
    let imageName: String
    var isFavorite: Bool = false
    
    init(id: String = UUID().uuidString, title: String, category: String, description: String, imageName: String, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.description = description
        self.imageName = imageName
        self.isFavorite = isFavorite
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Coach Model
struct Coach: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let yearsExperience: Int
    let imageName: String
    var isFavorite: Bool = false
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Coach, rhs: Coach) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Category Model
struct Category: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data
extension Exercise {
    static let mockExercises = [
        Exercise(id: "1", title: "Bench Press", category: "Chest", description: "Classic compound exercise for chest development", imageName: "dumbbell.fill"),
        Exercise(id: "2", title: "Squats", category: "Legs", description: "Fundamental lower body exercise", imageName: "figure.walk"),
        Exercise(id: "3", title: "Pull-ups", category: "Back", description: "Upper body strength builder", imageName: "figure.strengthtraining.traditional"),
        Exercise(id: "4", title: "Deadlift", category: "Back", description: "Full body compound movement", imageName: "figure.strengthtraining.traditional"),
        Exercise(id: "5", title: "Overhead Press", category: "Shoulders", description: "Shoulder strength and stability", imageName: "figure.strengthtraining.traditional")
    ]
}

extension Coach {
    static let mockCoaches = [
        Coach(name: "Mike Johnson", yearsExperience: 8, imageName: "person.circle.fill"),
        Coach(name: "Sarah Williams", yearsExperience: 5, imageName: "person.circle.fill"),
        Coach(name: "David Chen", yearsExperience: 12, imageName: "person.circle.fill"),
        Coach(name: "Emma Davis", yearsExperience: 6, imageName: "person.circle.fill")
    ]
}

extension Category {
    static let mockCategories = [
        Category(name: "Chest", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Back", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Triceps", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Biceps", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Legs", imageName: "figure.walk"),
        Category(name: "Glutes", imageName: "figure.walk"),
        Category(name: "Shoulders", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Calves", imageName: "figure.walk"),
        Category(name: "Forearms", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Neck", imageName: "figure.strengthtraining.traditional"),
        Category(name: "Abs", imageName: "figure.core.training")
    ]
} 