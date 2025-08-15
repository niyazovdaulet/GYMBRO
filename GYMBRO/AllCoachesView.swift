import SwiftUI

struct AllCoachesView: View {
    @StateObject private var viewModel = AllCoachesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with coaches info
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                            .frame(width: 60, height: 60)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Coaches")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(viewModel.coachCount) coaches")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                .background(Color(.systemGroupedBackground))
                
                // Content based on loading state
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading coaches...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    // Coaches list
                    List {
                        ForEach(viewModel.coaches) { coach in
                            CoachRowView(coach: coach, viewModel: viewModel)
                                .onTapGesture {
                                    viewModel.selectCoach(coach)
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
            .sheet(isPresented: $viewModel.showingCoachDetail) {
                if let coach = viewModel.selectedCoach {
                    CoachDetailView(coach: coach)
                }
            }
        }
    }
}

// MARK: - Coach Row View
struct CoachRowView: View {
    let coach: Coach
    let viewModel: AllCoachesViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Coach image
            Image(systemName: coach.imageName)
                .font(.system(size: 40))
                .foregroundColor(.green)
                .frame(width: 60, height: 60)
                .background(Color.green.opacity(0.1))
                .cornerRadius(30)
            
            // Coach details
            VStack(alignment: .leading, spacing: 4) {
                Text(coach.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(coach.yearsExperience) years experience")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Favorite button
            Button(action: {
                viewModel.toggleCoachFavorite(coach)
            }) {
                Image(systemName: coach.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(coach.isFavorite ? .red : .gray)
                    .font(.system(size: 18))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    AllCoachesView()
} 