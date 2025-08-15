import Foundation
import SwiftUI

// MARK: - API Models
struct ExerciseAPI: Codable, Identifiable {
    let id: String
    let name: String
    let bodyPart: String
    let equipment: String
    let target: String
    let secondaryMuscles: [String]?
    let instructions: [String]?
    
    // Computed properties for our app
    var title: String { name }
    var category: String { bodyPart.capitalized }
    var description: String { 
        "Targets \(target.lowercased()) using \(equipment.lowercased())."
    }
    var imageName: String { 
        // Map body parts to SF Symbols
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
}

// MARK: - API Service
@MainActor
class ExerciseAPIService: ObservableObject {
    // MARK: - Properties
    private let baseURL = "https://exercisedb.p.rapidapi.com"
    private let apiKey = "c80400b758mshd1c46277ad42c95p18e65ejsn0d544ccef5b2"
    private let host = "exercisedb.p.rapidapi.com"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Headers
    private var headers: [String: String] {
        [
            "X-RapidAPI-Key": apiKey,
            "X-RapidAPI-Host": host
        ]
    }
    
    // MARK: - API Methods
    
    /// Fetch all body parts (categories)
    func fetchBodyParts() async -> [String] {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(baseURL)/exercises/bodyPartList")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add headers
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            // The body parts API returns a direct array, not wrapped in an object
            let bodyParts = try JSONDecoder().decode([String].self, from: data)
            isLoading = false
            return bodyParts
            
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch body parts: \(error.localizedDescription)"
            print("Error fetching body parts: \(error)")
            return []
        }
    }
    
    /// Fetch exercises by body part
    func fetchExercisesByBodyPart(_ bodyPart: String) async -> [ExerciseAPI] {
        isLoading = true
        errorMessage = nil
        
        do {
            let encodedBodyPart = bodyPart.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? bodyPart
            let url = URL(string: "\(baseURL)/exercises/bodyPart/\(encodedBodyPart)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add headers
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let exercises = try JSONDecoder().decode([ExerciseAPI].self, from: data)
            isLoading = false
            return exercises
            
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch exercises: \(error.localizedDescription)"
            print("Error fetching exercises for \(bodyPart): \(error)")
            return []
        }
    }
    
    /// Fetch all exercises
    func fetchAllExercises() async -> [ExerciseAPI] {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "\(baseURL)/exercises")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add headers
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let exercises = try JSONDecoder().decode([ExerciseAPI].self, from: data)
            isLoading = false
            return exercises
            
        } catch {
            isLoading = false
            errorMessage = "Failed to fetch all exercises: \(error.localizedDescription)"
            print("Error fetching all exercises: \(error)")
            return []
        }
    }
    
    /// Search exercises by name
    func searchExercises(query: String) async -> [ExerciseAPI] {
        isLoading = true
        errorMessage = nil
        
        do {
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let url = URL(string: "\(baseURL)/exercises/name/\(encodedQuery)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Add headers
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let exercises = try JSONDecoder().decode([ExerciseAPI].self, from: data)
            isLoading = false
            return exercises
            
        } catch {
            isLoading = false
            errorMessage = "Failed to search exercises: \(error.localizedDescription)"
            print("Error searching exercises: \(error)")
            return []
        }
    }
    
    /// Search exercises with filters
    func searchExercises(query: String, bodyPart: String?, equipment: String?) async -> [Exercise] {
        var allExercises: [ExerciseAPI] = []
        
        // If we have a body part filter, use that
        if let bodyPart = bodyPart {
            allExercises = await fetchExercisesByBodyPart(bodyPart)
        } else {
            // Otherwise, search by name
            allExercises = await searchExercises(query: query)
        }
        
        // Convert to our Exercise model
        var exercises = allExercises.map { $0.toExercise() }
        
        // Apply text search filter if provided
        if !query.isEmpty {
            exercises = exercises.filter { exercise in
                exercise.title.localizedCaseInsensitiveContains(query) ||
                exercise.category.localizedCaseInsensitiveContains(query)
            }
        }
        
        // Apply equipment filter if provided
        if let equipment = equipment {
            exercises = exercises.filter { exercise in
                // For now, we'll use the category as a proxy for equipment
                // In a real implementation, you'd want to store equipment info in the Exercise model
                exercise.category.localizedCaseInsensitiveContains(equipment)
            }
        }
        
        return exercises
    }
    
    /// Get all body parts
    func getBodyParts() async -> [String] {
        return await fetchBodyParts()
    }
    
    /// Get all equipment types (simplified for now)
    func getEquipment() async -> [String] {
        // For now, return common equipment types
        // In a real implementation, you'd fetch this from the API
        return [
            "barbell", "dumbbell", "kettlebell", "cable", "machine",
            "bodyweight", "resistance band", "medicine ball", "stability ball"
        ]
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidResponse
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

// MARK: - Extension to convert API models to our app models
extension ExerciseAPI {
    func toExercise() -> Exercise {
        return Exercise(
            id: self.id,
            title: self.title,
            category: self.category,
            description: self.description,
            imageName: self.imageName,
            isFavorite: false
        )
    }
} 