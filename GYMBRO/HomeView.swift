import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    }
                } else if !viewModel.exercises.isEmpty {
                    ScrollView {
                                            VStack(spacing: 24) {
                        // Greeting Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hello \(viewModel.userName)!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.undergroundText)
                                
                                Text("We have some recommendations for you.")
                                    .font(.subheadline)
                                    .foregroundColor(Color.undergroundTextSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            // Popular Exercises Section
                            VStack(spacing: 16) {
                                SectionHeaderView(
                                    title: "Popular Exercises",
                                    actionTitle: "See All"
                                ) {
                                    viewModel.showPopularExercises()
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(viewModel.exercises) { exercise in
                                            ExerciseCardView(
                                                exercise: exercise,
                                                onFavoriteToggle: { exercise in
                                                    viewModel.toggleExerciseFavorite(exercise)
                                                }
                                            )
                                            .onTapGesture {
                                                viewModel.selectExercise(exercise)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Coaches Section
                            VStack(spacing: 16) {
                                SectionHeaderView(
                                    title: "Coaches",
                                    actionTitle: "See All"
                                ) {
                                    viewModel.showAllCoaches()
                                }
                                
                                                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(viewModel.coaches) { coach in
                                    CoachCardView(
                                        coach: coach,
                                        onFavoriteToggle: { coach in
                                            viewModel.toggleCoachFavorite(coach)
                                        }
                                    )
                                    .onTapGesture {
                                        viewModel.selectCoach(coach)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                            }
                            
                            // Categories Section
                            VStack(spacing: 16) {
                                SectionHeaderView(
                                    title: "Categories",
                                    actionTitle: "See All"
                                ) {
                                    viewModel.showAllCategories()
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(viewModel.categories) { category in
                                            CategoryCardView(category: category)
                                                .onTapGesture {
                                                    viewModel.selectCategory(category)
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Bottom spacing
                                                    Spacer(minLength: 20)
                    }
                }
            } else {
                // Show error state
                VStack {
                    Spacer()
                    ErrorView(message: "Failed to load exercises. Please check your internet connection.") {
                        // Retry loading data
                        viewModel.loadData()
                    }
                    Spacer()
                }
            }
            }
            .background(Color.undergroundPrimary)
            .sheet(isPresented: $viewModel.showingCategoryDetail) {
                if let category = viewModel.selectedCategory {
                    CategoryDetailView(category: category)
                }
            }
            .sheet(isPresented: $viewModel.showingPopularExercises) {
                PopularExercisesView()
            }
            .sheet(isPresented: $viewModel.showingAllCoaches) {
                AllCoachesView()
            }
            .sheet(isPresented: $viewModel.showingAllCategories) {
                AllCategoriesView()
            }
            .sheet(isPresented: $viewModel.showingExerciseDetail) {
                if let exercise = viewModel.selectedExercise {
                    ExerciseDetailView(exercise: exercise)
                }
            }
            .sheet(isPresented: $viewModel.showingCoachDetail) {
                if let coach = viewModel.selectedCoach {
                    CoachDetailView(coach: coach)
                }
            }
        }
    }
}

#Preview {
    HomeView()
} 
