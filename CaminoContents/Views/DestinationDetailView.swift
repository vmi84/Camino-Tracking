import SwiftUI
import Charts
import MapKit
import CoreLocation
import Models

struct StageProfileView: View {
    let elevationData: [(distance: Double, elevation: Double)]
    
    var body: some View {
        Chart {
            ForEach(elevationData, id: \.distance) { point in
                LineMark(
                    x: .value("Distance (km)", point.distance),
                    y: .value("Elevation (m)", point.elevation)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel(format: FloatingPointFormatStyle<Double>().precision(.fractionLength(1)))
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisValueLabel(format: FloatingPointFormatStyle<Double>().precision(.fractionLength(0)))
            }
        }
        .frame(height: 150)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

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
                if !destination.elevationProfile.isEmpty {
                    StageProfileView(elevationData: destination.elevationProfile)
                        .frame(height: 200)
                        .cornerRadius(12)
                }
                
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Route Information:")
                            .font(.headline)
                        Text("• Distance: \(String(format: "%.1f", destination.dailyDistance)) km")
                        Text("• Total: \(String(format: "%.1f", destination.cumulativeDistance)) km")
                    }
                    
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