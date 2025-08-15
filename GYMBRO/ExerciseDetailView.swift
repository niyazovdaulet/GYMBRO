import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @StateObject private var viewModel: ExerciseDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self._viewModel = StateObject(wrappedValue: ExerciseDetailViewModel(exercise: exercise))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Photo slides section
                    ZStack(alignment: .bottom) {
                        TabView(selection: $viewModel.currentPhotoIndex) {
                            ForEach(0..<viewModel.photoCount, id: \.self) { index in
                                Image(systemName: viewModel.exercisePhotos[index])
                                    .font(.system(size: 200))
                                    .foregroundColor(Color.undergroundAccent)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .background(Color.undergroundAccent.opacity(0.2))
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 300)
                        
                        // Page indicator
                        HStack(spacing: 8) {
                            ForEach(0..<viewModel.photoCount, id: \.self) { index in
                                Circle()
                                    .fill(viewModel.currentPhotoIndex == index ? Color.undergroundAccent : Color.undergroundAccent.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    
                    // Exercise details section
                    VStack(alignment: .leading, spacing: 20) {
                        // Title and category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.exerciseTitle)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.undergroundText)
                            
                            Text(viewModel.exerciseCategory)
                                .font(.title3)
                                .foregroundColor(Color.undergroundAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.undergroundAccent.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.undergroundText)
                            
                            Text(viewModel.exerciseDescription)
                                .font(.body)
                                .foregroundColor(Color.undergroundTextSecondary)
                                .lineLimit(nil)
                        }
                        
                        // YouTube video section (placeholder for now)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Instructions")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.undergroundText)
                            
                            // Placeholder for YouTube video
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.undergroundCard)
                                .frame(height: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.undergroundBorder, lineWidth: 1)
                                )
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color.undergroundAccentSecondary)
                                        
                                        Text("Video instructions will be added here")
                                            .font(.subheadline)
                                            .foregroundColor(Color.undergroundTextSecondary)
                                            .multilineTextAlignment(.center)
                                    }
                                )
                        }
                        
                        // Additional sections can be added here
                        // - Equipment needed
                        // - Muscle groups targeted
                        // - Difficulty level
                        // - Sets and reps recommendations
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(viewModel.isFavorite ? Color.undergroundAccent : Color.undergroundText)
                    }
                }
            }
            .background(Color.undergroundPrimary)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        Color.undergroundPrimary.opacity(0.8)
                            .ignoresSafeArea()
                        
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.undergroundAccent))
                            .scaleEffect(1.5)
                            .foregroundColor(Color.undergroundText)
                    }
                }
            )
        }
    }
}

#Preview {
    ExerciseDetailView(exercise: Exercise.mockExercises[0])
} 