import SwiftUI
import MapKit
import CoreLocation
import CaminoModels

// MARK: - CaminoMainView
struct CaminoMainView: View {
    @EnvironmentObject private var appState: CaminoAppState
    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var weatherTabWasTapped = false
    
    var body: some View {
        if !appState.isShowingMap {
            CaminoWelcomeView()
        } else {
            TabView(selection: $appState.selectedTab) {
                MapView()
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
                    .onChange(of: appState.selectedTab) { _, newValue in
                        if newValue == 2 {
                            // When Weather tab is selected, immediately open Apple Weather
                            // Use immediate execution and a flag to prevent multiple taps
                            if !weatherTabWasTapped {
                                weatherTabWasTapped = true
                                Task { @MainActor in
                                    weatherViewModel.openWeatherForCurrentLocation()
                                    // Reset the flag after a small delay to allow for future taps
                                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                                    weatherTabWasTapped = false
                                }
                            }
                        }
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)

                GoogleTranslateView()
                    .tabItem {
                        Label("Translate", systemImage: "globe")
                    }
                    .tag(4)
            }
            .tint(.blue)
        }
    }
}

// MARK: - CaminoWelcomeView
struct CaminoWelcomeView: View {
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
    CaminoMainView()
        .environmentObject(CaminoAppState())
        .environmentObject(LocationManager.shared)
} 