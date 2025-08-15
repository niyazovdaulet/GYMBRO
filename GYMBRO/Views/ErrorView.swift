import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color.undergroundAccentSecondary)
                .undergroundGlow(color: Color.undergroundAccentSecondary)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.undergroundText)
            
            Text(message)
                .font(.body)
                .foregroundColor(Color.undergroundTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.headline)
                .foregroundColor(Color.undergroundPrimary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.undergroundAccent)
                .cornerRadius(8)
                .undergroundGlow()
            }
        }
        .padding()
        .background(Color.undergroundCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

#Preview {
    ErrorView(message: "Failed to load exercises. Please check your internet connection.") {
        print("Retry tapped")
    }
} 