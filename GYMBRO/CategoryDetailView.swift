import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    @StateObject private var viewModel: CategoryDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(category: Category) {
        self.category = category
        self._viewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with category info
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: category.imageName)
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                            .frame(width: 60, height: 60)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(viewModel.exerciseCount) exercises")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search bar
                    SearchBarView(searchText: $viewModel.searchText)
                }
                .padding(.top, 8)
                .background(Color(.systemGroupedBackground))
                
                // Content based on loading state
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading exercises...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    // Exercises list
                    List {
                        ForEach(viewModel.filteredExercises) { exercise in
                            CategoryExerciseRowView(exercise: exercise, viewModel: viewModel)
                                .onTapGesture {
                                    viewModel.selectExercise(exercise)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingExerciseDetail) {
                if let exercise = viewModel.selectedExercise {
                    ExerciseDetailView(exercise: exercise)
                }
            }
        }
    }
}

// MARK: - Exercise Row View for Category Detail
struct CategoryExerciseRowView: View {
    let exercise: Exercise
    let viewModel: CategoryDetailViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Exercise image
            Image(systemName: exercise.imageName)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            // Exercise details
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(exercise.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Favorite button
            Button(action: {
                viewModel.toggleExerciseFavorite(exercise)
            }) {
                Image(systemName: exercise.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(exercise.isFavorite ? .red : .gray)
                    .font(.system(size: 18))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    CategoryDetailView(category: Category.mockCategories[0])
} 