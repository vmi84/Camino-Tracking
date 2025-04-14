import SwiftUI
import MapKit
#if canImport(CaminoModels)
import CaminoModels
#else
// Use the shim types when CaminoModels can't be imported
#endif
import CoreLocation

// MARK: - CaminoMainView
struct CaminoMainView: View {
    #if canImport(CaminoModels)
    @EnvironmentObject private var appState: CaminoAppState
    #else
    @EnvironmentObject private var appState: ShimCaminoAppState
    #endif
    @State private var weatherTabWasTapped = false
    @State private var translateTabWasTapped = false
    @State private var selectedTabIndex: Int = 0
    @StateObject private var alertManager = AlertManager()
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    // Add AppStorage for language settings
    @AppStorage("sourceLanguageCode") private var sourceLanguageCode = "en"
    @AppStorage("targetLanguageCode") private var targetLanguageCode = "es"
    
    var body: some View {
        NavigationView {
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
                
                AppleWeatherView()
                    .tabItem {
                        Label("Weather", systemImage: "cloud.sun")
                    }
                    .tag(2)
                    .environmentObject(weatherViewModel)
                
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
                // Handle Weather tab selection - open Weather app when tab is selected
                if newValue == 2 {
                    weatherViewModel.tabWasSelected()
                }
                
                // We're no longer auto-deep-linking to Google Translate
                // Let the GoogleTranslateView handle this internally
            }
            .tint(.blue)
        }
        .withErrorAlert(alertManager: alertManager)
        .environmentObject(alertManager)
    }
}

// Keep CaminoWelcomeView as a backup but it's not used in the main flow anymore
// We'll leave it here in case it's referenced elsewhere in the codebase
struct CaminoWelcomeView: View {
    #if canImport(CaminoModels)
    @EnvironmentObject private var appState: CaminoAppState
    #else
    @EnvironmentObject private var appState: ShimCaminoAppState
    #endif
    @EnvironmentObject private var alertManager: AlertManager
    
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
    #if canImport(CaminoModels)
    CaminoMainView()
        .environmentObject(CaminoAppState())
        .environmentObject(LocationManager.shared)
        .environmentObject(AlertManager())
    #else
    CaminoMainView()
        .environmentObject(ShimCaminoAppState())
        .environmentObject(LocationManager.shared)
        .environmentObject(AlertManager())
    #endif
} 