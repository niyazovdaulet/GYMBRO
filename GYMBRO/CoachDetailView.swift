import SwiftUI

struct CoachDetailView: View {
    let coach: Coach
    @StateObject private var viewModel: CoachDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(coach: Coach) {
        self.coach = coach
        self._viewModel = StateObject(wrappedValue: CoachDetailViewModel(coach: coach))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Coach header section
                    VStack(spacing: 20) {
                        // Coach image and basic info
                        VStack(spacing: 16) {
                            Image(systemName: viewModel.coachImageName)
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                                .frame(width: 120, height: 120)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(spacing: 8) {
                                Text(viewModel.coachName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(viewModel.coachExperience)
                                    .font(.title3)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                viewModel.contactCoach()
                            }) {
                                HStack {
                                    Image(systemName: "message.fill")
                                    Text("Contact")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                viewModel.bookSession()
                            }) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Book Session")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .background(Color(.systemGroupedBackground))
                    
                    // Coach details section
                    VStack(alignment: .leading, spacing: 24) {
                        // Bio section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(viewModel.coachBio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(nil)
                        }
                        
                        // Specialties section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specialties")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(viewModel.coachSpecialties, id: \.self) { specialty in
                                    Text(specialty)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Certifications section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Certifications")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.coachCertifications, id: \.self) { certification in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                        
                                        Text(certification)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        // Languages section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Languages")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 8) {
                                ForEach(viewModel.coachLanguages, id: \.self) { language in
                                    Text(language)
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Schedule section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Schedule")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Button(action: {
                                viewModel.viewSchedule()
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("View Available Times")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
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
                            .foregroundColor(viewModel.isFavorite ? .red : .primary)
                    }
                }
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                }
            )
        }
    }
}

#Preview {
    CoachDetailView(coach: Coach.mockCoaches[0])
} 