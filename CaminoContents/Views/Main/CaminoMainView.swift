import SwiftUI
import MapKit
import CoreLocation
import CaminoModels

// MARK: - CaminoMainView
struct CaminoMainView: View {
    @EnvironmentObject private var appState: CaminoAppState
    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var weatherTabWasTapped = false
    @State private var translateTabWasTapped = false
    @State private var selectedTabIndex: Int = 0
    
    // Add AppStorage for language settings
    @AppStorage("sourceLanguageCode") private var sourceLanguageCode = "en"
    @AppStorage("targetLanguageCode") private var targetLanguageCode = "es"
    
    var body: some View {
        // Always show the TabView with tabs - we don't need the conditional check here
        // since ContentView already handles showing WelcomeView vs. CaminoMainView
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
            
            EmptyView() // Use EmptyView instead of WeatherView to prevent loading it
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
                .tag(2)
            
            GoogleTranslateView()
                .tabItem {
                    Label("Translate", systemImage: "globe")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .onChange(of: appState.selectedTab) { oldValue, newValue in
            // Handle the Weather tab deep-linking
            if newValue == 2 {
                Task {
                    // Immediately try to open Apple Weather
                    await weatherViewModel.openWeatherForCurrentLocation()
                    
                    // Always switch back to the previous tab after a very short delay
                    try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                    
                    // Return to previous tab or Map tab if already on Weather
                    DispatchQueue.main.async {
                        if oldValue != 2 {
                            appState.selectedTab = oldValue
                        } else {
                            appState.selectedTab = 0 // Default to Map
                        }
                    }
                }
            }
            
            // Handle the Translate tab deep-linking
            if newValue == 3 && !translateTabWasTapped {
                translateTabWasTapped = true
                Task {
                    // Open Google Translate directly via URL using saved language settings
                    let translationService = TranslationService.shared
                    translationService.openGoogleTranslate(
                        text: "",
                        sourceLanguage: sourceLanguageCode,
                        targetLanguage: targetLanguageCode
                    )
                    // Reset the flag after a small delay
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    translateTabWasTapped = false
                }
            }
        }
        .tint(.blue)
    }
}

// Keep CaminoWelcomeView as a backup but it's not used in the main flow anymore
// We'll leave it here in case it's referenced elsewhere in the codebase
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
        Button(action: { 
            // Use the dedicated method for consistency
            appState.showMap()
        }) {
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