import SwiftUI

struct ExerciseSearchView: View {
    @StateObject private var viewModel = ExerciseSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    let onExerciseSelected: (Exercise) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(searchText: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Filters
                filterSection
                
                // Results
                exerciseResultsSection
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.undergroundAccent)
                }
            }
            .onChange(of: viewModel.searchText) { _ in
                Task {
                    await viewModel.searchExercises()
                }
            }
            .onChange(of: viewModel.selectedBodyPart) { _ in
                Task {
                    await viewModel.searchExercises()
                }
            }
            .onChange(of: viewModel.selectedEquipment) { _ in
                Task {
                    await viewModel.searchExercises()
                }
            }
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Body Part Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Body Part")
                    .font(.headline)
                    .foregroundColor(Color.undergroundText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedBodyPart == nil
                        ) {
                            viewModel.selectedBodyPart = nil
                        }
                        
                        ForEach(viewModel.bodyParts, id: \.self) { bodyPart in
                            FilterChip(
                                title: bodyPart,
                                isSelected: viewModel.selectedBodyPart == bodyPart
                            ) {
                                viewModel.selectedBodyPart = bodyPart
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Equipment Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Equipment")
                    .font(.headline)
                    .foregroundColor(Color.undergroundText)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedEquipment == nil
                        ) {
                            viewModel.selectedEquipment = nil
                        }
                        
                        ForEach(viewModel.equipment, id: \.self) { equipment in
                            FilterChip(
                                title: equipment,
                                isSelected: viewModel.selectedEquipment == equipment
                            ) {
                                viewModel.selectedEquipment = equipment
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Exercise Results Section
    private var exerciseResultsSection: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Searching exercises...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.undergroundAccent))
                        .foregroundColor(Color.undergroundText)
                    Spacer()
                }
            } else if viewModel.exercises.isEmpty && !viewModel.searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("No exercises found")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.exercises) { exercise in
                            ExerciseSearchCard(exercise: exercise) {
                                onExerciseSelected(exercise)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? Color.undergroundPrimary : Color.undergroundAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.undergroundAccent : Color.undergroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.undergroundAccent, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Exercise Search Card
struct ExerciseSearchCard: View {
    let exercise: Exercise
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: exercise.imageName)
                    .font(.system(size: 24))
                    .foregroundColor(Color.undergroundAccent)
                    .frame(width: 40, height: 40)
                    .background(Color.undergroundAccent.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.undergroundText)
                        .lineLimit(1)
                    
                    Text(exercise.category)
                        .font(.caption)
                        .foregroundColor(Color.undergroundAccent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.undergroundAccent.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color.undergroundAccent)
                    .font(.title2)
            }
            .padding(12)
            .background(Color.undergroundCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ExerciseSearchView { exercise in
        print("Selected: \(exercise.title)")
    }
} 