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
    let type: SettingsItemType
}

enum SettingsItemType {
    case toggle(Binding<Bool>)
    case picker([String], Binding<String>)
    case button(() -> Void)
    case navigationLink(destination: AnyView)
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("offlineMode") private var offlineMode = false
    @AppStorage("mapStyle") private var mapStyle = "Standard"
    @AppStorage("gpsUpdateInterval") private var gpsUpdateInterval = "Normal"
    @AppStorage("weatherNotifications") private var weatherNotifications = true
    @AppStorage("locationNotifications") private var locationNotifications = true
    
    private let mapStyles = ["Standard", "Satellite", "Hybrid"]
    private let gpsIntervals = ["High", "Normal", "Low"]
    
    private var sections: [SettingsSection] {
        [
            SettingsSection(title: "General", items: [
                SettingsItem(title: "Use Metric Units", type: .toggle($useMetricUnits)),
                SettingsItem(title: "Offline Mode", type: .toggle($offlineMode))
            ]),
            SettingsSection(title: "Map", items: [
                SettingsItem(title: "Map Style", type: .picker(mapStyles, $mapStyle)),
                SettingsItem(title: "GPS Update Interval", type: .picker(gpsIntervals, $gpsUpdateInterval))
            ]),
            SettingsSection(title: "Notifications", items: [
                SettingsItem(title: "Weather Alerts", type: .toggle($weatherNotifications)),
                SettingsItem(title: "Location Updates", type: .toggle($locationNotifications))
            ]),
            SettingsSection(title: "Data", items: [
                SettingsItem(title: "Clear Cache", type: .button(clearCache)),
                SettingsItem(title: "Version", type: .button(showVersion))
            ])
        ]
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sections, id: \.title) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.items, id: \.title) { item in
                            settingsRow(for: item)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    @ViewBuilder
    private func settingsRow(for item: SettingsItem) -> some View {
        switch item.type {
        case .toggle(let binding):
            Toggle(item.title, isOn: binding)
        case .picker(let options, let selection):
            Picker(item.title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        case .button(let action):
            Button(action: action) {
                Text(item.title)
            }
        case .navigationLink(let destination):
            NavigationLink(destination: destination) {
                Text(item.title)
            }
        }
    }
    
    private func clearCache() {
        // TODO: Implement cache clearing
    }
    
    private func showVersion() {
        // TODO: Implement version display
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 