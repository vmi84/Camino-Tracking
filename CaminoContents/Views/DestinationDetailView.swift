import SwiftUI
import Charts
import MapKit
import CoreLocation
import CaminoModels

struct StageProfileView: View {
    let day: Int
    
    var body: some View {
        // Using a helper method to create the profile view
        let elevationImage = makeElevationImage()
        
        return VStack {
            elevationImage
        }
        .padding(.vertical, 8) // Remove horizontal padding to allow full width
    }
    
    // Helper method to create the elevation image with consistent return type
    private func makeElevationImage() -> some View {
        Group {
            if let uiImage = UIImage(named: "day\(day)") ?? loadElevationProfileImage(for: day) {
                // Return image if available
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(radius: 2)
            } else {
                // Return placeholder if no image available
                Text("Elevation profile not available for Day \(day)")
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
    }
    
    // Function to load the elevation profile image from the bundle
    private func loadElevationProfileImage(for day: Int) -> UIImage? {
        // Try first with the bundle resource path
        if let bundlePath = Bundle.main.resourcePath {
            let imagePath = bundlePath + "/ElevationProfileImages/day\(day).png"
            return UIImage(contentsOfFile: imagePath)
        }
        
        // Fallback to the main bundle path for resource
        if let imagePath = Bundle.main.path(forResource: "day\(day)", ofType: "png", inDirectory: "ElevationProfileImages") {
            return UIImage(contentsOfFile: imagePath)
        }
        
        return nil
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
                // Show the elevation profile image for the day
                StageProfileView(day: destination.day)
                    .frame(maxWidth: .infinity) // Use max width instead of fixed height
                    .padding(.horizontal) // Add padding inside the container
                
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
                        Text("• Distance: \(String(format: "%.1f", destination.actualRouteDistance)) km")
                        Text("• Total: \(String(format: "%.1f", destination.cumulativeDistance)) km")
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location Coordinates:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.4f° N, %.4f° W",
                                  destination.coordinate.latitude,
                                  abs(destination.coordinate.longitude)))
                            .font(.caption)
                            .monospaced()
                        
                        Text("Hotel: \(destination.hotelName) Coordinates:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.4f° N, %.4f° W",
                                  destination.coordinate.latitude,
                                  abs(destination.coordinate.longitude)))
                            .font(.caption)
                            .monospaced()
                    }
                }
                .padding(.horizontal)
                
                if !destination.content.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Directions:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text(destination.content)
                            .font(.body)
                            .padding(.horizontal)
                            .lineSpacing(4)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Destination Details")
    }
} 