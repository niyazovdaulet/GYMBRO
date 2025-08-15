import Foundation
import FirebaseFirestore

// MARK: - Workout Models
struct WorkoutSession: Identifiable, Codable {
    let id: String
    let userId: String
    let startTime: Date
    var endTime: Date?
    var totalDuration: TimeInterval?
    var exercises: [WorkoutExercise]
    var isActive: Bool
    
    init(userId: String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.startTime = Date()
        self.endTime = nil
        self.totalDuration = nil
        self.exercises = []
        self.isActive = true
    }
    
    init(id: String, userId: String, startTime: Date, endTime: Date?, totalDuration: TimeInterval?, exercises: [WorkoutExercise], isActive: Bool) {
        self.id = id
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.totalDuration = totalDuration
        self.exercises = exercises
        self.isActive = isActive
    }
}

struct WorkoutExercise: Identifiable, Codable {
    let id: String
    let exerciseId: String
    let name: String
    let category: String
    let imageName: String
    var sets: [ExerciseSet]
    
    init(exercise: Exercise) {
        self.id = UUID().uuidString
        self.exerciseId = exercise.id
        self.name = exercise.title
        self.category = exercise.category
        self.imageName = exercise.imageName
        self.sets = []
    }
    
    init(id: String, exerciseId: String, name: String, category: String, imageName: String, sets: [ExerciseSet]) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.imageName = imageName
        self.sets = sets
    }
}

struct ExerciseSet: Identifiable, Codable {
    let id: String
    var reps: Int
    var targetRepRange: RepRange?
    var weight: Double?
    var isFailure: Bool // Did the user fail to complete all target reps?
    let timestamp: Date
    
    init(reps: Int, targetRepRange: RepRange? = nil, weight: Double? = nil, isFailure: Bool = false) {
        self.id = UUID().uuidString
        self.reps = reps
        self.targetRepRange = targetRepRange
        self.weight = weight
        self.isFailure = isFailure
        self.timestamp = Date()
    }
    
    init(id: String, reps: Int, targetRepRange: RepRange?, weight: Double?, isFailure: Bool, timestamp: Date) {
        self.id = id
        self.reps = reps
        self.targetRepRange = targetRepRange
        self.weight = weight
        self.isFailure = isFailure
        self.timestamp = timestamp
    }
}

// MARK: - Rep Range
struct RepRange: Codable {
    let min: Int
    let max: Int
    
    init(min: Int, max: Int) {
        self.min = min
        self.max = max
    }
    
    var description: String {
        return "\(min)-\(max)"
    }
    
    func contains(_ reps: Int) -> Bool {
        return reps >= min && reps <= max
    }
}

// MARK: - Workout Template
struct WorkoutTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let exercises: [TemplateExercise]
    var isFavorite: Bool
    let createdAt: Date
    
    init(name: String, description: String, exercises: [TemplateExercise]) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
        self.exercises = exercises
        self.isFavorite = false
        self.createdAt = Date()
    }
}

struct TemplateExercise: Identifiable, Codable {
    let id: String
    let exerciseId: String
    let name: String
    let category: String
    let imageName: String
    let targetSets: Int
    let targetRepRange: RepRange
    
    init(exercise: Exercise, targetSets: Int, targetRepRange: RepRange) {
        self.id = UUID().uuidString
        self.exerciseId = exercise.id
        self.name = exercise.title
        self.category = exercise.category
        self.imageName = exercise.imageName
        self.targetSets = targetSets
        self.targetRepRange = targetRepRange
    }
    
    init(id: String, exerciseId: String, name: String, category: String, imageName: String, targetSets: Int, targetRepRange: RepRange) {
        self.id = id
        self.exerciseId = exerciseId
        self.name = name
        self.category = category
        self.imageName = imageName
        self.targetSets = targetSets
        self.targetRepRange = targetRepRange
    }
}

// MARK: - Workout State
enum WorkoutState {
    case notStarted
    case active
    case paused
    case finished
}

// MARK: - Exercise Search Models
struct ExerciseSearchFilters {
    var bodyPart: String?
    var equipment: String?
    var searchText: String = ""
}

