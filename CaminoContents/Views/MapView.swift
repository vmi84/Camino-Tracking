//
//  MapView.swift
//  Camino
//
//  Created by Jeff White on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation

// MARK: - CaminoDestination
struct CaminoDestination: Identifiable {
    let id = UUID()
    let day: Int
    let locationName: String
    let hotelName: String
    let coordinate: CLLocationCoordinate2D
    
    static let allDestinations: [CaminoDestination] = [
        CaminoDestination(day: 0, locationName: "Saint-Jean-Pied-de-Port", hotelName: "Villa Goxoki", coordinate: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386)),
        CaminoDestination(day: 1, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", coordinate: CLLocationCoordinate2D(latitude: 42.9878, longitude: -1.3197)),
        CaminoDestination(day: 2, locationName: "Zubiri", hotelName: "Hosteria de Zubiri", coordinate: CLLocationCoordinate2D(latitude: 42.9321, longitude: -1.5036)),
        CaminoDestination(day: 3, locationName: "Pamplona", hotelName: "Hotel A Pamplona", coordinate: CLLocationCoordinate2D(latitude: 42.8110, longitude: -1.6450)),
        CaminoDestination(day: 4, locationName: "Puente la Reina", hotelName: "Hotel El Cerco", coordinate: CLLocationCoordinate2D(latitude: 42.6728, longitude: -1.8115)),
        CaminoDestination(day: 5, locationName: "Estella", hotelName: "Alda Estella Hostal", coordinate: CLLocationCoordinate2D(latitude: 42.6708, longitude: -2.0295)),
        CaminoDestination(day: 6, locationName: "Los Arcos", hotelName: "Pensión Los Arcos", coordinate: CLLocationCoordinate2D(latitude: 42.5715, longitude: -2.1918)),
        CaminoDestination(day: 7, locationName: "Logroño", hotelName: "Hotel Ciudad de Logroño", coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450)),
        CaminoDestination(day: 8, locationName: "Nájera", hotelName: "Hotel Duques de Nájera", coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7290)),
        CaminoDestination(day: 9, locationName: "Santo Domingo de la Calzada", hotelName: "El Molino de Floren", coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530)),
        CaminoDestination(day: 10, locationName: "Belorado", hotelName: "Hostel Punto B", coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910)),
        CaminoDestination(day: 11, locationName: "San Juan de Ortega", hotelName: "Hotel Rural la Iglesia", coordinate: CLLocationCoordinate2D(latitude: 42.3760, longitude: -3.4370)),
        CaminoDestination(day: 12, locationName: "Burgos", hotelName: "Hotel Cordón", coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7010)),
        CaminoDestination(day: 13, locationName: "Hornillos del Camino", hotelName: "De Sol A Sol", coordinate: CLLocationCoordinate2D(latitude: 42.3130, longitude: -4.0460)),
        CaminoDestination(day: 14, locationName: "Castrojeriz", hotelName: "A Cien Leguas", coordinate: CLLocationCoordinate2D(latitude: 42.2900, longitude: -4.1380)),
        CaminoDestination(day: 15, locationName: "Frómista", hotelName: "Eco Hotel Doña Mayor", coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060)),
        CaminoDestination(day: 16, locationName: "Carrión de los Condes", hotelName: "Hostal La Corte", coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030)),
        CaminoDestination(day: 17, locationName: "Calzadilla de la Cueza", hotelName: "Hostal Camino Real", coordinate: CLLocationCoordinate2D(latitude: 42.3630, longitude: -4.8860)),
        CaminoDestination(day: 18, locationName: "Sahagún", hotelName: "Hostal Domus Viatoris", coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290)),
        CaminoDestination(day: 19, locationName: "El Burgo Ranero", hotelName: "Hotel Castillo El Burgo", coordinate: CLLocationCoordinate2D(latitude: 42.4220, longitude: -5.2200)),
        CaminoDestination(day: 20, locationName: "Mansilla de las Mulas", hotelName: "Alberguería del Camino", coordinate: CLLocationCoordinate2D(latitude: 42.4990, longitude: -5.4170)),
        CaminoDestination(day: 21, locationName: "León", hotelName: "Hotel Alda Vía León", coordinate: CLLocationCoordinate2D(latitude: 42.5990, longitude: -5.5710)),
        CaminoDestination(day: 22, locationName: "Villadangos del Páramo", hotelName: "TBD", coordinate: CLLocationCoordinate2D(latitude: 42.5160, longitude: -5.7660)),
        CaminoDestination(day: 23, locationName: "Chozas de Abajo", hotelName: "Albergue San Antonio", coordinate: CLLocationCoordinate2D(latitude: 42.5060, longitude: -5.6830)),
        CaminoDestination(day: 24, locationName: "Astorga", hotelName: "Hotel Astur Plaza", coordinate: CLLocationCoordinate2D(latitude: 42.4570, longitude: -6.0560)),
        CaminoDestination(day: 25, locationName: "Rabanal del Camino", hotelName: "Hotel Rural Casa Indie", coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840)),
        CaminoDestination(day: 26, locationName: "Ponferrada", hotelName: "Hotel El Castillo", coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5960)),
        CaminoDestination(day: 27, locationName: "Villafranca del Bierzo", hotelName: "Hostal Tres Campanas", coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110)),
        CaminoDestination(day: 28, locationName: "O Cebreiro", hotelName: "Casa Navarro", coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0420)),
        CaminoDestination(day: 29, locationName: "Triacastela", hotelName: "Complexo Xacobeo", coordinate: CLLocationCoordinate2D(latitude: 42.7550, longitude: -7.2370))
    ]
}

