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
    @State private var camera: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.1630, longitude: -1.2380), // St. Jean Pied de Port
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    ))
    @State private var selectedDestination: CaminoDestination?
    @State private var showingDestinationDetail = false
    
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
            .mapStyle(.standard)
            
            // Map control buttons
            VStack(spacing: 8) {
                Button(action: {
                    centerOnUserLocation()
                }) {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    centerOnStartingPoint()
                }) {
                    Image(systemName: "house.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .background(Color.white)
                        .clipShape(Circle())
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
        }
    }
    
    // Center on user location
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            camera = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    // Center on St. Jean Pied de Port (starting point)
    private func centerOnStartingPoint() {
        if let firstDestination = CaminoDestination.allDestinations.first {
            camera = .region(MKCoordinateRegion(
                center: firstDestination.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            ))
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

