import SwiftUI
import Foundation
import MapKit
import CoreLocation

struct Destination: Identifiable {
    let id = UUID()
    let day: Int
    let locationName: String
    let hotelName: String
    let coordinate: CLLocationCoordinate2D
    
    static let allDestinations: [Destination] = [
        Destination(day: 0, locationName: "Saint-Jean-Pied-de-Port", hotelName: "Villa Goxoki", coordinate: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386)),
        Destination(day: 1, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", coordinate: CLLocationCoordinate2D(latitude: 42.9878, longitude: -1.3197)),
        // ... Add all other destinations here ...
    ]
}

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