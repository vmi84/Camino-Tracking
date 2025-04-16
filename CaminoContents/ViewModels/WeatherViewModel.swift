import Foundation
import WeatherKit
import CaminoModels
import CoreLocation
import SwiftyJSON
import UIKit
import MapKit

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentLocationWeather: Weather?
    @Published var errorMessage: String?
    @Published var shouldShowWeatherAppPrompt: Bool = true
    @Published var isTabSelected: Bool = false
    @Published var hasAttemptedRedirect: Bool = false
    @Published var isLoading: Bool = false
    
    private var locationManager: LocationManager {
        return LocationManager.shared
    }
    
    init() {}
    
    func refreshWeather() async {
        guard !shouldShowWeatherAppPrompt else {
            print("WeatherViewModel: Skipping fetch, shouldShowWeatherAppPrompt is true.")
            self.currentLocationWeather = nil
            self.errorMessage = nil
            self.isLoading = false
            return
        }

        guard let location = locationManager.location else {
            self.errorMessage = "Current location not available."
            self.currentLocationWeather = nil
            self.isLoading = false
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.currentLocationWeather = nil

        print("WeatherViewModel: Attempting to fetch weather via WeatherKit...")
        
        do {
            let weatherService = WeatherService.shared
            self.currentLocationWeather = try await weatherService.weather(for: location)
            print("WeatherViewModel: WeatherKit fetch successful.")
        } catch {
            print("WeatherViewModel: WeatherKit fetch failed - \(error)")
            self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            self.shouldShowWeatherAppPrompt = true
        }
        self.isLoading = false
    }
    
    func openWeatherForCurrentLocation() {
        print("WeatherViewModel: Attempting to open Apple Weather...")
        guard !hasAttemptedRedirect else {
            print("WeatherViewModel: Already attempted redirect, skipping.")
            return
        }
        hasAttemptedRedirect = true

        if let currentLocation = locationManager.location {
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            if let weatherURL = URL(string: "weather:///?lat=\(lat)&lon=\(lon)") {
                print("WeatherViewModel: Trying deep link with coords: \(weatherURL)")
                if UIApplication.shared.canOpenURL(weatherURL) {
                    UIApplication.shared.open(weatherURL, options: [:]) { success in
                        print("WeatherViewModel: Deep link with coords open success: \(success)")
                        if !success {
                            self.tryOpenBaseWeatherURL()
                        }
                    }
                    return
                } else {
                    print("WeatherViewModel: Cannot open deep link with coords.")
                    self.tryOpenBaseWeatherURL()
                    return
                }
            }
        } else {
            print("WeatherViewModel: Current location not available for coords deep link.")
        }
        
        self.tryOpenBaseWeatherURL()
    }

    private func tryOpenBaseWeatherURL() {
        if let baseURL = URL(string: "weather:///") {
            print("WeatherViewModel: Trying base deep link: \(baseURL)")
            if UIApplication.shared.canOpenURL(baseURL) {
                UIApplication.shared.open(baseURL, options: [:]) { success in
                    print("WeatherViewModel: Base deep link open success: \(success)")
                    if !success {
                        self.fallbackToMaps()
                    }
                }
                return
            } else {
                print("WeatherViewModel: Cannot open base deep link.")
            }
        }
        self.fallbackToMaps()
    }

    private func fallbackToMaps() {
        print("WeatherViewModel: Falling back to Apple Maps.")
        if let currentLocation = locationManager.location {
            let coordinate = currentLocation.coordinate
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            mapItem.name = "Current Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsShowsTrafficKey: true])
        } else {
            print("WeatherViewModel: Cannot fallback to Maps, no location.")
        }
    }

    func useCaminoWeather() async {
        print("WeatherViewModel: Switching to use WeatherKit.")
        shouldShowWeatherAppPrompt = false
        hasAttemptedRedirect = false
        await refreshWeather()
    }

    func useAppleWeatherPrompt() {
        print("WeatherViewModel: Switching back to prompting Apple Weather.")
        shouldShowWeatherAppPrompt = true
        hasAttemptedRedirect = false
        self.currentLocationWeather = nil
        self.errorMessage = nil
        self.isLoading = false
    }
    
    func tabWasSelected() {
        print("WeatherViewModel: Weather tab selected.")
        if shouldShowWeatherAppPrompt {
            openWeatherForCurrentLocation()
        } else {
            print("WeatherViewModel: Tab selected, but not prompting for Apple Weather.")
        }
    }
} 