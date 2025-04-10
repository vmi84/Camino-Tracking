import SwiftUI
import MapKit
import CaminoModels

struct DestinationsView: View {
    @State private var searchText = ""
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    
    var filteredDestinations: [CaminoDestination] {
        if searchText.isEmpty {
            return CaminoDestination.allDestinations
        } else {
            return CaminoDestination.allDestinations.filter { destination in
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
        NavigationStack {
            List(filteredDestinations) { destination in
                NavigationLink(destination: DestinationDetailView(destination: destination)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Day \(destination.day)")
                                .font(.headline)
                            Text(destination.locationName)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Text(formatDistance(destination.actualRouteDistance))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Destinations")
            .searchable(text: $searchText, prompt: "Search days or locations")
        }
    }
}

#Preview {
    DestinationsView()
} 