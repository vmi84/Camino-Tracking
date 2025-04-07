import SwiftUI
import MapKit

// MARK: - Views
struct ContentView: View {
    @State private var isShowingMap = false
    
    var body: some View {
        if isShowingMap {
            MapView()
                .ignoresSafeArea()
        } else {
            WelcomeView(isShowingMap: $isShowingMap)
        }
    }
}

struct WelcomeView: View {
    @Binding var isShowingMap: Bool
    
    var body: some View {
        ZStack {
            Image("CaminoWelcome")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.7)
            
            VStack(spacing: 20) {
                Text("Welcome to Camino")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                
                Text("Your journey along the Camino de Santiago begins here. Explore the route, track your progress, and discover the rich history of this ancient pilgrimage.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.primary)
                
                Button(action: {
                    withAnimation {
                        isShowingMap = true
                    }
                }) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .padding()
            )
        }
    }
}

#Preview {
    Group {
        ContentView()
            .environment(\.colorScheme, .light)
        
        ContentView()
            .environment(\.colorScheme, .dark)
    }
} 