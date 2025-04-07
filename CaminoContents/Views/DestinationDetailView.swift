import SwiftUI
import MapKit
import CoreLocation

struct DestinationDetailView: View {
    let destination: CaminoDestination
    @State private var region: MKCoordinateRegion
    
    init(destination: CaminoDestination) {
        self.destination = destination
        _region = State(initialValue: MKCoordinateRegion(
            center: destination.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Map(coordinateRegion: $region, annotationItems: [destination]) { location in
                    MapMarker(coordinate: location.coordinate)
                }
                .frame(height: 200)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Day \(destination.day)")
                            .font(.headline)
                        Text("(\(destination.formattedDate))")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(destination.locationName)
                        .font(.title)
                        .bold()
                    
                    Text(destination.hotelName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Coordinates:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.4f, %.4f",
                                  destination.coordinate.latitude,
                                  destination.coordinate.longitude))
                            .font(.caption)
                            .monospaced()
                    }
                }
                .padding(.horizontal)
                
                Text(destination.content)
                    .font(.body)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Destination Details")
    }
} 