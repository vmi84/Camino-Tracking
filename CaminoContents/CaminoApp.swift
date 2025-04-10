import SwiftUI

@main
struct CaminoApp: App {
    @StateObject private var appState = CaminoAppState()
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
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