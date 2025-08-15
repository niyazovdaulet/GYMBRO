import SwiftUI

struct AddMeasurementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var weight: String = ""
    @State private var bodyFat: String = ""
    @State private var muscleMass: String = ""
    @State private var height: String = ""
    
    let onSave: (BodyMeasurement) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundAccent)
                    
                    Text("Add Body Measurement")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text("Track your progress with a new measurement")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 20) {
                    MeasurementField(
                        title: "Weight (lbs)",
                        value: $weight,
                        placeholder: "175.5",
                        icon: "scalemass.fill"
                    )
                    
                    MeasurementField(
                        title: "Body Fat (%)",
                        value: $bodyFat,
                        placeholder: "15.2",
                        icon: "person.fill"
                    )
                    
                    MeasurementField(
                        title: "Muscle Mass (lbs)",
                        value: $muscleMass,
                        placeholder: "140.3",
                        icon: "figure.strengthtraining.traditional"
                    )
                    
                    MeasurementField(
                        title: "Height (inches)",
                        value: $height,
                        placeholder: "70.0",
                        icon: "ruler"
                    )
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveMeasurement) {
                    Text("Save Measurement")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.undergroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.undergroundAccent)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
            .background(Color.undergroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.undergroundAccent)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private var isFormValid: Bool {
        !weight.isEmpty && !bodyFat.isEmpty && !muscleMass.isEmpty && !height.isEmpty
    }
    
    private func saveMeasurement() {
        guard let weightValue = Double(weight),
              let bodyFatValue = Double(bodyFat),
              let muscleMassValue = Double(muscleMass),
              let heightValue = Double(height) else {
            return
        }
        
        let measurement = BodyMeasurement(
            weight: weightValue,
            bodyFat: bodyFatValue,
            muscleMass: muscleMassValue,
            height: heightValue,
            date: Date()
        )
        
        onSave(measurement)
        dismiss()
    }
}

struct MeasurementField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.undergroundText)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color.undergroundAccent)
                    .frame(width: 24)
                
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
    }
}

#Preview {
    AddMeasurementView { measurement in
        print("Saved measurement: \(measurement)")
    }
}
