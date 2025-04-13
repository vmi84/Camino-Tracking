import Foundation
import WeatherKit
import CaminoModels
import CoreLocation
import SwiftyJSON
import UIKit
import MapKit

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: [CaminoDestination: Weather] = [:]
    @Published var destinations: [CaminoDestination] = []
    @Published var errorMessage: String?
    @Published var shouldShowWeatherAppPrompt: Bool = true
    @Published var isTabSelected: Bool = false
    @Published var hasRedirected: Bool = false
    
    private let caminoWeatherViewModel: CaminoWeatherViewModel
    private var locationManager: LocationManager {
        return LocationManager.shared
    }
    
    init() {
        self.caminoWeatherViewModel = CaminoWeatherViewModel()
        self.destinations = CaminoDestination.allDestinations
    }
    
    func refreshWeather() async {
        // Only fetch weather data if explicitly asked to use CaminoWeather
        if !shouldShowWeatherAppPrompt {
            await caminoWeatherViewModel.refreshWeather()
            
            if let error = caminoWeatherViewModel.errorMessage {
                self.errorMessage = error
                // If WeatherKit fails, default back to Apple Weather
                if error.contains("WeatherKit authorization failed") || 
                   error.contains("To get live weather data, you need to configure WeatherKit") {
                    shouldShowWeatherAppPrompt = true
                    openWeatherForCurrentLocation()
                }
            }
            
            if !caminoWeatherViewModel.weatherData.isEmpty {
                self.weatherData = caminoWeatherViewModel.weatherData
            }
        } else {
            // Default behavior is to open Apple Weather
            openWeatherForCurrentLocation()
        }
    }
    
    func openNativeWeatherApp(for destination: CaminoDestination) {
        // Weather app URL scheme for specific location
        let weatherURL = URL(string: "weather:///?lat=\(destination.coordinate.latitude)&lon=\(destination.coordinate.longitude)")
        
        if let url = weatherURL, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
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
    
    func openWeatherForCurrentLocation() {
        hasRedirected = true
        
        // Try to open Weather with current location coordinates
        if let currentLocation = locationManager.location {
            let weatherURL = URL(string: "weather:///?lat=\(currentLocation.coordinate.latitude)&lon=\(currentLocation.coordinate.longitude)")
            
            if let url = weatherURL, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }
        
        // Fallback to just opening the Weather app
        if let baseURL = URL(string: "weather:///"), UIApplication.shared.canOpenURL(baseURL) {
            UIApplication.shared.open(baseURL, options: [:], completionHandler: nil)
        } else {
            // Final fallback to Apple Maps
            if let currentLocation = locationManager.location {
                let coordinate = currentLocation.coordinate
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                mapItem.name = "Current Location"
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsShowsTrafficKey: true])
            }
        }
    }
    
    // Add method to switch to CaminoWeather
    func useCaminoWeather() async {
        shouldShowWeatherAppPrompt = false
        await refreshWeather()
    }
    
    // Track when tab is selected
    func tabWasSelected() {
        isTabSelected = true
        // Always try to open Apple Weather when tab is selected
        openWeatherForCurrentLocation()
    }
} 