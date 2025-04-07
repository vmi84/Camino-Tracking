import SwiftUI
import MapKit
import CoreLocation

struct DestinationsView: View {
    var body: some View {
        NavigationView {
            List(CaminoDestination.allDestinations) { destination in
                NavigationLink {
                    DestinationDetailView(destination: destination)
                } label: {
                    VStack(alignment: .leading) {
                        Text("Day \(destination.day)")
                            .font(.headline)
                        Text(destination.locationName)
                            .font(.title3)
                        Text(destination.hotelName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Destinations")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    DestinationsView()
} 