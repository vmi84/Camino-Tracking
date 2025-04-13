//
//  MapView.swift
//  Camino
//
//  Created by Jeff White on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation
import CaminoModels

// MARK: - MapView
struct MapView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @AppStorage("mapStyle") private var mapStyleSetting = "Standard"
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.1630, longitude: -1.2380), // St. Jean Pied de Port
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    ))
    @State private var selectedDestination: CaminoDestination?
    @State private var showingDestinationDetail = false
    @State private var zoomLevel: Double = 0.5 // Track zoom level
    @State private var showLocationAlert = false // For location error alerts
    
    // Convert string map style to SwiftUI mapStyle
    private var mapStyle: MapStyle {
        switch mapStyleSetting {
        case "Satellite":
            return .imagery
        case "Hybrid":
            return .hybrid
        default:
            return .standard
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $camera) {
                // User location
                if let userLocation = locationManager.location {
                    Marker("My Location", coordinate: userLocation.coordinate)
                        .tint(.blue)
                }
                
                // Destination markers
                ForEach(CaminoDestination.allDestinations) { destination in
                    Annotation(
                        "\(destination.day)",
                        coordinate: destination.coordinate,
                        anchor: .bottom
                    ) {
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
                
                // Hotel markers
                ForEach(CaminoDestination.allDestinations) { destination in
                    Marker(
                        destination.hotelName,
                        coordinate: destination.coordinate
                    )
                    .tint(.orange)
                }
                
                // Draw route line using native MapKit polyline
                let coordinates = CaminoDestination.allDestinations.map { $0.coordinate }
                if coordinates.count >= 2 {
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    MapKit.MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 3)
                }
            }
            .mapStyle(mapStyle)
            
            // Map control buttons
            VStack(spacing: 8) {
                // Zoom in button
                Button(action: {
                    zoomIn()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                
                // Zoom out button
                Button(action: {
                    zoomOut()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                
                // My location button
                Button(action: {
                    centerOnUserLocation()
                }) {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                        .foregroundColor(locationManager.location != nil ? .blue : .gray)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                
                // Home button
                Button(action: {
                    centerOnStartingPoint()
                }) {
                    Image(systemName: "house.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
            }
            .padding(.top, 60)
            .padding(.trailing, 16)
        }
        .sheet(isPresented: $showingDestinationDetail) {
            if let destination = selectedDestination {
                DestinationDetailView(destination: destination)
            }
        }
        .onAppear {
            locationManager.requestAuthorization()
            locationManager.startUpdatingLocation()
        }
        .alert("Location Unavailable", isPresented: $showLocationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your location is not available. Please ensure location services are enabled for this app in Settings.")
        }
    }
    
    // Zoom in function
    private func zoomIn() {
        if let region = camera.region {
            let newDelta = max(region.span.latitudeDelta * 0.5, 0.005)
            camera = .region(MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(latitudeDelta: newDelta, longitudeDelta: newDelta)
            ))
            zoomLevel = newDelta
        }
    }
    
    // Zoom out function
    private func zoomOut() {
        if let region = camera.region {
            let newDelta = min(region.span.latitudeDelta * 2.0, 20.0)
            camera = .region(MKCoordinateRegion(
                center: region.center,
                span: MKCoordinateSpan(latitudeDelta: newDelta, longitudeDelta: newDelta)
            ))
            zoomLevel = newDelta
        }
    }
    
    // Center on user location
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            camera = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
            zoomLevel = 0.01
        } else {
            // No location available, show alert
            showLocationAlert = true
        }
    }
    
    // Center on St. Jean Pied de Port (starting point)
    private func centerOnStartingPoint() {
        if let firstDestination = CaminoDestination.allDestinations.first {
            camera = .region(MKCoordinateRegion(
                center: firstDestination.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            ))
            zoomLevel = 0.5
        }
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

