import SwiftUI
import MapKit
import CoreLocation

// MARK: - Destination Model
struct Destination: Identifiable {
    let id = UUID()
    let day: Int
    let locationName: String
    let hotelName: String
    let coordinate: CLLocationCoordinate2D
    
    static let allDestinations: [Destination] = [
        Destination(day: 0, locationName: "Saint-Jean-Pied-de-Port", hotelName: "Villa Goxoki", coordinate: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386)),
        Destination(day: 1, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", coordinate: CLLocationCoordinate2D(latitude: 42.9878, longitude: -1.3197)),
        Destination(day: 2, locationName: "Zubiri", hotelName: "Hosteria de Zubiri", coordinate: CLLocationCoordinate2D(latitude: 42.9321, longitude: -1.5036)),
        Destination(day: 3, locationName: "Pamplona", hotelName: "Hotel A Pamplona", coordinate: CLLocationCoordinate2D(latitude: 42.8110, longitude: -1.6450)),
        Destination(day: 4, locationName: "Puente la Reina", hotelName: "Hotel El Cerco", coordinate: CLLocationCoordinate2D(latitude: 42.6728, longitude: -1.8115)),
        Destination(day: 5, locationName: "Estella", hotelName: "Alda Estella Hostal", coordinate: CLLocationCoordinate2D(latitude: 42.6708, longitude: -2.0295)),
        Destination(day: 6, locationName: "Los Arcos", hotelName: "Pensión Los Arcos", coordinate: CLLocationCoordinate2D(latitude: 42.5715, longitude: -2.1918)),
        Destination(day: 7, locationName: "Logroño", hotelName: "Hotel Ciudad de Logroño", coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450)),
        Destination(day: 8, locationName: "Nájera", hotelName: "Hotel Duques de Nájera", coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7290)),
        Destination(day: 9, locationName: "Santo Domingo de la Calzada", hotelName: "El Molino de Floren", coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530)),
        Destination(day: 10, locationName: "Belorado", hotelName: "Hostel Punto B", coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910)),
        Destination(day: 11, locationName: "San Juan de Ortega", hotelName: "Hotel Rural la Iglesia", coordinate: CLLocationCoordinate2D(latitude: 42.3760, longitude: -3.4370)),
        Destination(day: 12, locationName: "Burgos", hotelName: "Hotel Cordón", coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7010)),
        Destination(day: 13, locationName: "Hornillos del Camino", hotelName: "De Sol A Sol", coordinate: CLLocationCoordinate2D(latitude: 42.3130, longitude: -4.0460)),
        Destination(day: 14, locationName: "Castrojeriz", hotelName: "A Cien Leguas", coordinate: CLLocationCoordinate2D(latitude: 42.2900, longitude: -4.1380)),
        Destination(day: 15, locationName: "Frómista", hotelName: "Eco Hotel Doña Mayor", coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060)),
        Destination(day: 16, locationName: "Carrión de los Condes", hotelName: "Hostal La Corte", coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030)),
        Destination(day: 17, locationName: "Calzadilla de la Cueza", hotelName: "Hostal Camino Real", coordinate: CLLocationCoordinate2D(latitude: 42.3630, longitude: -4.8860)),
        Destination(day: 18, locationName: "Sahagún", hotelName: "Hostal Domus Viatoris", coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290)),
        Destination(day: 19, locationName: "El Burgo Ranero", hotelName: "Hotel Castillo El Burgo", coordinate: CLLocationCoordinate2D(latitude: 42.4220, longitude: -5.2200)),
        Destination(day: 20, locationName: "Mansilla de las Mulas", hotelName: "Alberguería del Camino", coordinate: CLLocationCoordinate2D(latitude: 42.4990, longitude: -5.4170)),
        Destination(day: 21, locationName: "León", hotelName: "Hotel Alda Vía León", coordinate: CLLocationCoordinate2D(latitude: 42.5990, longitude: -5.5710)),
        Destination(day: 22, locationName: "Villadangos del Páramo", hotelName: "TBD", coordinate: CLLocationCoordinate2D(latitude: 42.5160, longitude: -5.7660)),
        Destination(day: 23, locationName: "Chozas de Abajo", hotelName: "Albergue San Antonio", coordinate: CLLocationCoordinate2D(latitude: 42.5060, longitude: -5.6830)),
        Destination(day: 24, locationName: "Astorga", hotelName: "Hotel Astur Plaza", coordinate: CLLocationCoordinate2D(latitude: 42.4570, longitude: -6.0560)),
        Destination(day: 25, locationName: "Rabanal del Camino", hotelName: "Hotel Rural Casa Indie", coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840)),
        Destination(day: 26, locationName: "Ponferrada", hotelName: "Hotel El Castillo", coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5960)),
        Destination(day: 27, locationName: "Villafranca del Bierzo", hotelName: "Hostal Tres Campanas", coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110)),
        Destination(day: 28, locationName: "O Cebreiro", hotelName: "Casa Navarro", coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0420)),
        Destination(day: 29, locationName: "Triacastela", hotelName: "Complexo Xacobeo", coordinate: CLLocationCoordinate2D(latitude: 42.7550, longitude: -7.2370))
    ]
}

// MARK: - MapViewModel
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.6, longitude: -5.5),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isOffRoute = false
    
    private let locationManager = CLLocationManager()
    private let routeCoordinates: [CLLocationCoordinate2D]
    
    override init() {
        routeCoordinates = Destination.allDestinations.map { $0.coordinate }
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        // Check if user is off route (more than 100 meters from nearest point)
        let nearestPoint = routeCoordinates.min(by: { point1, point2 in
            let distance1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
                .distance(from: location)
            let distance2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
                .distance(from: location)
            return distance1 < distance2
        })
        
        if let nearestPoint = nearestPoint {
            let distance = CLLocation(latitude: nearestPoint.latitude, longitude: nearestPoint.longitude)
                .distance(from: location)
            isOffRoute = distance > 100
        }
    }
    
    func centerOnDay(_ day: Int) {
        if let destination = Destination.allDestinations.first(where: { $0.day == day }) {
            withAnimation {
                region = MKCoordinateRegion(
                    center: destination.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        }
    }
}

// MARK: - MapView
struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        Map {
            // Add map annotations here
        }
        .mapStyle(.standard)
        .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - MapPolyline
struct MapPolyline: MapContent {
    let coordinates: [CLLocationCoordinate2D]
    
    var body: some MapContent {
        ForEach(0..<coordinates.count-1, id: \.self) { index in
            let start = coordinates[index]
            let end = coordinates[index + 1]
            MapPolyline(coordinates: [start, end])
                .stroke(Color.red, lineWidth: 2)
        }
    }
}

#Preview {
    MapView()
} 