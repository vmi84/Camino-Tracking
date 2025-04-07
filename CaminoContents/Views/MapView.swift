//
//  MapView.swift
//  Camino
//
//  Created by Jeff White on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Models

// MARK: - MapView
struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var selectedDestination: CaminoDestination?
    @State private var showingDestinationDetail = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                userTrackingMode: .constant(.none),
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
                Path { path in
                    guard let firstCoordinate = CaminoDestination.allDestinations.first?.coordinate else { return }
                    
                    let points = CaminoDestination.allDestinations.map { destination -> CGPoint in
                        let latitude = (destination.coordinate.latitude - firstCoordinate.latitude)
                        let longitude = (destination.coordinate.longitude - firstCoordinate.longitude)
                        return CGPoint(x: longitude, y: latitude)
                    }
                    
                    if let firstPoint = points.first {
                        path.move(to: firstPoint)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 3)
            )
            
            // Location and Zoom controls
            VStack(spacing: 8) {
                // Location button
                Button(action: {
                    viewModel.centerOnUserLocation()
                }) {
                    Image(systemName: "location.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                // Zoom controls
                Button(action: {
                    viewModel.zoomIn()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    viewModel.zoomOut()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
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
        .alert(isPresented: .constant(viewModel.isOffRoute)) {
            Alert(
                title: Text("Off Route"),
                message: Text("You appear to be more than 500m from the Camino route."),
                dismissButton: .default(Text("OK"))
            )
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

