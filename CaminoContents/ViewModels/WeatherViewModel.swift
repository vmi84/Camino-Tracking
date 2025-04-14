import Foundation
import WeatherKit // Keep import for now, might be needed if WK types are used implicitly elsewhere
#if canImport(CaminoModels)
import CaminoModels
#endif
import CoreLocation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import MapKit

@MainActor
class WeatherViewModel: ObservableObject {
    // Restore properties related to external linking/state
    @Published var destinations: [CaminoDestination] = []
    @Published var errorMessage: String?
    @Published var isTabSelected: Bool = false // Track if the tab was selected
    @Published var hasRedirected: Bool = false // Track if we've already redirected
    @Published var hasAttemptedRedirect: Bool = false // Track if we tried to redirect
    
    // Published properties for the view (kept from previous WeatherKit attempt, might need adjustment)
    @Published var isLoading: Bool = false // Loading state for the view itself

    var locationManager: LocationManager {
        return LocationManager.shared
    }

    init() {
        self.destinations = CaminoDestination.allDestinations
        // No automatic weather fetch on init
    }
    
    // Restore function to trigger redirect (if needed, called by view?)
    func refreshWeather() async {
        // This logic might need adjustment based on how view calls it
        if !hasAttemptedRedirect {
            hasAttemptedRedirect = true
            openWeatherForCurrentLocation()
        }
    }

    // Restore functions for opening external Weather app
    func getWeatherURL(for destination: CaminoDestination) -> URL? {
        return URL(string: "weather:///?lat=\(destination.coordinate.latitude)&lon=\(destination.coordinate.longitude)")
    }

    func getWeatherURLForCurrentLocation() -> URL? {
        if let currentLocation = locationManager.location {
            return URL(string: "weather:///?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)")
        }
        return URL(string: "weather:///") // Fallback to just opening the app
    }

    func openNativeWeatherApp(for destination: CaminoDestination) {
        let weatherURL = getWeatherURL(for: destination)
        
        #if os(iOS)
        if let url = weatherURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback to Apple Maps with weather enabled
            openInMaps(coordinate: destination.coordinate, name: destination.locationName)
        }
        #elseif os(macOS)
        if let url = weatherURL {
            NSWorkspace.shared.open(url)
        } else {
            openInMaps(coordinate: destination.coordinate, name: destination.locationName)
        }
        #endif
    }

    func openWeatherForCurrentLocation() {
        hasRedirected = true // Mark that we've tried opening
        let weatherURL = getWeatherURLForCurrentLocation()

        #if os(iOS)
        if let url = weatherURL, UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
             // Final fallback to Apple Maps if Weather app can't be opened
            if let currentLocation = locationManager.location {
                openInMaps(coordinate: currentLocation.coordinate, name: "Current Location")
            }
        }
        #elseif os(macOS)
        if let url = weatherURL {
            NSWorkspace.shared.open(url)
        } else {
            if let currentLocation = locationManager.location {
                 openInMaps(coordinate: currentLocation.coordinate, name: "Current Location")
            }
        }
        #endif
    }

    // Helper to open in Maps as fallback
    private func openInMaps(coordinate: CLLocationCoordinate2D, name: String) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
                                         MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))])
    }

    // Restore method to track tab selection
    func tabWasSelected() {
        isTabSelected = true
        // Allow view's onAppear to handle the redirect attempt
    }
    
    // REMOVED: WeatherKit specific properties and functions
    // - weatherService
    // - currentWeatherData
    // - currentPlaceName
    // - fetchWeatherForCurrentLocation()
    // - updatePlaceName(for:)
} 