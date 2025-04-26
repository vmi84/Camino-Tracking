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
import CaminoModels
import Combine // Import Combine for Cancellable

// Helper extension for MKPolyline
// Moved here from the bottom for conventional placement
extension MKPolyline {
    func mapPoints() -> [MKMapPoint] {
        let pointPtr = self.points()
        return Array(UnsafeBufferPointer(start: pointPtr, count: self.pointCount))
    }
}

// Custom Annotation class to hold more context
class CaminoMapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String? // e.g., "Day X Waypoint" or "Day X Destination"
    @objc dynamic var coordinate: CLLocationCoordinate2D
    let locationPoint: LocationPoint? // The original waypoint/start/end point
    let destination: CaminoDestination? // The parent destination context
    let isWaypoint: Bool // True for intermediate points, false for start/end of a day
    let isStartPoint: Bool // Specific flag for the start point of a focused day
    let isEndPoint: Bool // Specific flag for the end point of a focused day

    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, 
         locationPoint: LocationPoint? = nil, destination: CaminoDestination? = nil, 
         isWaypoint: Bool = false, isStartPoint: Bool = false, isEndPoint: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.locationPoint = locationPoint
        self.destination = destination
        self.isWaypoint = isWaypoint
        self.isStartPoint = isStartPoint
        self.isEndPoint = isEndPoint
    }
}

