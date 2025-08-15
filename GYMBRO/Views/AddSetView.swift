import SwiftUI

struct AddSetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reps = ""
    @State private var weight = ""
    @State private var includeWeight = false
    @State private var useRepRange = false
    @State private var minReps = ""
    @State private var maxReps = ""
    @State private var isFailure = false
    let onSave: (Int, RepRange?, Double?, Bool) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color.undergroundAccent)
                        .undergroundGlow()
                    
                    Text("Add New Set")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text("Enter your set details below")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 20) {
                    // Rep Range Toggle
                    Toggle("Use Rep Range (e.g., 8-12)", isOn: $useRepRange)
                        .foregroundColor(Color.undergroundText)
                        .tint(Color.undergroundAccent)
                    
                    if useRepRange {
                        // Rep Range Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Rep Range")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            HStack(spacing: 12) {
                                TextField("Min", text: $minReps)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.numberPad)
                                
                                Text("-")
                                    .foregroundColor(Color.undergroundText)
                                    .font(.headline)
                                
                                TextField("Max", text: $maxReps)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                        }
                        
                        // Actual Reps Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Actual Reps Completed")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            TextField("Number of reps completed", text: $reps)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        // Failure Toggle
                        Toggle("Failed to complete target reps", isOn: $isFailure)
                            .foregroundColor(Color.undergroundText)
                            .tint(Color.undergroundAccentSecondary)
                    } else {
                        // Standard Reps Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reps")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            TextField("Number of reps", text: $reps)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    // Weight Toggle
                    Toggle("Include Weight", isOn: $includeWeight)
                        .foregroundColor(Color.undergroundText)
                        .tint(Color.undergroundAccent)
                    
                    // Weight Input (conditional)
                    if includeWeight {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weight (lbs)")
                                .font(.headline)
                                .foregroundColor(Color.undergroundText)
                            
                            TextField("Weight in pounds", text: $weight)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveSet) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Add Set")
                        }
                        .font(.headline)
                        .foregroundColor(Color.undergroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isFormValid ? Color.undergroundAccent : Color.undergroundTextMuted)
                        .cornerRadius(12)
                        .undergroundGlow()
                    }
                    .disabled(!isFormValid)
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(Color.undergroundAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.undergroundCard)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.undergroundAccent, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color.undergroundPrimary)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        guard let repsInt = Int(reps), repsInt > 0 else { return false }
        
        if useRepRange {
            guard let minRepsInt = Int(minReps), minRepsInt > 0,
                  let maxRepsInt = Int(maxReps), maxRepsInt > 0,
                  maxRepsInt >= minRepsInt else { return false }
        }
        
        if includeWeight {
            guard let weightDouble = Double(weight), weightDouble >= 0 else { return false }
        }
        
        return true
    }
    
    // MARK: - Methods
    
    private func saveSet() {
        guard let repsInt = Int(reps), repsInt > 0 else { return }
        
        var weightDouble: Double?
        if includeWeight, let weightValue = Double(weight) {
            weightDouble = weightValue
        }
        
        var repRange: RepRange?
        if useRepRange {
            guard let minRepsInt = Int(minReps), minRepsInt > 0,
                  let maxRepsInt = Int(maxReps), maxRepsInt > 0 else { return }
            repRange = RepRange(min: minRepsInt, max: maxRepsInt)
        }
        
        onSave(repsInt, repRange, weightDouble, isFailure)
    }
}

#Preview {
    AddSetView { reps, repRange, weight, isFailure in
        print("Added set: \(reps) reps, range: \(repRange?.description ?? "none"), weight: \(weight?.description ?? "no weight"), failure: \(isFailure)")
    }
} 