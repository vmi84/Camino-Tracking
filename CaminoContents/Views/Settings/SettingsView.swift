import SwiftUI

// MARK: - Settings Models
struct SettingsSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String?
    let type: SettingsItemType
}

enum SettingsItemType {
    case toggle(Binding<Bool>)
    case picker([String], Binding<String>)
    case button(() -> Void)
    case navigationLink(destination: AnyView)
    case info(String)
}

// MARK: - Settings View
struct SettingsView: View {
    // General Settings
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("language") private var language = "English"
    @AppStorage("appTheme") private var appTheme = "System"
    
    // Map Settings
    @AppStorage("offlineMode") private var offlineMode = false
    @AppStorage("mapStyle") private var mapStyle = "Standard"
    
    // Tracking Settings
    @AppStorage("gpsUpdateInterval") private var gpsUpdateInterval = "10 seconds"
    @AppStorage("offRouteNotifications") private var offRouteNotifications = true
    @AppStorage("weatherNotifications") private var weatherNotifications = true
    
    // Weather Settings
    @AppStorage("weatherUpdateFrequency") private var weatherUpdateFrequency = "15 minutes"
    @AppStorage("useCelsius") private var useCelsius = true
    
    // Options arrays
    private let languages = ["English", "Spanish"]
    private let mapStyles = ["Standard", "Satellite", "Hybrid"]
    private let gpsIntervals = ["5 seconds", "10 seconds", "30 seconds", "1 minute"]
    private let weatherUpdateIntervals = ["15 minutes", "30 minutes", "1 hour", "3 hours"]
    private let themeOptions = ["Light", "Dark", "System"]
    
