import Foundation
import FirebaseFirestore

@MainActor
class WorkoutHistoryViewModel: ObservableObject {
    @Published var workouts: [WorkoutSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    // MARK: - Load Workout History
    
    func loadWorkoutHistory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("workouts")
                .whereField("isActive", isEqualTo: false)
                .order(by: "startTime", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            let sessions = snapshot.documents.compactMap { document in
                WorkoutSession.fromFirestoreData(document.data())
            }
            
            workouts = sessions
        } catch {
            errorMessage = "Failed to load workout history: \(error.localizedDescription)"
            print("Error loading workout history: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Utility Methods
    
    func refreshWorkoutHistory() async {
        await loadWorkoutHistory()
    }
    
    func deleteWorkout(_ workout: WorkoutSession) async {
        do {
            try await db.collection("users")
                .document(userId)
                .collection("workouts")
                .document(workout.id)
                .delete()
            
            // Remove from local array
            workouts.removeAll { $0.id == workout.id }
        } catch {
            errorMessage = "Failed to delete workout: \(error.localizedDescription)"
            print("Error deleting workout: \(error)")
        }
    }
} 