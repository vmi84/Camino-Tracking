import SwiftUI
import Charts
import MapKit
import CoreLocation
import CaminoModels

struct StageProfileView: View {
    let assetName: String
    
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
            if !assetName.isEmpty {
                // Return image if assetName is provided
                Image(assetName) // Load directly from Asset Catalog
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(radius: 2)
            } else {
                // Return placeholder if no assetName is provided
                Text("Elevation profile not available")
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
    }
}

struct RouteDetailView: View {
    let destinationDay: Int
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    
    // Convert destination day to route day, accounting for the rest day in Leon
    private var routeDay: Int {
        if destinationDay <= 19 {
            return destinationDay
        } else {
            // After Leon (destination day 19), we have a rest day, so route day is destination day - 1
            return destinationDay - 1
        }
    }
    
    private var routeDetails: RouteDetail? {
        return RouteDetailProvider.getRouteDetail(for: routeDay)
    }
    
    // Helper method to format distances with proper units
    private func formatDistance(_ kilometers: Double?) -> String {
        guard let km = kilometers else { return "" }
        
        if useMetricUnits {
            return "(\(km) km)"
        } else {
            let miles = km * 0.621371
            return "(\(String(format: "%.1f", miles)) mi)"
        }
    }
    
    var body: some View {
        if let details = routeDetails {
            VStack(alignment: .leading, spacing: 16) {
                // Title section
                VStack(alignment: .leading, spacing: 2) {
                    Text("Route Specifics")
                        .font(.headline)
                    
                    if let routeTitle = details.title {
                        Text(routeTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Day profile with elevation
                    if let ascent = details.ascent, let descent = details.descent {
                        HStack(spacing: 16) {
                            Label("\(ascent) m", systemImage: "arrow.up")
                                .foregroundColor(.orange)
                            Label("\(descent) m", systemImage: "arrow.down")
                                .foregroundColor(.blue)
                        }
                        .font(.callout)
                        .padding(.top, 4)
                    }
                }
                
                Divider()
                
                // Start point
                if let start = details.startPoint {
                    VStack(alignment: .leading, spacing: 4) {
                        Label {
                            Text("Starting Point: ") +
                            Text(start.name).bold() +
                            Text(start.distance != nil ? " (0.0 \(useMetricUnits ? "km" : "mi"))" : "")
                        } icon: {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.green)
                        }
                        .font(.callout)
                        
                        if let details = start.details {
                            Text(details)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.bottom, 4)
                }
                
                // Waypoints
                if let waypoints = details.waypoints, !waypoints.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Waypoints")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ForEach(waypoints, id: \.name) { waypoint in
                            VStack(alignment: .leading, spacing: 2) {
                                Label {
                                    Text(waypoint.name).bold() +
                                    Text(waypoint.distance != nil ? " " + formatDistance(waypoint.distance) : "")
                                } icon: {
                                    Image(systemName: "mappin")
                                        .foregroundColor(.red)
                                }
                                .font(.callout)
                                
                                if let services = waypoint.services {
                                    Text(services)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                }
                                
                                if let details = waypoint.details {
                                    Text(details)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.vertical, 2)
                            
                            if waypoint != waypoints.last {
                                Divider()
                                    .padding(.leading, 24)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // End point
                if let end = details.endPoint {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label {
                            Text("End Point: ") +
                            Text(end.name).bold() +
                            Text(end.distance != nil ? " " + formatDistance(end.distance) : "")
                        } icon: {
                            Image(systemName: "flag.checkered")
                                .foregroundColor(.blue)
                        }
                        .font(.callout)
                        
                        if let services = end.services {
                            Text(services)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                        }
                        
                        if let details = end.details {
                            Text(details)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 24)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        } else {
            Text("Route details not available for day \(destinationDay)")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
        }
    }
}

struct DestinationDetailView: View {
    let destination: CaminoDestination
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @Environment(\.presentationMode) var presentationMode // For dismissing the modal
    @EnvironmentObject var appState: CaminoAppState // Inject AppState
    
    // Detect if presented modally (simple check: is it embedded in NavigationView?)
    // This is imperfect. A more robust way is to pass an explicit flag or binding.
    private var isPresentedModally: Bool {
         // Check if we can dismiss using presentationMode
         // If presented via .sheet, this should work.
         // If pushed via NavigationLink, presentationMode won't dismiss it to the root.
         // Let's assume .sheet for now based on MapView's implementation.
         return true // Assume modal for now, adjust if needed.
    }

    // Helper function to format distance
    private func formattedDistance(_ kilometers: Double) -> String {
        if useMetricUnits {
            return String(format: "%.1f km", kilometers)
        } else {
            let miles = kilometers * 0.621371
            return String(format: "%.1f mi", miles)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header
                destinationHeader

                // MARK: - Elevation Profile
                Section("Elevation Profile") {
                    StageProfileView(assetName: destination.elevationProfileAssetName)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                }

                // MARK: - Distance
                Section("Distance") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Daily Distance:")
                                .font(.subheadline)
                            Spacer()
                            Text(formattedDistance(destination.dailyDistance))
                                .font(.body.weight(.semibold))
                        }
                        HStack {
                            Text("Cumulative Distance:")
                                .font(.subheadline)
                            Spacer()
                            Text(formattedDistance(destination.cumulativeDistance))
                                .font(.body.weight(.semibold))
                        }
                        HStack {
                            Text("Total Remaining:")
                                .font(.subheadline)
                            Spacer()
                            Text(formattedDistance(CaminoDestination.totalDistance - destination.cumulativeDistance))
                                .font(.body.weight(.semibold))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary.opacity(0.05))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                }

                // MARK: - Route Details
                Section("Route Details") {
                    RouteDetailView(destinationDay: destination.day)
                    
                    // NEW: Button to show route on main map
                    Button {
                        appState.focusedRouteDay = destination.day
                        appState.selectedTab = 0 // Assuming Map is Tab 0
                        presentationMode.wrappedValue.dismiss() // Dismiss detail view
                    } label: {
                        Label("Show Route on Map", systemImage: "map.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }

                // MARK: - Hotel Information
                Section("Hotel Details") {
                    HotelInfoView(destination: destination)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        // Add Toolbar only if presented modally
        .toolbar { 
            if isPresentedModally {
                 ToolbarItem(placement: .navigationBarLeading) { // Or .navigationBarTrailing
                     Button("Return") {
                         presentationMode.wrappedValue.dismiss() // Dismiss the sheet
                     }
                 }
            }
        }
    }
    
    // MARK: - Computed Properties for Title
    private var navigationTitleText: String {
        // Find the previous destination
        let previousDayIndex = destination.day - 1
        let previousDestination = (previousDayIndex >= 0 && previousDayIndex < CaminoDestination.allDestinations.count) 
                                  ? CaminoDestination.allDestinations[previousDayIndex] 
                                  : nil
        
        // Construct the title
        if destination.day == 0 { // Special case for Day 0
            return "Starting Point: \(destination.locationName)"
        } else if let prevDest = previousDestination {
            return "\(prevDest.locationName) to \(destination.locationName)"
        } else {
            // Fallback if previous destination can't be found (shouldn't happen after Day 0)
            return destination.locationName
        }
    }

    // MARK: - Subviews
    private var destinationHeader: some View {
        VStack(alignment: .leading) {
            Text("Day \(destination.day): \(destination.locationName)")
                .font(.title)
                .bold()

            if !destination.hotelName.isEmpty {
                HStack {
                    Image(systemName: "bed.double.fill")
                        .foregroundColor(.blue)
                    Text(destination.hotelName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                Text("Date: \(destination.formattedDate)")
                Spacer()
                Text("Dist: \(formattedDistance(destination.dailyDistance)) / \(formattedDistance(destination.cumulativeDistance)) cumulative")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
}

// MARK: - Route Detail Models
struct LocationPoint: Equatable {
    let name: String
    let distance: Double?
    let services: String?
    let details: String?
    let coordinate: CLLocationCoordinate2D?
}

struct RouteDetail {
    let title: String?
    let startPoint: LocationPoint?
    let waypoints: [LocationPoint]?
    let endPoint: LocationPoint?
    let ascent: Int?
    let descent: Int?
}

// MARK: - Route Detail Provider
struct RouteDetailProvider {
    static func getRouteDetail(for day: Int) -> RouteDetail? {
        switch day {
        case 1:
            return RouteDetail(
                title: "St Jean Pied de Port to Roncesvalles (Option A: Via Orisson)",
                startPoint: LocationPoint(
                    name: "Saint Jean Pied de Port",
                    distance: 0.0,
                    services: "All services",
                    details: "Begin at the medieval bridge over the River Nive, proceed to Rue d'Espagne, turn right after 100 m onto the \"Route de Napoleon\" (steep, follows the Via Aquitaine Roman road).",
                    coordinate: CLLocationCoordinate2D(latitude: 43.1630, longitude: -1.2380)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Honto",
                        distance: 5.0,
                        services: nil,
                        details: "After Honto, take a left-hand path to avoid a road curve, rejoin the road, and head to Orisson.",
                        coordinate: CLLocationCoordinate2D(latitude: 43.137, longitude: -1.268)
                    ),
                    LocationPoint(
                        name: "Orisson",
                        distance: 7.6,
                        services: "Bar, Restaurant",
                        details: "Continue on a low-traffic road through alpine meadows; 4 km ahead, spot the Virgin of Biakorri statue (shepherds' protector) on the left if clear.",
                        coordinate: CLLocationCoordinate2D(latitude: 43.120, longitude: -1.280)
                    ),
                    LocationPoint(
                        name: "Arnéguy",
                        distance: 12.7,
                        services: nil,
                        details: "Pass Arnéguy on the right (option to link to Valcarlos), leave the road after 2.0 km for a right-hand path by the Urdanarre Cross.",
                        coordinate: CLLocationCoordinate2D(latitude: 43.1130, longitude: -1.2830)
                    ),
                    LocationPoint(
                        name: "Collado de Bentartea",
                        distance: 16.2,
                        services: "Bentartea Pass",
                        details: "After 1.4 km, reach the pass with Roldán Fountain (commemorates Charlemagne's officer, 778). Follow a beech forest track along the border fence, pass a stone pillar marking Navarre, take a right-hand track along Txangoa and Menditxipi mountains' northern slopes.",
                        coordinate: CLLocationCoordinate2D(latitude: 43.075, longitude: -1.299)
                    ),
                    LocationPoint(
                        name: "Collado de Lepoeder",
                        distance: 20.2,
                        services: nil,
                        details: "Two descent options: 1) Direct Route: Steep descent through Mount Donsimon beech forest (caution in fog), go right then left of the road. 2) Ibañeta Pass Route: Divert to Ibañeta Pass (Monument to Roldan, Chapel), descend left of the national road.",
                        coordinate: CLLocationCoordinate2D(latitude: 43.0483, longitude: -1.3086)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Roncesvalles",
                    distance: 23.9,
                    services: "Bar-restaurant, Tourism Office",
                    details: "Arrive via descent into this historic Jacobean town.",
                    coordinate: CLLocationCoordinate2D(latitude: 43.0090, longitude: -1.3190)
                ),
                ascent: 1282,
                descent: 504
            )
        case 2:
            return RouteDetail(
                title: "Roncesvalles to Zubiri",
                startPoint: LocationPoint(
                    name: "Roncesvalles",
                    distance: 0.0,
                    services: "Bar, Restaurant, Tourism Office",
                    details: "Exit on the N-135, take a right-hand path through Sorginaritzaga Forest (oaks, beeches), pass the Cross of the Pilgrims (Gothic, 1880) after 100 m, stay right of the road, turn left at Ipetea industrial park, enter Burguete.",
                    coordinate: CLLocationCoordinate2D(latitude: 43.0090, longitude: -1.3190)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Burguete",
                        distance: 2.8,
                        services: "Bars, Stores, Health Center, Pharmacy, ATM",
                        details: "Cross via the main street, pass the Parish Church of San Nicolas, turn right, cross a footbridge over a stream to the Urrobi River, climb a wooded trail with water sources and a steep hill.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.9905, longitude: -1.3350)
                    ),
                    LocationPoint(
                        name: "Espinal",
                        distance: 6.5,
                        services: "Bar, Store, Medical Clinic",
                        details: "After 2.6 km, enter via a paved path, head right (bar and bakery nearby), follow the sidewalk, turn left after a crosswalk, climb to Mezkiritz.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.9722, longitude: -1.3590)
                    ),
                    LocationPoint(
                        name: "Alto de Mezkiritz",
                        distance: 8.2,
                        services: "924 m",
                        details: "Cross the N-135, see the Virgen of Roncesvalles carving, descend on a wooded trail (some deteriorated), enter a beech forest via a metal gate, reach Bizkarreta.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.960, longitude: -1.380)
                    ),
                    LocationPoint(
                        name: "Bizkarreta",
                        distance: 11.5,
                        services: nil,
                        details: "Historic stage end with a former pilgrims' hospital (12th century).",
                        coordinate: CLLocationCoordinate2D(latitude: 42.9500, longitude: -1.4000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Zubiri",
                    distance: 21.5,
                    services: "All services",
                    details: "Cross the 14th-century \"Bridge of Rabies\" over the Arga River (Santa Quiteria legend).",
                    coordinate: CLLocationCoordinate2D(latitude: 42.9320, longitude: -1.5030)
                ),
                ascent: 217,
                descent: 633
            )
        case 3:
            return RouteDetail(
                title: "Zubiri to Pamplona",
                startPoint: LocationPoint(
                    name: "Zubiri",
                    distance: 0.0,
                    services: "All services",
                    details: "Cross the entry bridge, follow the Arga River valley, pass a magnesite factory (1 km), ascend its perimeter, descend stairs, continue on pleasant roads.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.9320, longitude: -1.5030)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Ilarratz",
                        distance: 2.9,
                        services: "Drinking fountain",
                        details: nil,
                        coordinate: CLLocationCoordinate2D(latitude: 42.923, longitude: -1.528)
                    ),
                    LocationPoint(
                        name: "Ezkirotz",
                        distance: 3.7,
                        services: "Drinking fountain",
                        details: nil,
                        coordinate: CLLocationCoordinate2D(latitude: 42.920, longitude: -1.535)
                    ),
                    LocationPoint(
                        name: "Larrasoaña",
                        distance: 5.5,
                        services: "Bar, Store, Supermarket, Medical Clinic",
                        details: "Exit via the entry bridge, keep the Arga River right, ascend to Akerreta (off-path across the river).",
                        coordinate: CLLocationCoordinate2D(latitude: 42.9190, longitude: -1.5500)
                    ),
                    LocationPoint(
                        name: "Akerreta",
                        distance: 6.1,
                        services: nil,
                        details: "Pass the Church of the Transfiguration, go by a rural hotel, cross a gate and gravel stretch, reach a local road, cross it, descend to the Arga River shore, follow to Zuriain.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.917, longitude: -1.555)
                    ),
                    LocationPoint(
                        name: "Zuriain",
                        distance: 9.2,
                        services: "Bar",
                        details: "Walk beside the N-135 for 600 m, turn left, cross the Arga River.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.898, longitude: -1.580)
                    ),
                    LocationPoint(
                        name: "Irotz",
                        distance: 11.2,
                        services: "Bar",
                        details: "Pass the Church of San Pedro, reach the Romanesque Iturgaiz Bridge, choose: Arre (narrow trail to Zabaldika) or Riverside Walk (to Huarte).",
                        coordinate: CLLocationCoordinate2D(latitude: 42.888, longitude: -1.595)
                    ),
                    LocationPoint(
                        name: "Trinidad de Arre",
                        distance: 16.0,
                        services: nil,
                        details: "Cross the medieval bridge over the Ultzama River, turn left.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.8900, longitude: -1.6200)
                    ),
                    LocationPoint(
                        name: "Villava",
                        distance: 16.4,
                        services: "All services",
                        details: "Follow Mayor de Villava Street, cross the road, pass roundabouts, link to Burlada.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.830, longitude: -1.625)
                    ),
                    LocationPoint(
                        name: "Burlada",
                        distance: 17.5,
                        services: "All services",
                        details: "Cross Main Street, turn right at a mechanic, cross a pedestrian walkway, follow pavement markers, turn left onto the Camino of Burlada walkway.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.825, longitude: -1.630)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Pamplona",
                    distance: 21.8,
                    services: "All services",
                    details: "Cross the Magdalena Bridge over the Arga River, follow the moat (Bastion of Our Lady of Guadalupe), enter via Portal de Francia (1553), proceed through Carmen streets, turn left on De Curia Street.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8120, longitude: -1.6450)
                ),
                ascent: 72,
                descent: 148
            )
        case 4:
            return RouteDetail(
                title: "Pamplona to Puente la Reina",
                startPoint: LocationPoint(
                    name: "Pamplona",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit via the historic center, climb the Sierra del Perdon (260 m ascent, steeper at the end), pass wind turbines and the Pilgrims' Monument.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8120, longitude: -1.6450)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Cizur Menor",
                        distance: 5.0,
                        services: "Bar, store",
                        details: "Pass the Church of San Miguel, continue on a paved path.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.795, longitude: -1.680)
                    ),
                    LocationPoint(
                        name: "Alto del Perdon",
                        distance: 13.0,
                        services: "770 m",
                        details: "Reach the ridge, descend on a rocky path (caution advised).",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7400, longitude: -1.7100)
                    ),
                    LocationPoint(
                        name: "Uterga",
                        distance: 16.5,
                        services: "Bar",
                        details: "Enter via a dirt track, continue westward.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7100, longitude: -1.7600)
                    ),
                    LocationPoint(
                        name: "Obanos",
                        distance: 19.5,
                        services: "Bar, store",
                        details: "Pass the Church of San Juan Bautista, merge with the Aragonés Camino route.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6800, longitude: -1.7900)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Puente la Reina",
                    distance: 24.0,
                    services: "All services",
                    details: "Cross the iconic 11th-century bridge over the Arga River; optional detour to the Hermitage of Santa Maria de Eunate (2 km off-route).",
                    coordinate: CLLocationCoordinate2D(latitude: 42.6720, longitude: -1.8140)
                ),
                ascent: 419,
                descent: 523
            )
        case 5:
            return RouteDetail(
                title: "Puente la Reina to Estella",
                startPoint: LocationPoint(
                    name: "Puente la Reina",
                    distance: 0.0,
                    services: "All services",
                    details: "Cross the famous medieval bridge, follow the main road west, and take the path along the Arga River.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.6720, longitude: -1.8140)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Mañeru",
                        distance: 4.6,
                        services: "Bar, store",
                        details: "Village on a hillside, follow main street through the center.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.673, longitude: -1.865)
                    ),
                    LocationPoint(
                        name: "Cirauqui",
                        distance: 8.1,
                        services: "Bar, store, pharmacy",
                        details: "Enter through medieval gate, follow steep streets, exit via Roman road.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6750, longitude: -1.8900)
                    ),
                    LocationPoint(
                        name: "Lorca",
                        distance: 15.5,
                        services: "Bar, water fountain",
                        details: "Small village with fountain, continue straight through.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6700, longitude: -1.9500)
                    ),
                    LocationPoint(
                        name: "Villatuerta",
                        distance: 18.8,
                        services: "Bar, store",
                        details: "Cross river, follow path up the hill into town.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6600, longitude: -2.0000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Estella",
                    distance: 22.5,
                    services: "All services",
                    details: "Historic town with many medieval buildings and churches. Enter via the north bridge and follow signs to the center.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.6710, longitude: -2.0320)
                ),
                ascent: 345,
                descent: 270
            )
        case 6:
            return RouteDetail(
                title: "Estella to Los Arcos",
                startPoint: LocationPoint(
                    name: "Estella",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit via the Monastery of Irache, visit the famous wine fountain (Fuente del Vino).",
                    coordinate: CLLocationCoordinate2D(latitude: 42.6710, longitude: -2.0320)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Irache",
                        distance: 2.2,
                        services: "Wine fountain, monastery",
                        details: "Pass the notable 12th-century monastery and the wine fountain where pilgrims can take a free drink.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6600, longitude: -2.0500)
                    ),
                    LocationPoint(
                        name: "Azqueta",
                        distance: 5.7,
                        services: "Bar, water",
                        details: "Small village with pilgrim fountain, continue through main street.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6500, longitude: -2.0800)
                    ),
                    LocationPoint(
                        name: "Villamayor de Monjardín",
                        distance: 8.1,
                        services: "Bar, fountain",
                        details: "Village at the foot of Mount Monjardín, with the ruins of San Esteban de Deyo Castle above.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6400, longitude: -2.1000)
                    ),
                    LocationPoint(
                        name: "Luquin",
                        distance: 14.6,
                        services: "Water",
                        details: "Cross fields, follow dirt path through olive groves.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.605, longitude: -2.135)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Los Arcos",
                    distance: 21.3,
                    services: "All services",
                    details: "Town centered around the impressive Church of Santa María, with many bars and restaurants in the main square.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.5710, longitude: -2.1920)
                ),
                ascent: 310,
                descent: 264
            )
        case 7:
            return RouteDetail(
                title: "Los Arcos to Logroño",
                startPoint: LocationPoint(
                    name: "Los Arcos",
                    distance: 0.0,
                    services: "All services",
                    details: "Leave town via the west, cross the River Odrón, follow path through vineyards and farmland.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.5710, longitude: -2.1920)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Torres del Río",
                        distance: 7.6,
                        services: "Bar, fountain",
                        details: "Village with an octagonal church (Church of the Holy Sepulchre), continue west.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.5500, longitude: -2.2700)
                    ),
                    LocationPoint(
                        name: "Viana",
                        distance: 17.8,
                        services: "All services",
                        details: "Historic walled town, impressive Church of Santa María, pass by where Cesare Borgia died in 1507.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.5200, longitude: -2.3700)
                    ),
                    LocationPoint(
                        name: "Navarre-La Rioja Border",
                        distance: 20.1,
                        services: nil,
                        details: "Cross from Navarre into La Rioja region, marked by a stone monument.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.500, longitude: -2.400)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Logroño",
                    distance: 28.2,
                    services: "All services",
                    details: "Capital of La Rioja, enter via the Stone Bridge (Puente de Piedra), visit the Cathedral of Santa María de la Redonda.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450)
                ),
                ascent: 150,
                descent: 185
            )
        case 8:
            return RouteDetail(
                title: "Logroño to Nájera",
                startPoint: LocationPoint(
                    name: "Logroño",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit through the west side, pass Parque de la Grajera, follow path through vineyards.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Navarrete",
                        distance: 12.9,
                        services: "Bars, restaurants, shops",
                        details: "Town known for pottery, see the Church of the Assumption and Santiago ruins.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4300, longitude: -2.5600)
                    ),
                    LocationPoint(
                        name: "Ventosa",
                        distance: 18.2,
                        services: "Bar, fountain",
                        details: "Small hill village with views of vineyards, follow main road through town.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -2.6200)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Nájera",
                    distance: 29.0,
                    services: "All services",
                    details: "Historic town on the Najerilla River, visit the Monastery of Santa María la Real with royal pantheon.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7320)
                ),
                ascent: 185,
                descent: 130
            )
        case 9:
            return RouteDetail(
                title: "Nájera to Santo Domingo de la Calzada",
                startPoint: LocationPoint(
                    name: "Nájera",
                    distance: 0.0,
                    services: "All services",
                    details: "Cross the Najerilla River, climb steadily through grain fields and vineyards.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7320)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Azofra",
                        distance: 5.5,
                        services: "Bar, fountain, store",
                        details: "Traditional pilgrim stop with fountain in the main square.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -2.8000)
                    ),
                    LocationPoint(
                        name: "Cirueña",
                        distance: 12.0,
                        services: "Bar",
                        details: "Small village near golf course, follow path through fields.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4300, longitude: -2.9000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Santo Domingo de la Calzada",
                    distance: 21.0,
                    services: "All services",
                    details: "Named after saint who built bridges for pilgrims, visit the cathedral with live chickens (related to the famous miracle).",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530)
                ),
                ascent: 220,
                descent: 170
            )
        case 10:
            return RouteDetail(
                title: "Santo Domingo de la Calzada to Belorado",
                startPoint: LocationPoint(
                    name: "Santo Domingo de la Calzada",
                    distance: 0.0,
                    services: nil,
                    details: "Start at El Molino de Floren, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Grañón",
                        distance: 6.0,
                        services: nil,
                        details: "Village with a bar and albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4500, longitude: -3.0300)
                    ),
                    LocationPoint(
                        name: "Redecilla del Camino",
                        distance: 10.0,
                        services: nil,
                        details: "Small village with a baptismal font.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -3.0800)
                    ),
                    LocationPoint(
                        name: "Viloria de Rioja",
                        distance: 15.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4300, longitude: -3.1200)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Belorado",
                    distance: 22.0,
                    services: nil,
                    details: "End at Hostel Punto B, near Plaza Mayor.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910)
                ),
                ascent: 170,
                descent: 250
            )
        case 11:
            return RouteDetail(
                title: "Belorado to San Juan de Ortega",
                startPoint: LocationPoint(
                    name: "Belorado",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hostel Punto B, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Tosantos",
                        distance: 5.0,
                        services: nil,
                        details: "Small village with an albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4100, longitude: -3.2400)
                    ),
                    LocationPoint(
                        name: "Villafranca Montes de Oca",
                        distance: 12.0,
                        services: nil,
                        details: "Village with a bar and historic hospital.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3900, longitude: -3.3100)
                    )
                ],
                endPoint: LocationPoint(
                    name: "San Juan de Ortega",
                    distance: 24.0,
                    services: nil,
                    details: "End at Hotel Rural la Henera, near the monastery.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3750, longitude: -3.4370)
                ),
                ascent: 370,
                descent: 210
            )
        case 12:
            return RouteDetail(
                title: "San Juan de Ortega to Burgos",
                startPoint: LocationPoint(
                    name: "San Juan de Ortega",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Rural la Henera, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3750, longitude: -3.4370)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Agés",
                        distance: 4.0,
                        services: nil,
                        details: "Village with a bar and albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3700, longitude: -3.4800)
                    ),
                    LocationPoint(
                        name: "Atapuerca",
                        distance: 7.0,
                        services: nil,
                        details: "Village near archaeological sites.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3700, longitude: -3.5100)
                    ),
                    LocationPoint(
                        name: "Orbaneja",
                        distance: 15.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3500, longitude: -3.6000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Burgos",
                    distance: 26.0,
                    services: nil,
                    details: "End at Hotel Cordón, near the Cathedral.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7040)
                ),
                ascent: 150,
                descent: 280
            )
        case 13:
            return RouteDetail(
                title: "Burgos to Hornillos del Camino",
                startPoint: LocationPoint(
                    name: "Burgos",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Cordón, head west.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7040)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Tardajos",
                        distance: 10.0,
                        services: nil,
                        details: "Village with a bar and church.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3500, longitude: -3.8200)
                    ),
                    LocationPoint(
                        name: "Rabé de las Calzadas",
                        distance: 13.0,
                        services: nil,
                        details: "Small village with an albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3400, longitude: -3.8500)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Hornillos del Camino",
                    distance: 21.0,
                    services: nil,
                    details: "End at De Sol A Sol, near the main street.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3390, longitude: -3.9240)
                ),
                ascent: 70,
                descent: 90
            )
        case 14:
            return RouteDetail(
                title: "Hornillos del Camino to Castrojeriz",
                startPoint: LocationPoint(
                    name: "Hornillos del Camino",
                    distance: 0.0,
                    services: nil,
                    details: "Start at De Sol A Sol, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3390, longitude: -3.9240)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Hontanas",
                        distance: 6.0,
                        services: nil,
                        details: "Village with a bar and fountain.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3100, longitude: -4.0500)
                    ),
                    LocationPoint(
                        name: "San Antón Ruins",
                        distance: 10.0,
                        services: nil,
                        details: "Gothic ruins of a former hospital.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3000, longitude: -4.0800)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Castrojeriz",
                    distance: 20.0,
                    services: nil,
                    details: "End at A Cien Leguas, near the Church of Santo Domingo.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.2880, longitude: -4.1380)
                ),
                ascent: 140,
                descent: 160
            )
        case 15:
            return RouteDetail(
                title: "Castrojeriz to Frómista",
                startPoint: LocationPoint(
                    name: "Castrojeriz",
                    distance: 0.0,
                    services: nil,
                    details: "Start at A Cien Leguas, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.2880, longitude: -4.1380)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Itero de la Vega",
                        distance: 10.0,
                        services: nil,
                        details: "Village with a bridge over the Pisuerga River.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.2800, longitude: -4.2600)
                    ),
                    LocationPoint(
                        name: "Boadilla del Camino",
                        distance: 18.0,
                        services: nil,
                        details: "Village with a bar and historic rollo.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.2700, longitude: -4.3500)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Frómista",
                    distance: 25.0,
                    services: nil,
                    details: "End at Eco Hotel Doña Mayor, near the Church of San Martín.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060)
                ),
                ascent: 90,
                descent: 175
            )
        case 16:
            return RouteDetail(
                title: "Frómista to Carrión de los Condes",
                startPoint: LocationPoint(
                    name: "Frómista",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Eco Hotel Doña Mayor, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Población de Campos",
                        distance: 6.0,
                        services: nil,
                        details: "Village with a bar and church.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.2700, longitude: -4.4500)
                    ),
                    LocationPoint(
                        name: "Villalcázar de Sirga",
                        distance: 13.0,
                        services: nil,
                        details: "Village with a Templar church.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3200, longitude: -4.5400)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Carrión de los Condes",
                    distance: 19.0,
                    services: nil,
                    details: "End at Hostal La Corte, near Plaza Mayor.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030)
                ),
                ascent: 120,
                descent: 60
            )
        case 17:
            return RouteDetail(
                title: "Carrión de los Condes to Calzadilla de la Cueza",
                startPoint: LocationPoint(
                    name: "Carrión de los Condes",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hostal La Corte, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030)
                ),
                waypoints: [
                    // No intermediate waypoints listed in TXT
                ],
                endPoint: LocationPoint(
                    name: "Calzadilla de la Cueza",
                    distance: 17.0,
                    services: nil,
                    details: "End at Hostal Camino Real, near the main street.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.8020)
                ),
                ascent: 140,
                descent: 110
            )
        case 18:
            return RouteDetail(
                title: "Calzadilla de la Cueza to Sahagún",
                startPoint: LocationPoint(
                    name: "Calzadilla de la Cueza",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hostal Camino Real, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.8020)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Ledigos",
                        distance: 6.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.8700)
                    ),
                    LocationPoint(
                        name: "Terradillos de los Templarios",
                        distance: 10.0,
                        services: nil,
                        details: "Village with an albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3600, longitude: -4.9000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Sahagún",
                    distance: 22.0,
                    services: nil,
                    details: "End at Hostal Domus Viatoris, near Arco de San Benito.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290)
                ),
                ascent: 60,
                descent: 90
            )
        case 19:
            return RouteDetail(
                title: "Sahagún to El Burgo Ranero",
                startPoint: LocationPoint(
                    name: "Sahagún",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hostal Domus Viatoris, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Bercianos del Real Camino",
                        distance: 10.0,
                        services: nil,
                        details: "Village with a bar and albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.3900, longitude: -5.1400)
                    )
                ],
                endPoint: LocationPoint(
                    name: "El Burgo Ranero",
                    distance: 18.0,
                    services: nil,
                    details: "End at Hotel Castillo El Burgo, near the main road.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4230, longitude: -5.2210)
                ),
                ascent: 50,
                descent: 120
            )
        case 20:
            return RouteDetail(
                title: "El Burgo Ranero to Mansilla de las Mulas",
                startPoint: LocationPoint(
                    name: "El Burgo Ranero",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Castillo El Burgo, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4230, longitude: -5.2210)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Reliegos",
                        distance: 6.0,
                        services: nil,
                        details: "Village with a bar and murals.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4700, longitude: -5.2900)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Mansilla de las Mulas",
                    distance: 19.0,
                    services: nil,
                    details: "End at Albergueria del Camino, near Plaza del Grano.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.4170)
                ),
                ascent: 100,
                descent: 120
            )
        case 21:
            return RouteDetail(
                title: "Mansilla de las Mulas to León",
                startPoint: LocationPoint(
                    name: "Mansilla de las Mulas",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Albergueria del Camino, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.4170)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Puente Castro",
                        distance: 12.0,
                        services: nil,
                        details: "Village with a bridge over the Torío River.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.5800, longitude: -5.5100)
                    )
                ],
                endPoint: LocationPoint(
                    name: "León",
                    distance: 18.0,
                    services: nil,
                    details: "End at Hotel Alda Vía León, near the Cathedral.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710)
                ),
                ascent: 150,
                descent: 50
            )
        case 22:
            return nil
        case 23:
            return RouteDetail(
                title: "León to Chozas de Abajo (Villar de Mazarife)",
                startPoint: LocationPoint(
                    name: "León",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Alda Vía León, head southwest via Villar de Mazarife route.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710)
                ),
                waypoints: [
                    LocationPoint(
                        name: "La Virgen del Camino",
                        distance: 7.0,
                        services: nil,
                        details: "Town with a sanctuary and services.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.5800, longitude: -5.6500)
                    ),
                    LocationPoint(
                        name: "Villar de Mazarife",
                        distance: 20.0,
                        services: nil,
                        details: "Village with a bar and albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.5100, longitude: -5.6800)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Chozas de Abajo",
                    distance: 22.0,
                    services: nil,
                    details: "End at Albergue San Antonio de Padua, near Camino León.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.6860)
                ),
                ascent: 180,
                descent: 670
            )
        case 24:
            return RouteDetail(
                title: "Chozas de Abajo to Astorga",
                startPoint: LocationPoint(
                    name: "Chozas de Abajo",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Albergue San Antonio de Padua, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.6860)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Hospital de Órbigo",
                        distance: 15.0,
                        services: nil,
                        details: "Town with a historic bridge.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4600, longitude: -5.8800)
                    ),
                    LocationPoint(
                        name: "Santibáñez de Valdeiglesias",
                        distance: 20.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4500, longitude: -5.9500)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Astorga",
                    distance: 27.0,
                    services: nil,
                    details: "End at Hotel Astur Plaza, near Plaza de España.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4580, longitude: -6.0530)
                ),
                ascent: 100,
                descent: 160
            )
        case 25:
            return RouteDetail(
                title: "Astorga to Rabanal del Camino",
                startPoint: LocationPoint(
                    name: "Astorga",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Astur Plaza, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4580, longitude: -6.0530)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Santa Catalina de Somoza",
                        distance: 8.0,
                        services: nil,
                        details: "Village with a bar and albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4700, longitude: -6.1500)
                    ),
                    LocationPoint(
                        name: "El Ganso",
                        distance: 13.0,
                        services: nil,
                        details: "Small village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4700, longitude: -6.2000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Rabanal del Camino",
                    distance: 20.0,
                    services: nil,
                    details: "End at Hotel Rural Casa Indie, near the main street.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840)
                ),
                ascent: 720,
                descent: 120
            )
        case 26:
            return RouteDetail(
                title: "Rabanal del Camino to Ponferrada",
                startPoint: LocationPoint(
                    name: "Rabanal del Camino",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Rural Casa Indie, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Cruz de Ferro",
                        distance: 5.0,
                        services: nil,
                        details: "Iconic iron cross where pilgrims leave stones.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4900, longitude: -6.3500)
                    ),
                    LocationPoint(
                        name: "Foncebadón",
                        distance: 8.0,
                        services: nil,
                        details: "Village with a bar and albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.4900, longitude: -6.3700)
                    ),
                    LocationPoint(
                        name: "Acebo",
                        distance: 16.0,
                        services: nil,
                        details: "Village with a bar and scenic views.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.5000, longitude: -6.4500)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Ponferrada",
                    distance: 32.0,
                    services: nil,
                    details: "End at Hotel El Castillo, near the Templar Castle.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5900)
                ),
                ascent: 150,
                descent: 570
            )
        case 27:
            return RouteDetail(
                title: "Ponferrada to Villafranca del Bierzo",
                startPoint: LocationPoint(
                    name: "Ponferrada",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel El Castillo, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5900)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Cacabelos",
                        distance: 15.0,
                        services: nil,
                        details: "Town with all services and a church.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6000, longitude: -6.7200)
                    ),
                    LocationPoint(
                        name: "Pieros",
                        distance: 20.0,
                        services: nil,
                        details: "Small village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6100, longitude: -6.7700)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Villafranca del Bierzo",
                    distance: 24.0,
                    services: nil,
                    details: "End at Hostal Tres Campanas, near the Church of Santiago.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110)
                ),
                ascent: 300,
                descent: 400
            )
        case 28:
            return RouteDetail(
                title: "Villafranca del Bierzo to O Cebreiro",
                startPoint: LocationPoint(
                    name: "Villafranca del Bierzo",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hostal Tres Campanas, head west.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Pereje",
                        distance: 5.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6200, longitude: -6.8600)
                    ),
                    LocationPoint(
                        name: "Trabadelo",
                        distance: 9.0,
                        services: nil,
                        details: "Village with an albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6300, longitude: -6.9000)
                    ),
                    LocationPoint(
                        name: "Vega de Valcarce",
                        distance: 15.0,
                        services: nil,
                        details: "Village with bars and services.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.6600, longitude: -6.9400)
                    )
                ],
                endPoint: LocationPoint(
                    name: "O Cebreiro",
                    distance: 28.0,
                    services: nil,
                    details: "End at Casa Navarro, near the church of Santa María la Real.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0020)
                ),
                ascent: 250,
                descent: 170
            )
        case 29:
            return RouteDetail(
                title: "O Cebreiro to Triacastela",
                startPoint: LocationPoint(
                    name: "O Cebreiro",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Casa Navarro, head east.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0020)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Alto de San Roque",
                        distance: 4.0,
                        services: nil,
                        details: "High point with a pilgrim statue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7100, longitude: -7.0500)
                    ),
                    LocationPoint(
                        name: "Liñares",
                        distance: 6.0,
                        services: nil,
                        details: "Small village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7200, longitude: -7.0700)
                    ),
                    LocationPoint(
                        name: "Hospital da Condesa",
                        distance: 9.0,
                        services: nil,
                        details: "Village with an albergue.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7300, longitude: -7.1000)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Triacastela",
                    distance: 21.0,
                    services: nil,
                    details: "End at Complexo Xacobeo, near the town center.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.7560, longitude: -7.2340)
                ),
                ascent: 380,
                descent: 340
            )
        case 30:
            return RouteDetail(
                title: "Triacastela to Sarria (Via San Xil)",
                startPoint: LocationPoint(
                    name: "Triacastela",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Complexo Xacobeo, head south via San Xil route.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.7560, longitude: -7.2340)
                ),
                waypoints: [
                    LocationPoint(
                        name: "San Xil",
                        distance: 6.0,
                        services: nil,
                        details: "Village with a vending machine.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7400, longitude: -7.2600)
                    ),
                    LocationPoint(
                        name: "Furela",
                        distance: 12.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7200, longitude: -7.2800)
                    ),
                    LocationPoint(
                        name: "Pintín",
                        distance: 15.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7150, longitude: -7.2850)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Sarria",
                    distance: 18.5,
                    services: nil,
                    details: "End at Hotel Mar de Plata, near Rúa Maior.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.7810, longitude: -7.4140)
                ),
                ascent: 270,
                descent: 380
            )
        case 31:
            return RouteDetail(
                title: "Sarria to Portomarín",
                startPoint: LocationPoint(
                    name: "Sarria",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Mar de Plata, head south via Rúa Maior.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.7810, longitude: -7.4140)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Barbadelo",
                        distance: 4.0,
                        services: nil,
                        details: "Village with a rest area.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7650, longitude: -7.4300)
                    ),
                    LocationPoint(
                        name: "Ferreiros",
                        distance: 10.0,
                        services: nil,
                        details: "Village with a bar and church.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7200, longitude: -7.4750)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Portomarín",
                    distance: 22.0,
                    services: nil,
                    details: "End at Casona Da Ponte Portomarín, near the Church of San Nicolás.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160)
                ),
                ascent: 180,
                descent: 230
            )
        case 32:
            return RouteDetail(
                title: "Portomarín to Palas de Rei",
                startPoint: LocationPoint(
                    name: "Portomarín",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Casona Da Ponte Portomarín, head east.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Gonzar",
                        distance: 8.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7800, longitude: -7.6250)
                    ),
                    LocationPoint(
                        name: "Castromaior",
                        distance: 12.0,
                        services: nil,
                        details: "Village with a bar and pre-Roman fort.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7750, longitude: -7.6300)
                    ),
                    LocationPoint(
                        name: "Hospital da Cruz",
                        distance: 15.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7700, longitude: -7.6350)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Palas de Rei",
                    distance: 25.0,
                    services: nil,
                    details: "End at Hotel Mica, near the town center.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8730, longitude: -7.8690)
                ),
                ascent: 160,
                descent: 140
            )
        case 33:
            return RouteDetail(
                title: "Palas de Rei to Arzúa",
                startPoint: LocationPoint(
                    name: "Palas de Rei",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Mica, head east.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8730, longitude: -7.8690)
                ),
                waypoints: [
                    LocationPoint(
                        name: "San Xulián",
                        distance: 4.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.7200, longitude: -7.6950)
                    ),
                    LocationPoint(
                        name: "Melide",
                        distance: 14.0,
                        services: nil,
                        details: "Town with all services, known for octopus dishes.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.9147, longitude: -8.0150)
                    ),
                    LocationPoint(
                        name: "Boente",
                        distance: 20.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.9100, longitude: -8.0200)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Arzúa",
                    distance: 29.0,
                    services: nil,
                    details: "End at Hotel Arzúa, near the town center.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.9280, longitude: -8.1600)
                ),
                ascent: 240,
                descent: 310
            )
        case 34:
            return RouteDetail(
                title: "Arzúa to A Rúa",
                startPoint: LocationPoint(
                    name: "Arzúa",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Arzúa, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.9280, longitude: -8.1600)
                ),
                waypoints: [
                    LocationPoint(
                        name: "Preguntoño",
                        distance: 5.0,
                        services: nil,
                        details: "Village with an underpass.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.8750, longitude: -8.1650)
                    ),
                    LocationPoint(
                        name: "Salceda",
                        distance: 11.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.8450, longitude: -8.1950)
                    ),
                    LocationPoint(
                        name: "Santa Irene",
                        distance: 15.0,
                        services: nil,
                        details: "Village with a bar.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.8300, longitude: -8.2100)
                    )
                ],
                endPoint: LocationPoint(
                    name: "A Rúa",
                    distance: 19.0,
                    services: nil,
                    details: "End at Hotel Rural O Acivro, near O Pedrouzo.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.9080, longitude: -8.3670)
                ),
                ascent: nil,
                descent: nil
            )
        case 35:
            return RouteDetail(
                title: "A Rúa to Santiago de Compostela",
                startPoint: LocationPoint(
                    name: "A Rúa",
                    distance: 0.0,
                    services: nil,
                    details: "Start at Hotel Rural O Acivro, head southwest.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.9080, longitude: -8.3670)
                ),
                waypoints: [
                    LocationPoint(
                        name: "O Pedrouzo",
                        distance: 2.0,
                        services: nil,
                        details: "Town with all services.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.8200, longitude: -8.2200)
                    ),
                    LocationPoint(
                        name: "Monte do Gozo",
                        distance: 15.0,
                        services: nil,
                        details: "Complex with views of Santiago.",
                        coordinate: CLLocationCoordinate2D(latitude: 42.8850, longitude: -8.4450)
                    )
                ],
                endPoint: LocationPoint(
                    name: "Santiago de Compostela",
                    distance: 20.0,
                    services: nil,
                    details: "End at Hotel Alda Avenida, near Praza do Obradoiro.",
                    coordinate: CLLocationCoordinate2D(latitude: 42.8800, longitude: -8.5450)
                ),
                ascent: nil,
                descent: nil
            )
        default:
            return nil
        }
    }
}

// MARK: - Helper View for Hotel Information
private struct HotelInfoView: View {
    let destination: CaminoDestination

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let checkIn = destination.checkInInfo {
                detailRow(label: "Check-in:", value: checkIn)
            }
            if let checkOut = destination.checkOutInfo {
                detailRow(label: "Check-out:", value: checkOut)
            }
            if let bookingRef = destination.bookingReference {
                detailRow(label: "Booking Ref:", value: bookingRef)
            }
            if let room = destination.roomDetails {
                detailRow(label: "Room:", value: room)
            }
            if let meals = destination.mealDetails {
                detailRow(label: "Meals:", value: meals)
            }
            if let luggage = destination.luggageTransferInfo {
                Divider().padding(.vertical, 4)
                VStack(alignment: .leading) {
                    Text("Luggage Transfer:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(luggage)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    // Helper for consistent row formatting
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 110, alignment: .leading) // Align labels
            Text(value)
                .font(.body)
            Spacer() // Pushes content to the left
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        DestinationDetailView(destination: CaminoDestination.allDestinations[1]) // Use Day 1 for preview
            .environmentObject(CaminoAppState())
    }
} 