    @State private var showingBackupOptions = false
    @State private var showingClearCacheOptions = false
    @State private var showingAboutInfo = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var sections: [SettingsSection] {
        [
            SettingsSection(title: "General", items: [
                SettingsItem(title: "Distance (kilometers)", icon: "ruler", type: .toggle($useMetricUnits)),
                SettingsItem(title: "Language", icon: "globe", type: .picker(languages, $language)),
                SettingsItem(title: "Appearance", icon: "circle.lefthalf.filled", type: .picker(themeOptions, $appTheme))
            ]),
            
            SettingsSection(title: "Map", items: [
                SettingsItem(title: "Offline Mode", icon: "wifi.slash", type: .toggle($offlineMode)),
                SettingsItem(title: "Map Style", icon: "map", type: .picker(mapStyles, $mapStyle))
            ]),
            
            SettingsSection(title: "Tracking", items: [
                SettingsItem(title: "GPS Update Frequency", icon: "location", type: .picker(gpsIntervals, $gpsUpdateInterval)),
                SettingsItem(title: "Off-Route Notifications", icon: "exclamationmark.triangle", type: .toggle($offRouteNotifications)),
                SettingsItem(title: "Weather Alerts", icon: "cloud.bolt.rain", type: .toggle($weatherNotifications))
            ]),
            
            SettingsSection(title: "Weather", items: [
                SettingsItem(title: "Update Frequency", icon: "clock.arrow.circlepath", type: .picker(weatherUpdateIntervals, $weatherUpdateFrequency)),
                SettingsItem(title: "Temperature (celsius)", icon: "thermometer", type: .toggle($useCelsius))
            ]),
            
            SettingsSection(title: "Data Management", items: [
                SettingsItem(title: "Backup & Restore", icon: "arrow.clockwise.icloud", type: .button({
                    showingBackupOptions = true
                })),
                SettingsItem(title: "Clear Cache", icon: "trash", type: .button({
                    showingClearCacheOptions = true
                }))
            ]),
            
            SettingsSection(title: "About", items: [
                SettingsItem(title: "Version", icon: "info.circle", type: .info(appVersion)),
                SettingsItem(title: "Camino Resources", icon: "link", type: .button({
                    showingAboutInfo = true
                })),
                SettingsItem(title: "Developer Info", icon: "person.fill", type: .info("Built by Camino Tracking Team"))
            ])
        ]
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items) { item in
                            settingsRow(for: item)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(selectedColorScheme)
            .confirmationDialog("Backup & Restore", isPresented: $showingBackupOptions, titleVisibility: .visible) {
                Button("Backup to Cloud") { performBackup() }
                Button("Restore from Cloud") { performRestore() }
                Button("Export Data") { exportData() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Choose an option")
            }
            .confirmationDialog("Clear Cache", isPresented: $showingClearCacheOptions, titleVisibility: .visible) {
                Button("Clear Offline Maps", role: .destructive) { clearOfflineMaps() }
                Button("Clear Weather Data", role: .destructive) { clearWeatherData() }
                Button("Clear Photo Cache", role: .destructive) { clearPhotoCache() }
                Button("Clear All Cache", role: .destructive) { clearAllCache() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("What would you like to clear?")
            }
            .sheet(isPresented: $showingAboutInfo) {
                AboutView()
                    .preferredColorScheme(selectedColorScheme)
            }
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
    
    @ViewBuilder
    private func settingsRow(for item: SettingsItem) -> some View {
        switch item.type {
        case .toggle(let binding):
            Toggle(isOn: binding) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .foregroundColor(.blue)
                            .frame(width: 25)
                    }
                    Text(item.title)
                }
            }
            
        case .picker(let options, let selection):
            NavigationLink(destination: pickerView(title: item.title, options: options, selection: selection)) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .foregroundColor(.blue)
                            .frame(width: 25)
                    }
                    Text(item.title)
                    Spacer()
                    Text(selection.wrappedValue)
                        .foregroundColor(.gray)
                }
            }
            
        case .button(let action):
            Button(action: action) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .foregroundColor(.blue)
                            .frame(width: 25)
                    }
                    Text(item.title)
                        .foregroundColor(.primary)
                }
            }
            
        case .navigationLink(let destination):
            NavigationLink(destination: destination) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .foregroundColor(.blue)
                            .frame(width: 25)
                    }
                    Text(item.title)
                }
            }
            
        case .info(let detail):
            HStack {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 25)
                }
                Text(item.title)
                Spacer()
                if !detail.isEmpty {
                    Text(detail)
                        .foregroundColor(.gray)
                }
            }
            .foregroundColor(.gray)
        }
    }
    
    private func pickerView(title: String, options: [String], selection: Binding<String>) -> some View {
        Form {
            Section(header: Text(title)) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection.wrappedValue = option
                    }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if selection.wrappedValue == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle(title)
        .preferredColorScheme(selectedColorScheme)
    }
    
    // MARK: - Action Methods
    
    private func performBackup() {
        // Implement backup to cloud functionality
        print("Backing up data to cloud...")
    }
    
    private func performRestore() {
        // Implement restore from cloud functionality
        print("Restoring data from cloud...")
    }
    
    private func exportData() {
        // Implement data export functionality
        print("Exporting data...")
    }
    
    private func clearOfflineMaps() {
        // Implement clearing offline maps
        print("Clearing offline maps...")
    }
    
    private func clearWeatherData() {
        // Implement clearing weather data
        print("Clearing weather data...")
    }
    
    private func clearPhotoCache() {
        // Implement clearing photo cache
        print("Clearing photo cache...")
    }
    
    private func clearAllCache() {
        clearOfflineMaps()
        clearWeatherData()
        clearPhotoCache()
        print("All cache cleared.")
    }
}

// MARK: - About View
struct AboutView: View {
    let caminoResources = [
        ("Pilgrim.es", "https://pilgrim.es"),
        ("Camino de Santiago Forum", "https://www.caminodesantiago.me"),
        ("American Pilgrims", "https://americanpilgrims.org"),
        ("Camino Ways", "https://caminoways.com")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Camino Resources")) {
                    ForEach(caminoResources, id: \.0) { resource in
                        Link(destination: URL(string: resource.1)!) {
                            HStack {
                                Text(resource.0)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("About This App")) {
                    Text("Camino Tracking App helps pilgrims on the Camino de Santiago track their journey, check weather conditions, and manage their pilgrimage experience.")
                        .font(.body)
                        .padding(.vertical, 4)
                    
                    Text("Developed with SwiftUI and WeatherKit.\nAll rights reserved © 2025")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        // Close the sheet
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 