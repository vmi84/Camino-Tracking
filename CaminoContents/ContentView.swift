import MapKit
import CoreLocation
import SwiftUI
import CaminoModels

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject private var appState: CaminoAppState
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        Group {
            if appState.isShowingMap {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    @EnvironmentObject private var appState: CaminoAppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            ZStack {
                MapView()
                    .edgesIgnoringSafeArea(.top)
                VStack {
                    Spacer()
                    Color.clear.frame(height: 0)
                }
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(0)
            
            DestinationsView()
                .tabItem {
                    Label("Destinations", systemImage: "list.bullet")
                }
                .tag(1)
            
            WeatherView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
                .tag(2)
            
            TranslationView()
                .tabItem {
                    Label("Translator", systemImage: "character.bubble")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {

                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(.blue)
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
                    appState.toggleMap() 
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
        .statusBar(hidden: true) // Hide status bar for immersive experience
    }
}

#Preview {
    ContentView()
        .environmentObject(CaminoAppState())
        .environmentObject(LocationManager.shared)
} 
