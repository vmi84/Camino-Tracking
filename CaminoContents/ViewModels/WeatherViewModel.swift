import Foundation
import WeatherKit
import CaminoModels
import CoreLocation
import SwiftyJSON
import UIKit
import MapKit

class WeatherViewModel: ObservableObject {
    @Published var weatherData: [CaminoDestination: Weather] = [:]
    @Published var destinations: [CaminoDestination] = []
    @Published var errorMessage: String?
    @Published var shouldShowWeatherAppPrompt: Bool = true // Default to true to prioritize Apple Weather
    @Published var isTabSelected: Bool = false
    @Published var hasAttemptedRedirect: Bool = false
    
    private let caminoWeatherViewModel: CaminoWeatherViewModel
    @MainActor private var locationManager: LocationManager {
        return LocationManager.shared
    }
    
    @MainActor
    init() {
        self.caminoWeatherViewModel = CaminoWeatherViewModel()
        self.destinations = CaminoDestination.allDestinations
        
        // Check if Apple Weather app is available and attempt to open it immediately
        checkAppleWeatherAvailability()
    }
    
    private func checkAppleWeatherAvailability() {
        // Always default to using Apple Weather app
        self.shouldShowWeatherAppPrompt = true
        
        // Test if Apple Weather app URL scheme works
        if let testURL = URL(string: "weather:///") {
            // Using the correct canOpenURL method
            if UIApplication.shared.canOpenURL(testURL) {
                // Weather app is available, keep shouldShowWeatherAppPrompt as true
                Task { @MainActor in
                    // If this is the first time checking, automatically open Weather
                    if !hasAttemptedRedirect {
                        hasAttemptedRedirect = true
                        openWeatherForCurrentLocation()
                    }
                }
            } else {
                // Weather app is not available, fall back to CaminoWeather
                self.shouldShowWeatherAppPrompt = false
                Task {
                    await self.refreshWeather()
                }
            }
        }
    }
    
    @MainActor
    func refreshWeather() async {
        // Only fetch weather data from CaminoWeather if not using Apple Weather
        if !shouldShowWeatherAppPrompt {
            await caminoWeatherViewModel.refreshWeather()
            
            // Check if WeatherKit authentication failed
            if let error = caminoWeatherViewModel.errorMessage {
                self.errorMessage = error
                
                if error.contains("WeatherKit authorization failed") || 
                   error.contains("To get live weather data, you need to configure WeatherKit") {
                    shouldShowWeatherAppPrompt = true
                    // Try to open Apple Weather as a fallback
                    openWeatherForCurrentLocation()
                }
            }
            
            // If we have data, use it
            if !caminoWeatherViewModel.weatherData.isEmpty {
                self.weatherData = caminoWeatherViewModel.weatherData
            }
        } else {
            // If we should be using Apple Weather, try to open it now
            openWeatherForCurrentLocation()
        }
    }
    
    func openNativeWeatherApp(for destination: CaminoDestination) {
        // Weather app URL scheme for specific location
        // Format: weather:///?lat={latitude}&lon={longitude}
        if let weatherURL = URL(string: "weather:///?lat=\(destination.coordinate.latitude)&lon=\(destination.coordinate.longitude)") {
            UIApplication.shared.open(weatherURL, options: [:]) { success in
                if !success {
                    // Fallback to Apple Maps with weather enabled
                    let coordinate = CLLocationCoordinate2D(
                        latitude: destination.coordinate.latitude,
                        longitude: destination.coordinate.longitude
                    )
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                    mapItem.name = destination.locationName
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsShowsTrafficKey: true])
                }
            }
        }
    }
    
    @MainActor
    func openWeatherForCurrentLocation() {
        hasAttemptedRedirect = true
        
        // If we have current location, use it
        if let currentLocation = locationManager.location {
            let weatherURL = URL(string: "weather:///?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)")
            
            if let url = weatherURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // If we can't open Weather app with coordinates, try just the base URL
                if let baseURL = URL(string: "weather:///"), UIApplication.shared.canOpenURL(baseURL) {
                    UIApplication.shared.open(baseURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback to Apple Maps with weather enabled if weather app isn't available
                    let coordinate = currentLocation.coordinate
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                    mapItem.name = "Current Location"
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsShowsTrafficKey: true])
                }
            }
        } else {
            // If we don't have current location, just open Weather app
            if let baseURL = URL(string: "weather:///"), UIApplication.shared.canOpenURL(baseURL) {
                UIApplication.shared.open(baseURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    // Add method to switch to CaminoWeather
    func useCaminoWeather() async {
        shouldShowWeatherAppPrompt = false
        await refreshWeather()
    }
    
    // Track when tab is selected
    @MainActor
    func tabWasSelected() {
        isTabSelected = true
        // Always try to open Apple Weather when tab is selected
        openWeatherForCurrentLocation()
    }
} 