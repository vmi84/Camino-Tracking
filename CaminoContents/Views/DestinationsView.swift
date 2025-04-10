import SwiftUI
import MapKit
import CaminoModels

struct DestinationsView: View {
    @State private var searchText = ""
    
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
                        
                        Text(String(format: "%.1f km", destination.dailyDistance))
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