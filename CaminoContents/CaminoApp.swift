import SwiftUI
import CaminoModels

@main
struct CaminoApp: App {
    @StateObject private var appState = CaminoAppState()
    @StateObject private var locationManager = LocationManager.shared
    @AppStorage("appTheme") private var appTheme = "System"
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .preferredColorScheme(selectedColorScheme)
        }
    }
    
    // Compute the preferred color scheme based on the user's selection
    private var selectedColorScheme: ColorScheme? {
        switch appTheme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default:
            return nil // System default
        }
    }
}

class CaminoAppState: ObservableObject {
    @Published var isShowingMap: Bool = false
    @Published var selectedTab: Int = 0
    @Published var selectedDestinationDay: Int? = nil // Track selected day for list highlighting etc.
    @Published var focusedRouteDay: Int? = nil // NEW: Track which day's route to show on main map
    @Published var initialMapTargetDay: Int? = nil // NEW: Track day to show on initial map load
    @Published var userSettings = UserSettings()
    @Published var routeProgress: Double = 0.0
    
    // This method is deprecated - use direct state changes instead
    func toggleMap() {
        withAnimation {
            isShowingMap.toggle()
            // Always set to Map tab when toggling from welcome screen
            if isShowingMap {
                selectedTab = 0
                initialMapTargetDay = 1 // Set initial target when toggling TO map
            } else {
                initialMapTargetDay = nil // Clear target when toggling AWAY from map (if needed)
            }
        }
    }
    
    // Helper method to show the map screen with the Map tab selected
    // Renamed to startJourney for clarity and specific purpose
    func startJourney() {
        withAnimation {
            initialMapTargetDay = 0 // Target Day 0 (St. Jean)
            isShowingMap = true     // Show the main view (which contains the map)
            selectedTab = 0         // Select the Map tab
        }
    }
}

struct UserSettings: Codable {
    var isDarkModeEnabled: Bool = false
    var preferredLanguage: String = "en"
    var useMetricSystem: Bool = true
    var notificationsEnabled: Bool = true
}