// MARK: - Firestore Extensions
extension WorkoutSession {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "userId": userId,
            "startTime": Timestamp(date: startTime),
            "isActive": isActive,
            "exercises": exercises.map { $0.toFirestoreData() }
        ]
        
        if let endTime = endTime {
            data["endTime"] = Timestamp(date: endTime)
        }
        
        if let totalDuration = totalDuration {
            data["totalDuration"] = totalDuration
        }
        
        return data
    }
    
    static func fromFirestoreData(_ data: [String: Any]) -> WorkoutSession? {
        guard let id = data["id"] as? String,
              let userId = data["userId"] as? String,
              let startTimeTimestamp = data["startTime"] as? Timestamp,
              let isActive = data["isActive"] as? Bool,
              let exercisesData = data["exercises"] as? [[String: Any]] else {
            return nil
        }
        
        let startTime = startTimeTimestamp.dateValue()
        var endTime: Date?
        var totalDuration: TimeInterval?
        
        if let endTimeTimestamp = data["endTime"] as? Timestamp {
            endTime = endTimeTimestamp.dateValue()
        }
        
        if let duration = data["totalDuration"] as? TimeInterval {
            totalDuration = duration
        }
        
        let exercises = exercisesData.compactMap { WorkoutExercise.fromFirestoreData($0) }
        
        return WorkoutSession(
            id: id,
            userId: userId,
            startTime: startTime,
            endTime: endTime,
            totalDuration: totalDuration,
            exercises: exercises,
            isActive: isActive
        )
    }
}

extension WorkoutExercise {
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "exerciseId": exerciseId,
            "name": name,
            "category": category,
            "imageName": imageName,
            "sets": sets.map { $0.toFirestoreData() }
        ]
    }
    
    static func fromFirestoreData(_ data: [String: Any]) -> WorkoutExercise? {
        guard let id = data["id"] as? String,
              let exerciseId = data["exerciseId"] as? String,
              let name = data["name"] as? String,
              let category = data["category"] as? String,
              let imageName = data["imageName"] as? String,
              let setsData = data["sets"] as? [[String: Any]] else {
            return nil
        }
        
        let sets = setsData.compactMap { ExerciseSet.fromFirestoreData($0) }
        
        return WorkoutExercise(
            id: id,
            exerciseId: exerciseId,
            name: name,
            category: category,
            imageName: imageName,
            sets: sets
        )
    }
}

extension ExerciseSet {
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "reps": reps,
            "isFailure": isFailure,
            "timestamp": Timestamp(date: timestamp)
        ]
        
        if let weight = weight {
            data["weight"] = weight
        }
        
        if let targetRepRange = targetRepRange {
            data["targetRepRange"] = [
                "min": targetRepRange.min,
                "max": targetRepRange.max
            ]
        }
        
        return data
    }
    
    static func fromFirestoreData(_ data: [String: Any]) -> ExerciseSet? {
        guard let id = data["id"] as? String,
              let reps = data["reps"] as? Int,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        
        let weight = data["weight"] as? Double
        let isFailure = data["isFailure"] as? Bool ?? false
        
        var targetRepRange: RepRange?
        if let repRangeData = data["targetRepRange"] as? [String: Any],
           let min = repRangeData["min"] as? Int,
           let max = repRangeData["max"] as? Int {
            targetRepRange = RepRange(min: min, max: max)
        }
        
        return ExerciseSet(
            id: id,
            reps: reps,
            targetRepRange: targetRepRange,
            weight: weight,
            isFailure: isFailure,
            timestamp: timestamp.dateValue()
        )
    }
}

extension WorkoutTemplate {
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "description": description,
            "exercises": exercises.map { $0.toFirestoreData() },
            "isFavorite": isFavorite,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    static func fromFirestoreData(_ data: [String: Any]) -> WorkoutTemplate? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let description = data["description"] as? String,
              let exercisesData = data["exercises"] as? [[String: Any]],
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        
        let isFavorite = data["isFavorite"] as? Bool ?? false
        let exercises = exercisesData.compactMap { TemplateExercise.fromFirestoreData($0) }
        
        var template = WorkoutTemplate(name: name, description: description, exercises: exercises)
        template.isFavorite = isFavorite
        return template
    }
}

extension TemplateExercise {
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "exerciseId": exerciseId,
            "name": name,
            "category": category,
            "imageName": imageName,
            "targetSets": targetSets,
            "targetRepRange": [
                "min": targetRepRange.min,
                "max": targetRepRange.max
            ]
        ]
    }
    
    static func fromFirestoreData(_ data: [String: Any]) -> TemplateExercise? {
        guard let id = data["id"] as? String,
              let exerciseId = data["exerciseId"] as? String,
              let name = data["name"] as? String,
              let category = data["category"] as? String,
              let imageName = data["imageName"] as? String,
              let targetSets = data["targetSets"] as? Int,
              let repRangeData = data["targetRepRange"] as? [String: Any],
              let min = repRangeData["min"] as? Int,
              let max = repRangeData["max"] as? Int else {
            return nil
        }
        
        let targetRepRange = RepRange(min: min, max: max)
        
        let templateExercise = TemplateExercise(
            id: id,
            exerciseId: exerciseId,
            name: name,
            category: category,
            imageName: imageName,
            targetSets: targetSets,
            targetRepRange: targetRepRange
        )
        return templateExercise
    }
} 