@MainActor // Ensure UI updates happen on the main thread
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CaminoDestination.allDestinations.first?.coordinate ?? CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0) // Wider initial span
    )
    
    @Published var currentAnnotations: [CaminoMapAnnotation] = []
    @Published var currentPolyline: MKPolyline? = nil
    
    @Published var isLoadingRoute: Bool = false
    @Published var selectedDestinationForModal: CaminoDestination? = nil
    @Published var isLocationAlertPresented: Bool = false

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isOffRoute: Bool = false
    
    private let locationManager = CLLocationManager()
    private var routeCalculationTask: Task<Void, Never>? = nil
    private var appStateSubscription: AnyCancellable?
    private weak var appState: CaminoAppState? // Keep weak reference

    // Standard Initializer
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest 
        locationManager.distanceFilter = 50 
        // Defer authorization check and initial load until setup
    }
    
    // NEW: Setup method to be called from View's onAppear
    func setup(appState: CaminoAppState) {
        // Only setup once
        guard self.appState == nil else { return }
        
        print("MapViewModel setup called.")
        self.appState = appState
        
        // Now check authorization
        checkLocationAuthorization()
        
        // Subscribe to focusedRouteDay changes
        appStateSubscription = appState.$focusedRouteDay
            .removeDuplicates()
            .sink { [weak self] focusedDay in
                // Use Task to ensure updateMapDisplay runs on MainActor
                Task {
                    // Ignore the return value as we just need the side effects (updating published properties)
                    _ = await self?.updateMapDisplay(focusedDay: focusedDay)
                }
            }
            
        // Initial map display based on current state
        // Use Task to ensure updateMapDisplay runs on MainActor
        Task {
             await updateMapDisplay(focusedDay: appState.focusedRouteDay)
        }
    }
    
    // updateMapDisplay remains async but is now called via Task from setup/sink
    func updateMapDisplay(focusedDay: Int?) async {
        // Ensure this runs on main actor
        assert(Thread.isMainThread, "updateMapDisplay must be called on the main thread")
        print("Updating map display, focusedDay: \(focusedDay?.description ?? "nil")")
        isLoadingRoute = true
        routeCalculationTask?.cancel() // Cancel any ongoing calculation

        // Keep Task for background work, but state updates are already @MainActor protected
        routeCalculationTask = Task.detached(priority: .userInitiated) { [weak self] in 
            // Use non-async helper methods for data prep if possible
            if let mapData = await self?.prepareMapData(for: focusedDay) {

                // Check if cancelled before updating UI
                 guard !Task.isCancelled else {
                     print("Map display task cancelled.")
                     // Capture isLoadingRoute state modification for MainActor
                     await MainActor.run { [weak self] in self?.isLoadingRoute = false }
                     return
                 }
                 
                // Update published properties back on main actor
                // Capture necessary data to avoid capturing self directly for data properties
                await MainActor.run { [annotations = mapData.annotations, polyline = mapData.polyline, weak self] in 
                     guard let self = self else { return }
                     // Use the captured data
                     self.currentAnnotations = annotations
                     self.currentPolyline = polyline
                     self.isLoadingRoute = false // Update state on self
                     print("Map display updated. Annotations: \(self.currentAnnotations.count), Polyline: \(self.currentPolyline != nil)")
                     self.adjustRegionToFitContent() // Call method on self
                }
            } else {
                 // Handle case where self is nil or prepareMapData returns nil
                 // Capture isLoadingRoute state modification for MainActor
                 await MainActor.run { [weak self] in self?.isLoadingRoute = false }
            }
        }
    }
    
    // NEW Helper to consolidate data prep (can be async)
    private func prepareMapData(for focusedDay: Int?) async -> (annotations: [CaminoMapAnnotation], polyline: MKPolyline?) {
        var points: [LocationPoint] = []
        var annotations: [CaminoMapAnnotation] = []
        var polyline: MKPolyline? = nil

        if let day = focusedDay {
            print("Preparing data for focused day: \(day)")
            if let routeDetail = fetchRouteDetail(for: day) {
                points = extractDetailPoints(from: routeDetail)
                annotations = createDetailAnnotations(for: day, from: routeDetail)
            }
        } else {
            print("Preparing overview data")
            // Overview Mode - fetch only destination points for polyline calculation
             points = await fetchOverviewPoints()
             annotations = createOverviewAnnotations(from: points) // Create annotations from destinations
        }
        
        // Calculate polyline based on the fetched points
        polyline = await calculateRoute(points: points, forDay: focusedDay)
        
        return (annotations, polyline)
    }

    private func fetchRouteDetail(for day: Int) -> RouteDetail? {
        // Adjust for Leon rest day
        let routeDay = (day <= 19) ? day : day - 1
        return RouteDetailProvider.getRouteDetail(for: routeDay)
    }

    // Fetch only Start/End points for the overview
    private func fetchOverviewPoints() async -> [LocationPoint] {
        var overviewPoints: [LocationPoint] = []
        for destination in CaminoDestination.allDestinations {
            // Use Day 0 as the first point
            if destination.day == 0 {
                 let coord = destination.coordinate // Assign directly
                 overviewPoints.append(LocationPoint(name: destination.locationName, distance: 0, services: nil, details: nil, coordinate: coord))
                 continue
            }
            
            // /* // Uncommented block
            // For other days, get the corresponding route's endpoint
            if destination.day > 0 {
                // Revert to comma-separated if let, ensuring coordinate check
                if let routeDetail = fetchRouteDetail(for: destination.day), 
                   let endPoint = routeDetail.endPoint, 
                   endPoint.coordinate != nil { // Check coordinate exists
                    // We have a valid endPoint with a coordinate from the route detail
                    overviewPoints.append(endPoint)
                } 
                // Fallback: If route detail/endpoint/coordinate missing, use destination's coordinate
                else {
                    // Use the non-optional destination coordinate directly,
                    // letting Swift implicitly convert to the expected Optional type.
                     overviewPoints.append(LocationPoint(name: destination.locationName, distance: destination.dailyDistance, services: nil, details: nil, coordinate: destination.coordinate))
                }
            }
             // */ // Uncommented block
        }
         print("Fetched \(overviewPoints.count) overview points.")
        return overviewPoints.filter { $0.coordinate != nil }
    }

    // Extract Start, Waypoints, End for a single day's detail
    private func extractDetailPoints(from routeDetail: RouteDetail) -> [LocationPoint] {
        var points: [LocationPoint] = []
        // Separate unwrapping and coordinate check for clarity
        if let start = routeDetail.startPoint {
             if start.coordinate != nil {
                 points.append(start)
             }
        }
        if let waypoints = routeDetail.waypoints {
            // Filter waypoints that have coordinates
            points.append(contentsOf: waypoints.filter { $0.coordinate != nil })
        }
        // Separate unwrapping and coordinate check for clarity
        if let end = routeDetail.endPoint {
            if end.coordinate != nil {
                points.append(end)
            }
        }
         print("Extracted \(points.count) detail points.")
        return points
    }
    
    private func createOverviewAnnotations(from points: [LocationPoint]) -> [CaminoMapAnnotation] {
         // Find the corresponding destination for each overview point (match by coordinate or name?)
         // This is tricky as overview points are derived from endPoints. Let's map based on destination list.
         var annotations: [CaminoMapAnnotation] = []
         for destination in CaminoDestination.allDestinations {
             // Use destination.coordinate directly as it's non-optional
             let coord = destination.coordinate 
             let subtitle = "Day \(destination.day) Destination"
             let annotation = CaminoMapAnnotation(
                 title: destination.locationName,
                 subtitle: subtitle,
                 coordinate: coord, // Use the non-optional coord
                 locationPoint: nil, // Not directly from a specific LocationPoint here
                 destination: destination,
                 isWaypoint: false, isStartPoint: false, isEndPoint: true // Mark as destination
             )
             annotations.append(annotation)
         }
         print("Created \(annotations.count) overview annotations.")
         return annotations
    }

    private func createDetailAnnotations(for day: Int, from routeDetail: RouteDetail) -> [CaminoMapAnnotation] {
        var annotations: [CaminoMapAnnotation] = []
        let destination = CaminoDestination.allDestinations.first { $0.day == day }

        if let start = routeDetail.startPoint, let coord = start.coordinate {
            let subtitle = "Day \(day) Start"
            annotations.append(CaminoMapAnnotation(title: start.name, subtitle: subtitle, coordinate: coord, locationPoint: start, destination: destination, isWaypoint: false, isStartPoint: true, isEndPoint: false))
        }
        if let waypoints = routeDetail.waypoints {
            for waypoint in waypoints {
                if let coord = waypoint.coordinate {
                    let subtitle = "Day \(day) Waypoint"
                    annotations.append(CaminoMapAnnotation(title: waypoint.name, subtitle: subtitle, coordinate: coord, locationPoint: waypoint, destination: destination, isWaypoint: true, isStartPoint: false, isEndPoint: false))
                }
            }
        }
        if let end = routeDetail.endPoint, let coord = end.coordinate {
            let subtitle = "Day \(day) End"
            annotations.append(CaminoMapAnnotation(title: end.name, subtitle: subtitle, coordinate: coord, locationPoint: end, destination: destination, isWaypoint: false, isStartPoint: false, isEndPoint: true))
        }
        print("Created \(annotations.count) detail annotations for day \(day).")
        return annotations
    }
    
    // Consolidated route calculation for overview or detail
    private func calculateRoute(points: [LocationPoint], forDay day: Int?) async -> MKPolyline? {
        guard points.count >= 2 else {
            print("Not enough points (\(points.count)) to calculate route for day: \(day?.description ?? "Overview").")
            return nil
        }
        
        var routeSegments: [MKRoute] = []
        print("Calculating route for \(points.count) points (Day: \(day?.description ?? "Overview"))...")

        for i in 0..<(points.count - 1) {
            if Task.isCancelled { return nil }
            
            guard let sourceCoord = points[i].coordinate, let destinationCoord = points[i+1].coordinate else {
                print("Skipping segment \(i) due to missing coordinate.")
                continue
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoord))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord))
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            
            do {
                // Add a small delay to potentially avoid throttling, especially for overview
                if day == nil && i > 0 { try await Task.sleep(nanoseconds: 50_000_000) } // 50ms delay for overview segments
                
                let response = try await directions.calculate()
                if let route = response.routes.first {
                    routeSegments.append(route)
                }
            } catch {
                 // Check for specific errors like route not found
                 if let mkError = error as? MKError, mkError.code == .placemarkNotFound || mkError.code == .directionsNotFound {
                      print("Warning: Route segment \(i) (Day: \(day?.description ?? "Overview")) not found between \(points[i].name) and \(points[i+1].name). Skipping.")
                 } else {
                      print("Error calculating route segment \(i) (Day: \(day?.description ?? "Overview")): \(error.localizedDescription)")
                 }
            }
        }
        
        if Task.isCancelled { return nil }
        
        if !routeSegments.isEmpty {
            print("Successfully calculated \(routeSegments.count) segments.")
            // Combine points from all calculated segments
             let allSegmentPoints = routeSegments.flatMap { $0.polyline.mapPoints() }
             if allSegmentPoints.isEmpty {
                 print("Warning: Calculated segments resulted in an empty polyline.")
                 return nil
             }
             return MKPolyline(points: allSegmentPoints, count: allSegmentPoints.count)
        } else {
            print("Could not calculate any route segments for day: \(day?.description ?? "Overview").")
            return nil
        }
    }
    
    // Called by the MapView's Coordinator when an annotation is selected
    func annotationSelected(_ annotation: MKAnnotation) {
        guard let caminoAnnotation = annotation as? CaminoMapAnnotation else { return }
        
        // Use the destination stored in the annotation
        if let dest = caminoAnnotation.destination {
             print("Annotation selected: \(caminoAnnotation.title ?? "N/A") for Destination Day: \(dest.day)")
             // Decide if selecting an annotation should still show the modal,
             // or if it should maybe focus the map on that day?
             // For now, keep the modal behavior:
             self.selectedDestinationForModal = dest 
        } else {
             print("Warning: Tapped annotation \(caminoAnnotation.title ?? "N/A") has no associated destination.")
             self.selectedDestinationForModal = nil
        }
    }
    
    func clearModalSelection() {
        self.selectedDestinationForModal = nil
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
             print("Location access denied or restricted.")
             // Don't request again automatically, user needs to change in settings
             break // Potentially show an informative alert here?
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location access authorized.")
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func centerOnUserLocation() {
        if let userCoord = userLocation {
            adjustRegion(center: userCoord, spanDelta: 0.01)
        } else {
             print("User location not available to center.")
            isLocationAlertPresented = true 
        }
    }
    
    func zoomIn() {
        adjustRegion(spanDelta: region.span.latitudeDelta * 0.5) // Zoom in by 50%
    }
    
    func zoomOut() {
         adjustRegion(spanDelta: region.span.latitudeDelta * 2.0) // Zoom out by 100%
    }
    
    // Center on the start point of the *entire* Camino
    func centerOnStartingPoint() {
        let startCoord = CaminoDestination.allDestinations.first(where: { $0.day == 0 })?.coordinate 
                         ?? CaminoDestination.allDestinations.first?.coordinate 
                         ?? CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386) // Fallback

        adjustRegion(center: startCoord, spanDelta: 5.0) // Use wider overview span
    }
    
    // Helper to adjust region smoothly
    private func adjustRegion(center: CLLocationCoordinate2D? = nil, spanDelta: CLLocationDegrees? = nil) {
         withAnimation {
             if let newCenter = center {
                 region.center = newCenter
             }
             if let delta = spanDelta {
                 // Prevent zooming out too far or in too close
                 let clampedDelta = max(0.001, min(delta, 120.0)) 
                 region.span = MKCoordinateSpan(latitudeDelta: clampedDelta, longitudeDelta: clampedDelta)
             }
         }
     }
     
     // Helper to fit map to current annotations or polyline
     private func adjustRegionToFitContent() {
         // Use the *current* annotations/polyline being displayed
         Task { // Ensure this happens after the properties are updated
             await Task.yield() // Allow SwiftUI cycle to potentially update the view first
             if let polyline = self.currentPolyline, polyline.pointCount > 0 {
                 let rect = polyline.boundingMapRect
                 // Check if rect is valid before setting
                 if !rect.isNull {
                     let paddedRect = rect.insetBy(dx: -rect.size.width * 0.1, dy: -rect.size.height * 0.1) // 10% padding
                     self.region = MKCoordinateRegion(paddedRect)
                 } else {
                      print("Warning: Skipping zoom to invalid polyline rect.")
                 }
             } else if !self.currentAnnotations.isEmpty {
                 let coordinates = self.currentAnnotations.map { $0.coordinate }
                 var minLat = coordinates[0].latitude
                 var maxLat = coordinates[0].latitude
                 var minLon = coordinates[0].longitude
                 var maxLon = coordinates[0].longitude
                 
                 for coord in coordinates {
                     minLat = min(minLat, coord.latitude)
                     maxLat = max(maxLat, coord.latitude)
                     minLon = min(minLon, coord.longitude)
                     maxLon = max(maxLon, coord.longitude)
                 }
                 
                 let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
                 let span = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) * 1.4, longitudeDelta: abs(maxLon - minLon) * 1.4) // Add padding
                 self.region = MKCoordinateRegion(center: center, span: span)
             } else {
                 print("No content to adjust region for.")
                 // Optionally reset to default view?
                 // centerOnStartingPoint() 
             }
         }
     }

    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Remove unnecessary 'guard let self'
        // The check and update logic needs to be on the main actor
        
        Task { @MainActor [weak self] in // Capture self weakly
            guard let self = self else { return } // Safely unwrap weak self inside the Task
            
            // Perform check and update logic on the main actor
            let shouldUpdate = self.userLocation == nil || 
               CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
               .distance(from: CLLocation(latitude: self.userLocation!.latitude, longitude: self.userLocation!.longitude)) > self.locationManager.distanceFilter // Access properties via self

            if shouldUpdate {
                self.userLocation = location.coordinate
                print("User location updated: \(location.coordinate)")
                // Recalculate off-route status when location changes significantly
                // self.checkOffRouteStatus(userLocation: location.coordinate)
            }
        }
    }
    
    // TODO: Implement checkOffRouteStatus if needed, comparing userLocation to currentPolyline
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Remove unnecessary 'guard let self'
        
        print("Location authorization status changed: \(status.rawValue)")
        // Dispatch calls to main-actor-isolated methods and state updates
        Task { @MainActor [weak self] in // Capture self weakly
             guard let self = self else { return } // Safely unwrap weak self inside the Task

            self.checkLocationAuthorization() // This method is @MainActor isolated
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                 // Re-fetch map data if authorization was just granted and map might be empty
                 if self.currentAnnotations.isEmpty {
                     // Add await here
                     _ = await self.updateMapDisplay(focusedDay: self.appState?.focusedRouteDay)
                 }
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        // Potentially update UI to indicate location error (dispatch to main actor if needed)
        // Task { @MainActor in ... }
    }
}

