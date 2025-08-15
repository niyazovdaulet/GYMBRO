import SwiftUI

struct AllCategoriesView: View {
    @StateObject private var viewModel = AllCategoriesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with categories info
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                            .frame(width: 60, height: 60)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Categories")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(viewModel.categoryCount) categories")
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
                    ProgressView("Loading categories...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    // Categories grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.categories) { category in
                                CategoryGridItemView(category: category, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
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
            .sheet(isPresented: $viewModel.showingCategoryDetail) {
                if let category = viewModel.selectedCategory {
                    CategoryDetailView(category: category)
                }
            }
        }
    }
}

// MARK: - Category Grid Item View
struct CategoryGridItemView: View {
    let category: Category
    let viewModel: AllCategoriesViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: category.imageName)
                .font(.system(size: 30))
                .foregroundColor(.orange)
                .frame(width: 60, height: 60)
                .background(Color.orange.opacity(0.1))
                .clipShape(Circle())
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 100)
        .padding(12)
        .background(Color.black)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectCategory(category)
        }
    }
}

#Preview {
    AllCategoriesView()
} 
