import SwiftUI

// MARK: - Exercise Card View
struct ExerciseCardView: View {
    let exercise: Exercise
    let onFavoriteToggle: ((Exercise) -> Void)?
    
    init(exercise: Exercise, onFavoriteToggle: ((Exercise) -> Void)? = nil) {
        self.exercise = exercise
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: exercise.imageName)
                    .font(.system(size: 40))
                    .foregroundColor(Color.undergroundAccent)
                    .frame(width: 120, height: 80)
                    .background(Color.undergroundAccent.opacity(0.2))
                    .cornerRadius(12)
                    .undergroundGlow()
                
                Button(action: {
                    onFavoriteToggle?(exercise)
                }) {
                    Image(systemName: exercise.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(exercise.isFavorite ? Color.undergroundAccent : Color.undergroundTextSecondary)
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Color.undergroundCard)
                        .clipShape(Circle())
                        .shadow(color: Color.undergroundShadow, radius: 2)
                }
                .offset(x: -8, y: 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(Color.undergroundText)
                
                Text(exercise.category)
                    .font(.caption)
                    .foregroundColor(Color.undergroundAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.undergroundAccent.opacity(0.2))
                    .cornerRadius(4)
                
                Text(exercise.description)
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
                    .lineLimit(2)
            }
        }
        .frame(width: 160)
        .padding(12)
        .undergroundCard()
    }
}

// MARK: - Coach Card View
struct CoachCardView: View {
    let coach: Coach
    let onFavoriteToggle: ((Coach) -> Void)?
    
    init(coach: Coach, onFavoriteToggle: ((Coach) -> Void)? = nil) {
        self.coach = coach
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: coach.imageName)
                    .font(.system(size: 50))
                    .foregroundColor(Color.undergroundAccentSecondary)
                    .frame(width: 120, height: 80)
                    .background(Color.undergroundAccentSecondary.opacity(0.2))
                    .cornerRadius(12)
                    .undergroundGlow(color: Color.undergroundAccentSecondary)
                
                Button(action: {
                    onFavoriteToggle?(coach)
                }) {
                    Image(systemName: coach.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(coach.isFavorite ? Color.undergroundAccentSecondary : Color.undergroundTextSecondary)
                        .font(.system(size: 16))
                        .padding(8)
                        .background(Color.undergroundCard)
                        .clipShape(Circle())
                        .shadow(color: Color.undergroundShadow, radius: 2)
                }
                .offset(x: -8, y: 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coach.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(Color.undergroundText)
                
                Text("\(coach.yearsExperience) years experience")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
        }
        .frame(width: 160)
        .padding(12)
        .undergroundCard()
    }
}

// MARK: - Category Card View
struct CategoryCardView: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.imageName)
                .font(.system(size: 30))
                .foregroundColor(Color.undergroundAccentTertiary)
                .frame(width: 60, height: 60)
                .background(Color.undergroundAccentTertiary.opacity(0.2))
                .clipShape(Circle())
                .undergroundGlow(color: Color.undergroundAccentTertiary)
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.undergroundText)
        }
        .frame(width: 100, height: 100)
        .padding(12)
        .undergroundCard()
    }
}

// MARK: - Section Header View
struct SectionHeaderView: View {
    let title: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
            
            Spacer()
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.subheadline)
                    .foregroundColor(Color.undergroundAccent)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.undergroundTextSecondary)
            
            TextField("Search exercises, coaches...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Color.undergroundText)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.undergroundTextSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
        .padding(.horizontal)
    }
} 