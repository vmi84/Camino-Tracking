import SwiftUI

// MARK: - Settings Models
struct SettingsSection: Identifiable {
    let id = UUID()
    let title: String
    let description: String
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
    
    // Translation Settings
    @AppStorage("sourceLanguageCode") private var sourceLanguageCode = "en"
    @AppStorage("targetLanguageCode") private var targetLanguageCode = "es"
    
    // Options arrays
    private let languages = ["English", "Spanish"]
    private let mapStyles = ["Standard", "Satellite", "Hybrid"]
    private let gpsIntervals = ["5 seconds", "10 seconds", "30 seconds", "1 minute"]
    private let weatherUpdateIntervals = ["15 minutes", "30 minutes", "1 hour", "3 hours"]
    
    // Translation language options
    private let translationLanguages = [
        ("en", "English"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("it", "Italian"),
        ("de", "German"),
        ("pt", "Portuguese"),
        ("ru", "Russian")
    ]
    
    @State private var showingBackupOptions = false
    @State private var showingClearCacheOptions = false
    @State private var showingAboutInfo = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    private var sections: [SettingsSection] {
        [
            SettingsSection(title: "General", 
                description: "Configure basic app preferences including unit system and language options for your Camino journey.",
                items: [
                SettingsItem(title: "Distance (km)", icon: "ruler", type: .toggle($useMetricUnits)),
                SettingsItem(title: "Language", icon: "globe", type: .picker(languages, $language))
            ]),
            
            SettingsSection(title: "Map", 
                description: "Customize your map experience with different display styles and offline capabilities for areas with limited connectivity.",
                items: [
                SettingsItem(title: "Offline Mode", icon: "wifi.slash", type: .toggle($offlineMode)),
                SettingsItem(title: "Map Style", icon: "map", type: .picker(mapStyles, $mapStyle))
            ]),
            
            SettingsSection(title: "Translation", 
                description: "Set your preferred source and target languages for the translation feature.",
                items: [
                SettingsItem(title: "From Language", icon: "arrow.up.forward.circle", type: .navigationLink(
                    destination: AnyView(languagePickerView(title: "From Language", languageCodes: translationLanguages, selection: $sourceLanguageCode))
                )),
                SettingsItem(title: "To Language", icon: "arrow.down.forward.circle", type: .navigationLink(
                    destination: AnyView(languagePickerView(title: "To Language", languageCodes: translationLanguages, selection: $targetLanguageCode))
                ))
            ]),
            
            SettingsSection(title: "Tracking", 
                description: "Control how frequently your location updates and receive notifications about route changes and weather conditions.",
                items: [
                SettingsItem(title: "GPS Update Frequency", icon: "location", type: .picker(gpsIntervals, $gpsUpdateInterval)),
                SettingsItem(title: "Off-Route Notifications", icon: "exclamationmark.triangle", type: .toggle($offRouteNotifications)),
                SettingsItem(title: "Weather Alerts", icon: "cloud.bolt.rain", type: .toggle($weatherNotifications))
            ]),
            
            SettingsSection(title: "Weather", 
                description: "Configure weather information display preferences and update frequency to stay prepared for changing conditions.",
                items: [
                SettingsItem(title: "Update Frequency", icon: "clock.arrow.circlepath", type: .picker(weatherUpdateIntervals, $weatherUpdateFrequency)),
                SettingsItem(title: "Use Celsius (°C)", icon: "thermometer", type: .toggle($useCelsius))
            ]),
            
            SettingsSection(
                title: "Data Management", 
                description: "Tools for backing up your journey data, restoring from previous backups, and clearing cached information to free up storage space.",
                items: [
                    SettingsItem(title: "Backup & Restore", icon: "arrow.clockwise.icloud", type: .button({
                        showingBackupOptions = true
                    })),
                    SettingsItem(title: "Clear Cache", icon: "trash", type: .button({
                        showingClearCacheOptions = true
                    })),
                    SettingsItem(title: "How to Backup", icon: "doc.text.magnifyingglass", type: .navigationLink(destination: AnyView(BackupHowToView())))
                ]
            ),
            
            SettingsSection(title: "About", 
                description: "Information about the app, useful Camino resources, and developer details.",
                items: [
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
                    Section(header: Text(section.title), footer: Text(section.description)) {
                        ForEach(section.items) { item in
                            settingsRow(for: item)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
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
            }
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
            if item.title == "From Language" {
                NavigationLink(destination: destination) {
                    HStack {
                        if let icon = item.icon {
                            Image(systemName: icon)
                                .foregroundColor(.blue)
                                .frame(width: 25)
                        }
                        Text(item.title)
                        Spacer()
                        Text(languageNameFor(code: sourceLanguageCode))
                            .foregroundColor(.gray)
                    }
                }
            } else if item.title == "To Language" {
                NavigationLink(destination: destination) {
                    HStack {
                        if let icon = item.icon {
                            Image(systemName: icon)
                                .foregroundColor(.blue)
                                .frame(width: 25)
                        }
                        Text(item.title)
                        Spacer()
                        Text(languageNameFor(code: targetLanguageCode))
                            .foregroundColor(.gray)
                    }
                }
            } else {
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
    
    // Helper function to translate language code to language name
    private func languageNameFor(code: String) -> String {
        translationLanguages.first { $0.0 == code }?.1 ?? code
    }
    
    // Custom picker for language selection
    private func languagePickerView(title: String, languageCodes: [(String, String)], selection: Binding<String>) -> some View {
        List {
            Section(header: Text(title)) {
                ForEach(languageCodes, id: \.0) { code, name in
                    Button(action: {
                        selection.wrappedValue = code
                    }) {
                        HStack {
                            Text(name)
                            Spacer()
                            if selection.wrappedValue == code {
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

// MARK: - Backup How-To View
struct BackupHowToView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title and introduction
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.clockwise.icloud")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("How to Backup Your Data")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text("This guide will walk you through the process of backing up your Camino journey data to ensure you never lose your tracking information, settings, or saved routes.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Step 1
                BackupStepView(
                    number: 1,
                    title: "Access Backup Options",
                    instructions: "Navigate to Settings > Data Management > Backup & Restore and tap to open the backup options dialog.",
                    icon: "gearshape"
                )
                
                // Step 2
                BackupStepView(
                    number: 2,
                    title: "Choose Backup Method",
                    instructions: "Select \"Backup to Cloud\" to store your data securely in iCloud, which allows restoration on any device with your Apple ID.",
                    icon: "icloud.and.arrow.up"
                )
                
                // Step 3
                BackupStepView(
                    number: 3,
                    title: "Confirm Backup",
                    instructions: "Review the backup details showing what will be saved, including your journey progress, settings, waypoint notes, and saved photos.",
                    icon: "checkmark.circle"
                )
                
                // Step 4
                BackupStepView(
                    number: 4,
                    title: "Wait for Completion",
                    instructions: "The backup process may take a minute or two. A progress indicator will show the backup status. Do not leave the app during this process.",
                    icon: "hourglass"
                )
                
                // Step 5
                BackupStepView(
                    number: 5,
                    title: "Verify Backup",
                    instructions: "Once complete, you'll see a confirmation message with the date and time of the backup. This information is stored in Settings > Data Management.",
                    icon: "checkmark.seal"
                )
                
                // Alternative Export Option
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alternative: Export Your Data")
                            .font(.headline)
                        
                        Text("If you prefer a local backup that you can share or store elsewhere:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Select \"Export Data\" from the backup options")
                                Text("2. Choose a format (PDF or CSV)")
                                Text("3. Select a sharing method (AirDrop, Email, Files, etc.)")
                                Text("4. Send or save the exported file")
                            }
                            .font(.callout)
                        }
                    }
                    .padding()
                }
                
                // Automatic Backups Info
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Automatic Backups")
                            .font(.headline)
                        
                        Text("The app automatically creates daily backups when you have cloud backup enabled. You can access the last 7 days of automatic backups from the Restore options.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Backup Guide")
    }
}

// Helper view for backup steps
struct BackupStepView: View {
    let number: Int
    let title: String
    let instructions: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number in circle
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 36, height: 36)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Step title
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    
                    Text(title)
                        .font(.headline)
                }
                
                // Step instructions
                Text(instructions)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 