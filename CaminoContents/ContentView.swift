import MapKit
import CoreLocation
import SwiftUI
#if canImport(CaminoModels)
#if canImport(CaminoModels)
import CaminoModels
#endif
#endif

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject private var appState: CaminoAppState
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        Group {
            if appState.isShowingMap {
                CaminoMainView()
            } else {
                WelcomeView()
            }
        }
    }
}

// MARK: - WelcomeView
struct WelcomeView: View {
    @EnvironmentObject private var appState: CaminoAppState
    
    var body: some View {
        ZStack {
            // Background image
            Image("CaminoWelcome")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Content overlay
            VStack(spacing: 0) {
                // Church icon at top
                Image("CaminoChurch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding(.top, 40)
                
                // Welcome panel - oval shape at top
                VStack(spacing: 4) {
                    Text("Welcome to Camino")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Text("Your journey along the Camino de Santiago begins here. Explore the route, track your progress, and discover the rich history of this ancient pilgrimage.")
                        .font(.body)
                        .lineSpacing(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    Capsule()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color.white.opacity(0.85),
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ]
                                ),
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            
            // Start button at bottom - explicitly positioned and brought to front
            VStack {
                Spacer()
                
                Button(action: { 
                    // Use the dedicated method to show map and set tab
                    appState.showMap()
                }) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(25)
                        .shadow(radius: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .accessibilityHint("Tap to begin your Camino journey")
            }
            .zIndex(1) // Bring button to front
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Welcome to Camino")
        #if os(iOS)
        .statusBar(hidden: true) // Hide status bar for immersive experience
        #endif
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CaminoAppState())
            .environmentObject(LocationManager.shared)
    }
}

#Preview("Welcome Screen") {
    ContentView()
        .environmentObject(CaminoAppState())
        .environmentObject(LocationManager.shared)
} 
