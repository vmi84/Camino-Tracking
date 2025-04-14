// 
// CaminoModelsShim.swift
// Camino
//
// This file provides a local copy of CaminoModels types
// to avoid import issues with the Swift Package Manager
//

#if canImport(CaminoModels)
// Use the real CaminoModels when it can be imported
import CaminoModels
#else
// Otherwise provide local copies of the needed types
import Foundation
import CoreLocation
import MapKit
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Extension to make CLLocationCoordinate2D conform to Hashable and Equatable
extension CLLocationCoordinate2D: Hashable, Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

// Destination model for the Camino route
public struct CaminoDestination: Hashable, Equatable, Identifiable {
    public let id: UUID
    public let day: Int
    public let date: Date?
    public let locationName: String
    public let hotelName: String?
    public let coordinate: CLLocationCoordinate2D
    public let elevationProfile: String?
    public let dailyDistance: Double
    public let cumulativeDistance: Double
    public let content: String?
    
    // Add missing computed property for consistency with main model
    public var actualRouteDistance: Double {
        return dailyDistance
    }
    
    public init(
        id: UUID = UUID(),
        day: Int,
        date: Date? = nil,
        locationName: String,
        hotelName: String? = nil,
        coordinate: CLLocationCoordinate2D,
        elevationProfile: String? = nil,
        dailyDistance: Double,
        cumulativeDistance: Double,
        content: String? = nil
    ) {
        self.id = id
        self.day = day
        self.date = date
        self.locationName = locationName
        self.hotelName = hotelName
        self.coordinate = coordinate
        self.elevationProfile = elevationProfile
        self.dailyDistance = dailyDistance
        self.cumulativeDistance = cumulativeDistance
        self.content = content
    }
    
    // Sample data
    public static let allDestinations: [CaminoDestination] = [
        CaminoDestination(
            day: 0,
            locationName: "St Jean Pied de Port",
            coordinate: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386),
            dailyDistance: 0,
            cumulativeDistance: 0,
            content: "Starting point of the Camino Francés."
        ),
        CaminoDestination(
            day: 1,
            locationName: "Roncesvalles",
            coordinate: CLLocationCoordinate2D(latitude: 43.0088, longitude: -1.3197),
            dailyDistance: 25.1,
            cumulativeDistance: 25.1,
            content: "First major stop after crossing the Pyrenees."
        )
    ]
}

// App state to manage global state - renamed to avoid conflicts
public class ShimCaminoAppState: ObservableObject {
    @Published public var isShowingMap: Bool = false
    @Published public var selectedTab: Int = 0
    @Published var alertManager: AlertManager?
    
    public init(isShowingMap: Bool = false, selectedTab: Int = 0) {
        self.isShowingMap = isShowingMap
        self.selectedTab = selectedTab
        self.alertManager = AlertManager()
    }
    
    public func showMap() {
        isShowingMap = true
        selectedTab = 0
    }
    
    func handleError(_ error: Models.AppError) {
        alertManager?.showError(message: error.message, severity: mapErrorSeverity(error.logLevel))
    }
    
    private func mapErrorSeverity(_ logLevel: Models.AppError.LogLevel) -> ErrorSeverity {
        switch logLevel {
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        case .critical: return .critical
        }
    }
}

// Platform-compatible Location manager to track user location
public class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published public var location: CLLocation?
    @Published public var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    public static let shared = LocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        #if os(iOS)
        locationManager.requestWhenInUseAuthorization()
        #endif
        
        startUpdatingLocation()
    }
    
    public func requestAuthorization() {
        #if os(iOS)
        locationManager.requestWhenInUseAuthorization()
        #endif
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
#endif 