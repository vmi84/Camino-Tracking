import SwiftUI

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
    @Published var userSettings = UserSettings()
    @Published var routeProgress: Double = 0.0
    
    func toggleMap() {
        withAnimation {
            isShowingMap.toggle()
        }
    }
}

struct UserSettings: Codable {
    var isDarkModeEnabled: Bool = false
    var preferredLanguage: String = "en"
    var useMetricSystem: Bool = true
    var notificationsEnabled: Bool = true
}