// MARK: - MapViewModel
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CaminoDestination.allDestinations[0].coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isOffRoute: Bool = false
    
    private let locationManager = CLLocationManager()
    private let routeCoordinates: [CLLocationCoordinate2D] = CaminoDestination.allDestinations.map { $0.coordinate }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func centerOnDay(_ day: Int) {
        if let destination = CaminoDestination.allDestinations.first(where: { $0.day == day }) {
            region.center = destination.coordinate
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        // Find nearest destination
        let userLoc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let nearestDestination = CaminoDestination.allDestinations.min { dest1, dest2 in
            let loc1 = CLLocation(latitude: dest1.coordinate.latitude, longitude: dest1.coordinate.longitude)
            let loc2 = CLLocation(latitude: dest2.coordinate.latitude, longitude: dest2.coordinate.longitude)
            return userLoc.distance(from: loc1) < userLoc.distance(from: loc2)
        }
        
        // Check if user is off route (more than 500m from nearest destination)
        if let nearest = nearestDestination {
            let nearestLoc = CLLocation(latitude: nearest.coordinate.latitude, longitude: nearest.coordinate.longitude)
            isOffRoute = userLoc.distance(from: nearestLoc) > 500
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

// MARK: - MapView
struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var selectedDestination: CaminoDestination?
    @State private var showingDestinationDetail = false
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: CaminoDestination.allDestinations) { destination in
            MapAnnotation(coordinate: destination.coordinate) {
                VStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("\(destination.day)")
                        .font(.caption)
                        .bold()
                }
                .onTapGesture {
                    selectedDestination = destination
                    showingDestinationDetail = true
                }
            }
        }
        .overlay(
            MapPolyline(coordinates: CaminoDestination.allDestinations.map { $0.coordinate })
                .stroke(Color.blue, lineWidth: 3)
        )
        .sheet(isPresented: $showingDestinationDetail) {
            if let destination = selectedDestination {
                DestinationDetailView(destination: destination)
            }
        }
        .alert(isPresented: .constant(viewModel.isOffRoute)) {
            Alert(
                title: Text("Off Route"),
                message: Text("You appear to be more than 500m from the Camino route."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// MARK: - DestinationDetailView
struct DestinationDetailView: View {
    let destination: CaminoDestination
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Day \(destination.day)")
                .font(.headline)
            Text(destination.locationName)
                .font(.title)
            Text(destination.hotelName)
                .font(.subheadline)
            Spacer()
        }
        .padding()
    }
}

// MARK: - MapPolyline
struct MapPolyline: Shape {
    let coordinates: [CLLocationCoordinate2D]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard let firstCoordinate = coordinates.first else { return path }
        
        let points = coordinates.map { coordinate -> CGPoint in
            let latitude = (coordinate.latitude - firstCoordinate.latitude) * rect.height
            let longitude = (coordinate.longitude - firstCoordinate.longitude) * rect.width
            return CGPoint(x: longitude + rect.midX, y: latitude + rect.midY)
        }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}

