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
    let nextDestinationName: String?
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    
    init(destination: CaminoDestination, nextDestinationName: String? = nil) {
        self.destination = destination
        self.nextDestinationName = nextDestinationName
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
                    details: "Begin at the medieval bridge over the River Nive, proceed to Rue d'Espagne, turn right after 100 m onto the \"Route de Napoleon\" (steep, follows the Via Aquitaine Roman road)."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Honto",
                        distance: 5.0,
                        services: nil,
                        details: "After Honto, take a left-hand path to avoid a road curve, rejoin the road, and head to Orisson."
                    ),
                    LocationPoint(
                        name: "Orisson",
                        distance: 7.6,
                        services: "Bar, Restaurant",
                        details: "Continue on a low-traffic road through alpine meadows; 4 km ahead, spot the Virgin of Biakorri statue (shepherds' protector) on the left if clear."
                    ),
                    LocationPoint(
                        name: "Arnéguy",
                        distance: 12.7,
                        services: nil,
                        details: "Pass Arnéguy on the right (option to link to Valcarlos), leave the road after 2.0 km for a right-hand path by the Urdanarre Cross."
                    ),
                    LocationPoint(
                        name: "Collado de Bentartea",
                        distance: 16.2,
                        services: "Bentartea Pass",
                        details: "After 1.4 km, reach the pass with Roldán Fountain (commemorates Charlemagne's officer, 778). Follow a beech forest track along the border fence, pass a stone pillar marking Navarre, take a right-hand track along Txangoa and Menditxipi mountains' northern slopes."
                    ),
                    LocationPoint(
                        name: "Collado de Lepoeder",
                        distance: 20.2,
                        services: nil,
                        details: "Two descent options: 1) Direct Route: Steep descent through Mount Donsimon beech forest (caution in fog), go right then left of the road. 2) Ibañeta Pass Route: Divert to Ibañeta Pass (Monument to Roldan, Chapel), descend left of the national road."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Roncesvalles",
                    distance: 23.9,
                    services: "Bar-restaurant, Tourism Office",
                    details: "Arrive via descent into this historic Jacobean town."
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
                    details: "Exit on the N-135, take a right-hand path through Sorginaritzaga Forest (oaks, beeches), pass the Cross of the Pilgrims (Gothic, 1880) after 100 m, stay right of the road, turn left at Ipetea industrial park, enter Burguete."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Burguete",
                        distance: 2.8,
                        services: "Bars, Stores, Health Center, Pharmacy, ATM",
                        details: "Cross via the main street, pass the Parish Church of San Nicolas, turn right, cross a footbridge over a stream to the Urrobi River, climb a wooded trail with water sources and a steep hill."
                    ),
                    LocationPoint(
                        name: "Espinal",
                        distance: 6.5,
                        services: "Bar, Store, Medical Clinic",
                        details: "After 2.6 km, enter via a paved path, head right (bar and bakery nearby), follow the sidewalk, turn left after a crosswalk, climb to Mezkiritz."
                    ),
                    LocationPoint(
                        name: "Alto de Mezkiritz",
                        distance: 8.2,
                        services: "924 m",
                        details: "Cross the N-135, see the Virgen of Roncesvalles carving, descend on a wooded trail (some deteriorated), enter a beech forest via a metal gate, reach Bizkarreta."
                    ),
                    LocationPoint(
                        name: "Bizkarreta",
                        distance: 11.5,
                        services: nil,
                        details: "Historic stage end with a former pilgrims' hospital (12th century)."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Zubiri",
                    distance: 21.5,
                    services: "All services",
                    details: "Cross the 14th-century \"Bridge of Rabies\" over the Arga River (Santa Quiteria legend)."
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
                    details: "Cross the entry bridge, follow the Arga River valley, pass a magnesite factory (1 km), ascend its perimeter, descend stairs, continue on pleasant roads."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Ilarratz",
                        distance: 2.9,
                        services: "Drinking fountain",
                        details: nil
                    ),
                    LocationPoint(
                        name: "Ezkirotz",
                        distance: 3.7,
                        services: "Drinking fountain",
                        details: nil
                    ),
                    LocationPoint(
                        name: "Larrasoaña",
                        distance: 5.5,
                        services: "Bar, Store, Supermarket, Medical Clinic",
                        details: "Exit via the entry bridge, keep the Arga River right, ascend to Akerreta (off-path across the river)."
                    ),
                    LocationPoint(
                        name: "Akerreta",
                        distance: 6.1,
                        services: nil,
                        details: "Pass the Church of the Transfiguration, go by a rural hotel, cross a gate and gravel stretch, reach a local road, cross it, descend to the Arga River shore, follow to Zuriain."
                    ),
                    LocationPoint(
                        name: "Zuriain",
                        distance: 9.2,
                        services: "Bar",
                        details: "Walk beside the N-135 for 600 m, turn left, cross the Arga River."
                    ),
                    LocationPoint(
                        name: "Irotz",
                        distance: 11.2,
                        services: "Bar",
                        details: "Pass the Church of San Pedro, reach the Romanesque Iturgaiz Bridge, choose: Arre (narrow trail to Zabaldika) or Riverside Walk (to Huarte)."
                    ),
                    LocationPoint(
                        name: "Trinidad de Arre",
                        distance: 16.0,
                        services: nil,
                        details: "Cross the medieval bridge over the Ultzama River, turn left."
                    ),
                    LocationPoint(
                        name: "Villava",
                        distance: 16.4,
                        services: "All services",
                        details: "Follow Mayor de Villava Street, cross the road, pass roundabouts, link to Burlada."
                    ),
                    LocationPoint(
                        name: "Burlada",
                        distance: 17.5,
                        services: "All services",
                        details: "Cross Main Street, turn right at a mechanic, cross a pedestrian walkway, follow pavement markers, turn left onto the Camino of Burlada walkway."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Pamplona",
                    distance: 21.8,
                    services: "All services",
                    details: "Cross the Magdalena Bridge over the Arga River, follow the moat (Bastion of Our Lady of Guadalupe), enter via Portal de Francia (1553), proceed through Carmen streets, turn left on De Curia Street."
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
                    details: "Exit via the historic center, climb the Sierra del Perdon (260 m ascent, steeper at the end), pass wind turbines and the Pilgrims' Monument."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Cizur Menor",
                        distance: 5.0,
                        services: "Bar, store",
                        details: "Pass the Church of San Miguel, continue on a paved path."
                    ),
                    LocationPoint(
                        name: "Alto del Perdon",
                        distance: 13.0,
                        services: "770 m",
                        details: "Reach the ridge, descend on a rocky path (caution advised)."
                    ),
                    LocationPoint(
                        name: "Uterga",
                        distance: 16.5,
                        services: "Bar",
                        details: "Enter via a dirt track, continue westward."
                    ),
                    LocationPoint(
                        name: "Obanos",
                        distance: 19.5,
                        services: "Bar, store",
                        details: "Pass the Church of San Juan Bautista, merge with the Aragonés Camino route."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Puente la Reina",
                    distance: 24.0,
                    services: "All services",
                    details: "Cross the iconic 11th-century bridge over the Arga River; optional detour to the Hermitage of Santa Maria de Eunate (2 km off-route)."
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
                    details: "Cross the famous medieval bridge, follow the main road west, and take the path along the Arga River."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Mañeru",
                        distance: 4.6,
                        services: "Bar, store",
                        details: "Village on a hillside, follow main street through the center."
                    ),
                    LocationPoint(
                        name: "Cirauqui",
                        distance: 8.1,
                        services: "Bar, store, pharmacy",
                        details: "Enter through medieval gate, follow steep streets, exit via Roman road."
                    ),
                    LocationPoint(
                        name: "Lorca",
                        distance: 15.5,
                        services: "Bar, water fountain",
                        details: "Small village with fountain, continue straight through."
                    ),
                    LocationPoint(
                        name: "Villatuerta",
                        distance: 18.8,
                        services: "Bar, store",
                        details: "Cross river, follow path up the hill into town."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Estella",
                    distance: 22.5,
                    services: "All services",
                    details: "Historic town with many medieval buildings and churches. Enter via the north bridge and follow signs to the center."
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
                    details: "Exit via the Monastery of Irache, visit the famous wine fountain (Fuente del Vino)."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Irache",
                        distance: 2.2,
                        services: "Wine fountain, monastery",
                        details: "Pass the notable 12th-century monastery and the wine fountain where pilgrims can take a free drink."
                    ),
                    LocationPoint(
                        name: "Azqueta",
                        distance: 5.7,
                        services: "Bar, water",
                        details: "Small village with pilgrim fountain, continue through main street."
                    ),
                    LocationPoint(
                        name: "Villamayor de Monjardín",
                        distance: 8.1,
                        services: "Bar, fountain",
                        details: "Village at the foot of Mount Monjardín, with the ruins of San Esteban de Deyo Castle above."
                    ),
                    LocationPoint(
                        name: "Luquin",
                        distance: 14.6,
                        services: "Water",
                        details: "Cross fields, follow dirt path through olive groves."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Los Arcos",
                    distance: 21.3,
                    services: "All services",
                    details: "Town centered around the impressive Church of Santa María, with many bars and restaurants in the main square."
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
                    details: "Leave town via the west, cross the River Odrón, follow path through vineyards and farmland."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Torres del Río",
                        distance: 7.6,
                        services: "Bar, fountain",
                        details: "Village with an octagonal church (Church of the Holy Sepulchre), continue west."
                    ),
                    LocationPoint(
                        name: "Viana",
                        distance: 17.8,
                        services: "All services",
                        details: "Historic walled town, impressive Church of Santa María, pass by where Cesare Borgia died in 1507."
                    ),
                    LocationPoint(
                        name: "Navarre-La Rioja Border",
                        distance: 20.1,
                        services: nil,
                        details: "Cross from Navarre into La Rioja region, marked by a stone monument."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Logroño",
                    distance: 28.2,
                    services: "All services",
                    details: "Capital of La Rioja, enter via the Stone Bridge (Puente de Piedra), visit the Cathedral of Santa María de la Redonda."
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
                    details: "Exit through the west side, pass Parque de la Grajera, follow path through vineyards."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Navarrete",
                        distance: 12.9,
                        services: "Bars, restaurants, shops",
                        details: "Town known for pottery, see the Church of the Assumption and Santiago ruins."
                    ),
                    LocationPoint(
                        name: "Ventosa",
                        distance: 18.2,
                        services: "Bar, fountain",
                        details: "Small hill village with views of vineyards, follow main road through town."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Nájera",
                    distance: 29.0,
                    services: "All services",
                    details: "Historic town on the Najerilla River, visit the Monastery of Santa María la Real with royal pantheon."
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
                    details: "Cross the Najerilla River, climb steadily through grain fields and vineyards."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Azofra",
                        distance: 5.5,
                        services: "Bar, fountain, store",
                        details: "Traditional pilgrim stop with fountain in the main square."
                    ),
                    LocationPoint(
                        name: "Cirueña",
                        distance: 12.0,
                        services: "Bar",
                        details: "Small village near golf course, follow path through fields."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Santo Domingo de la Calzada",
                    distance: 21.0,
                    services: "All services",
                    details: "Named after saint who built bridges for pilgrims, visit the cathedral with live chickens (related to the famous miracle)."
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
                    services: "All services",
                    details: "Exit via the east, pass stone crosses marking the way, enter the province of Burgos."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Grañón",
                        distance: 6.2,
                        services: "Bar, fountain",
                        details: "Last village in La Rioja, Church of San Juan Bautista with panoramic views."
                    ),
                    LocationPoint(
                        name: "Redecilla del Camino",
                        distance: 7.8,
                        services: "Bar, fountain",
                        details: "First village in Castilla y León region, 12th-century baptismal font in the Church of La Virgen de la Calle."
                    ),
                    LocationPoint(
                        name: "Viloria de Rioja",
                        distance: 9.3,
                        services: "Water",
                        details: "Birthplace of Santo Domingo, small village with stone houses."
                    ),
                    LocationPoint(
                        name: "Villamayor del Río",
                        distance: 12.7,
                        services: "Bar",
                        details: "Small village with single main street, continue along the N-120."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Belorado",
                    distance: 22.7,
                    services: "All services",
                    details: "Medieval town with arcaded Plaza Mayor, visit the Church of Santa María and the ethnographic museum."
                ),
                ascent: 170,
                descent: 250
            )
        // Add all remaining days with similar level of detail
        case 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33:
            // For days we haven't explicitly coded yet, create basic route details with key stopping points
            let titles = [
                11: "Belorado to San Juan de Ortega",
                12: "San Juan de Ortega to Burgos",
                13: "Burgos to Hornillos del Camino",
                14: "Hornillos del Camino to Castrojeriz",
                15: "Castrojeriz to Frómista",
                16: "Frómista to Carrión de los Condes",
                17: "Carrión de los Condes to Terradillos de los Templarios",
                18: "Terradillos de los Templarios to El Burgo Ranero",
                19: "El Burgo Ranero to León",
                20: "León to San Martín del Camino",
                21: "San Martín del Camino to Astorga",
                22: "Astorga to Rabanal del Camino",
                23: "Rabanal del Camino to Ponferrada",
                24: "Ponferrada to Villafranca del Bierzo",
                25: "Villafranca del Bierzo to O Cebreiro",
                26: "O Cebreiro to Triacastela",
                27: "Triacastela to Sarria",
                28: "Sarria to Portomarín",
                29: "Portomarín to Palas de Rei",
                30: "Palas de Rei to Melide",
                31: "Melide to Arzúa",
                32: "Arzúa to Pedrouzo",
                33: "Pedrouzo to Santiago de Compostela"
            ]
            
            let distances = [
                11: 24.0,
                12: 25.3,
                13: 21.0,
                14: 20.0,
                15: 25.0,
                16: 19.5,
                17: 26.5,
                18: 24.0,
                19: 37.0,
                20: 24.8,
                21: 23.7,
                22: 21.0,
                23: 32.0,
                24: 24.5,
                25: 28.5,
                26: 21.0,
                27: 18.7,
                28: 22.0,
                29: 24.0,
                30: 14.0,
                31: 14.0,
                32: 19.0,
                33: 19.0
            ]
            
            let ascents = [
                11: 370,
                12: 150,
                13: 70,
                14: 140,
                15: 90,
                16: 120,
                17: 140,
                18: 60,
                19: 50,
                20: 100,
                21: 150,
                22: 500,
                23: 180,
                24: 100,
                25: 720,
                26: 150,
                27: 300,
                28: 250,
                29: 380,
                30: 270,
                31: 180,
                32: 160,
                33: 240
            ]
            
            let descents = [
                11: 210,
                12: 280,
                13: 90,
                14: 160,
                15: 175,
                16: 60,
                17: 110,
                18: 90,
                19: 120,
                20: 120,
                21: 50,
                22: 90,
                23: 670,
                24: 160,
                25: 120,
                26: 570,
                27: 400,
                28: 170,
                29: 340,
                30: 380,
                31: 230,
                32: 140,
                33: 310
            ]
            
            // Create placeholder route details with basic information
            if let title = titles[day], let distance = distances[day] {
                let startPlace = title.components(separatedBy: " to ")[0]
                let endPlace = title.components(separatedBy: " to ")[1]
                
                return RouteDetail(
                    title: title,
                    startPoint: LocationPoint(
                        name: startPlace,
                        distance: 0.0,
                        services: "Various services",
                        details: "Starting point for day \(day) of the Camino journey."
                    ),
                    waypoints: [
                        LocationPoint(
                            name: "Midpoint",
                            distance: distance / 2,
                            services: "Water, rest area",
                            details: "Approximately halfway point of today's journey."
                        )
                    ],
                    endPoint: LocationPoint(
                        name: endPlace,
                        distance: distance,
                        services: "Various services",
                        details: "End of day \(day) on the Camino journey."
                    ),
                    ascent: ascents[day],
                    descent: descents[day]
                )
            }
            
            return nil
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
        DestinationDetailView(destination: CaminoDestination.allDestinations[0], nextDestinationName: CaminoDestination.allDestinations[1].locationName)
            .environmentObject(CaminoAppState())
    }
} 