import SwiftUI
import MapKit
import CaminoModels

struct DestinationsView: View {
    @State private var searchText = ""
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @EnvironmentObject var appState: CaminoAppState
    let destinations = CaminoDestination.allDestinations
    
    var filteredDestinations: [CaminoDestination] {
        if searchText.isEmpty {
            return destinations
        } else {
            return destinations.filter { destination in
                destination.locationName.localizedCaseInsensitiveContains(searchText) ||
                destination.hotelName.localizedCaseInsensitiveContains(searchText) ||
                "\(destination.day)".contains(searchText)
            }
        }
    }
    
    // Helper method to format distances with proper units
    private func formatDistance(_ kilometers: Double) -> String {
        if useMetricUnits {
            return String(format: "%.1f km", kilometers)
        } else {
            let miles = kilometers * 0.621371
            return String(format: "%.1f mi", miles)
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredDestinations) { destination in
                NavigationLink(destination: DestinationDetailView(destination: destination)) {
                    DestinationRow(destination: destination)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search Destinations")
            .navigationTitle("Destinations")
            // Clear selection when view disappears
            .onDisappear {
                appState.selectedDestinationDay = nil
            }
        }
    }
}

struct DestinationRow: View {
    let destination: CaminoDestination
    @AppStorage("useMetricUnits") private var useMetricUnits = true

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Day \(destination.day): \(destination.locationName)")
                    .font(.headline)
                Text(destination.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(formattedDistance(destination.dailyDistance))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    // Helper to format distance in the row
    private func formattedDistance(_ kilometers: Double) -> String {
        if useMetricUnits {
            return String(format: "%.1f km", kilometers)
        } else {
            let miles = kilometers * 0.621371
            return String(format: "%.1f mi", miles)
        }
    }
}

#Preview {
    DestinationsView()
        .environmentObject(CaminoAppState()) // Ensure preview has the environment object
} 