//
//  MapViewModel.swift
//  Camino
//
//  Created by Jeff White on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation
// Import the shim which handles CaminoModels availability
#if canImport(CaminoModels)
import CaminoModels
#endif

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CaminoDestination.allDestinations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isOffRoute: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func centerOnUserLocation() {
        if let userLocation = userLocation {
            withAnimation {
                region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
    
    func zoomIn() {
        withAnimation {
            region.span = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta * 0.5,
                longitudeDelta: region.span.longitudeDelta * 0.5
            )
        }
    }
    
    func zoomOut() {
        withAnimation {
            region.span = MKCoordinateSpan(
                latitudeDelta: region.span.latitudeDelta * 2.0,
                longitudeDelta: region.span.longitudeDelta * 2.0
            )
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        // Find nearest destination
        let nearestDestination = CaminoDestination.allDestinations.min { first, second in
            let firstDistance = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                .distance(from: location)
            let secondDistance = CLLocation(latitude: second.coordinate.latitude, longitude: second.coordinate.longitude)
                .distance(from: location)
            return firstDistance < secondDistance
        }
        
        // Check if user is off route (more than 500m from nearest destination)
        if let nearest = nearestDestination {
            let nearestLocation = CLLocation(latitude: nearest.coordinate.latitude, longitude: nearest.coordinate.longitude)
            let distance = location.distance(from: nearestLocation)
            isOffRoute = distance > 500
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

