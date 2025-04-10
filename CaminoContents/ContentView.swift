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
            
            Text("Weather")
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
                .tag(2)
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
            
            Text("Settings")
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
            Image("CaminoWelcome")
                .resizable()
                .aspectRatio(1.2, contentMode: .fill)
                .scaleEffect(0.6)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.8)
            
            VStack(spacing: 0) {
                startButton
                Spacer()
                welcomeInfoCard
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Welcome to Camino")
    }
    
    private var startButton: some View {
        Button(action: { appState.toggleMap() }) {
            Text("Start Your Journey")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .accessibilityHint("Tap to begin your Camino journey")
    }
    
    private var welcomeInfoCard: some View {
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
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.98))
        )
        .padding(.horizontal, 80)
        .padding(.bottom, 40)
    }
}

#Preview {
    ContentView()
        .environmentObject(CaminoAppState())
        .environmentObject(LocationManager.shared)
} 