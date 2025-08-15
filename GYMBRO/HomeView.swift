import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Simple Welcome Message
                VStack(spacing: 24) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.undergroundAccent)
                        .undergroundGlow()
                    
                    VStack(spacing: 16) {
                        Text("Home")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(Color.undergroundText)
                        
                        Text("Welcome to your fitness dashboard")
                            .font(.title2)
                            .foregroundColor(Color.undergroundTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Coming Soon Message
                VStack(spacing: 16) {
                    Image(systemName: "clock.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("Coming Soon...")
                        .font(.headline)
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("This section is being developed with exciting new features!")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
                .background(Color.undergroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.undergroundBorder, lineWidth: 1)
                )
                
                Spacer()
            }
            .padding(.horizontal)
            .background(Color.undergroundPrimary)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HomeView()
} 
