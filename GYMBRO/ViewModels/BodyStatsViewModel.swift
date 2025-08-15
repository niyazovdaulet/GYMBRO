import Foundation
import FirebaseFirestore

@MainActor
class BodyStatsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentWeight: Double = 0.0
    @Published var currentBodyFat: Double = 0.0
    @Published var currentMuscleMass: Double = 0.0
    @Published var currentBMI: Double = 0.0
    
    @Published var weightChange: Double = 0.0
    @Published var bodyFatChange: Double = 0.0
    @Published var muscleMassChange: Double = 0.0
    @Published var bmiChange: Double = 0.0
    
    @Published var measurementHistory: [BodyMeasurement] = []
    @Published var weightProgressData: [BodyProgressDataPoint] = []
    @Published var bodyFatProgressData: [BodyProgressDataPoint] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private var userId: String?
    
    // MARK: - Initialization
    init() {
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    /// Load all data for the body stats view
    func loadData() async {
        isLoading = true
        
        // Load current measurements
        await loadCurrentMeasurements()
        
        // Load measurement history
        await loadMeasurementHistory()
        
        // Generate progress data
        generateProgressData()
        
        isLoading = false
    }
    
    /// Load data for a specific time range
    func loadDataForTimeRange(_ timeRange: BodyStatsView.TimeRange) async {
        // In a real app, this would filter data based on the selected time range
        await loadData()
    }
    
    /// Add a new measurement
    func addMeasurement(_ measurement: BodyMeasurement) {
        measurementHistory.insert(measurement, at: 0)
        
        // Update current measurements if this is the most recent
        if measurement.date > measurementHistory.last?.date ?? Date.distantPast {
            updateCurrentMeasurements(with: measurement)
        }
        
        // Regenerate progress data
        generateProgressData()
        
        // Save to Firestore (in a real app)
        saveMeasurementToFirestore(measurement)
    }
    
    // MARK: - Private Methods
    
    /// Load current measurements
    private func loadCurrentMeasurements() async {
        // For now, use mock data
        // In a real app, this would fetch from Firestore
        currentWeight = 175.5
        currentBodyFat = 15.2
        currentMuscleMass = 140.3
        currentBMI = 24.1
        
        // Calculate changes (mock data)
        weightChange = -2.5
        bodyFatChange = -1.8
        muscleMassChange = 3.2
        bmiChange = -0.4
    }
    
    /// Load measurement history
    private func loadMeasurementHistory() async {
        // For now, use mock data
        // In a real app, this would fetch from Firestore
        let mockMeasurements = [
            BodyMeasurement(
                weight: 175.5,
                bodyFat: 15.2,
                muscleMass: 140.3,
                height: 70.0,
                date: Date()
            ),
            BodyMeasurement(
                weight: 178.0,
                bodyFat: 17.0,
                muscleMass: 137.1,
                height: 70.0,
                date: Date().addingTimeInterval(-7 * 24 * 3600)
            ),
            BodyMeasurement(
                weight: 180.2,
                bodyFat: 18.5,
                muscleMass: 135.0,
                height: 70.0,
                date: Date().addingTimeInterval(-14 * 24 * 3600)
            ),
            BodyMeasurement(
                weight: 182.0,
                bodyFat: 19.2,
                muscleMass: 133.0,
                height: 70.0,
                date: Date().addingTimeInterval(-21 * 24 * 3600)
            ),
            BodyMeasurement(
                weight: 185.0,
                bodyFat: 20.0,
                muscleMass: 130.0,
                height: 70.0,
                date: Date().addingTimeInterval(-28 * 24 * 3600)
            )
        ]
        
        measurementHistory = mockMeasurements
    }
    
    /// Generate progress data for charts
    private func generateProgressData() {
        // Generate weight progress data
        weightProgressData = measurementHistory.map { measurement in
            BodyProgressDataPoint(
                date: measurement.date,
                value: measurement.weight
            )
        }.reversed()
        
        // Generate body fat progress data
        bodyFatProgressData = measurementHistory.map { measurement in
            BodyProgressDataPoint(
                date: measurement.date,
                value: measurement.bodyFat
            )
        }.reversed()
    }
    
    /// Update current measurements with new measurement
    private func updateCurrentMeasurements(with measurement: BodyMeasurement) {
        currentWeight = measurement.weight
        currentBodyFat = measurement.bodyFat
        currentMuscleMass = measurement.muscleMass
        currentBMI = measurement.bmi
    }
    
    /// Load mock data for development
    private func loadMockData() {
        Task {
            await loadCurrentMeasurements()
            await loadMeasurementHistory()
            generateProgressData()
        }
    }
    
    /// Save measurement to Firestore
    private func saveMeasurementToFirestore(_ measurement: BodyMeasurement) {
        // In a real app, this would save to Firestore
        print("Saving measurement to Firestore: \(measurement)")
    }
}

// MARK: - Body Measurement Model
struct BodyMeasurement: Identifiable, Codable {
    let id = UUID()
    let weight: Double // in pounds
    let bodyFat: Double // percentage
    let muscleMass: Double // in pounds
    let height: Double // in inches
    let date: Date
    
    var bmi: Double {
        // BMI = (weight in pounds * 703) / (height in inches)^2
        return (weight * 703) / (height * height)
    }
    
    init(weight: Double, bodyFat: Double, muscleMass: Double, height: Double, date: Date) {
        self.weight = weight
        self.bodyFat = bodyFat
        self.muscleMass = muscleMass
        self.height = height
        self.date = date
    }
}

// MARK: - Body Progress Data Point Model
struct BodyProgressDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
