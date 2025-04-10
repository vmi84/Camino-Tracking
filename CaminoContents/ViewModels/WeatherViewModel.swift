import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: [CaminoDestination: Weather] = [:]
    @Published var destinations: [CaminoDestination] = []
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    private let weatherStore = WeatherStore.shared
    
    init() {
        destinations = CaminoDestination.allDestinations
    }
    
    func refreshWeather() async {
        if weatherStore.shouldRefreshWeather() {
            var hasLoadedAnyRealData = false
            
            for destination in destinations {
                do {
                    let location = CLLocation(latitude: destination.coordinate.latitude, 
                                            longitude: destination.coordinate.longitude)
                    let weather = try await weatherService.weather(for: location)
                    weatherData[destination] = weather
                    hasLoadedAnyRealData = true
                    print("Loaded real weather data for \(destination.locationName)")
                } catch {
                    print("Error fetching weather for \(destination.locationName): \(error.localizedDescription)")
                    // If we fail to load real data, create mock data
                    if weatherData[destination] == nil {
                        weatherData[destination] = createMockWeather(for: destination)
                    }
                }
            }
            
            if !hasLoadedAnyRealData {
                errorMessage = "Using sample weather data. To get live data, configure WeatherKit in your Apple Developer account."
            } else {
                errorMessage = nil
            }
            
            cacheCurrentWeatherData()
        } else {
            print("Using cached weather data (less than 15 minutes old)")
            loadCachedWeatherData()
        }
    }
    
    private func loadCachedWeatherData() {
        guard let cachedData = weatherStore.loadWeatherData() else { return }
        
        var hasLoadedAnyCachedData = false
        
        for destination in destinations {
            let key = "\(destination.id)"
            if cachedData[key] != nil {
                // In a real app, we would deserialize the Weather data here
                hasLoadedAnyCachedData = true
                print("Loaded cached weather for \(destination.locationName)")
                
                // If no weather data exists for this destination yet, use mock data
                if weatherData[destination] == nil {
                    weatherData[destination] = createMockWeather(for: destination)
                }
            }
        }
        
        if !hasLoadedAnyCachedData {
            // If no cached data was loaded, create mock data for all destinations
            for destination in destinations {
                if weatherData[destination] == nil {
                    weatherData[destination] = createMockWeather(for: destination)
                }
            }
            errorMessage = "Using sample weather data. To get live data, configure WeatherKit in your Apple Developer account."
        }
    }
    
    private func cacheCurrentWeatherData() {
        // Simplified caching implementation
        var cachedData: [String: Data] = [:]
        
        for (destination, _) in weatherData {
            let key = "\(destination.id)"
            
            // In a real app, we would serialize the Weather data here
            let dummyData = "cached".data(using: .utf8)!
            cachedData[key] = dummyData
        }
        
        weatherStore.saveWeatherData(cachedData)
    }
    
    // Create mock weather data for a destination
    private func createMockWeather(for destination: CaminoDestination) -> Weather? {
        // This is a simplified approach - in a real implementation, you'd create a full Weather object
        // We're returning nil for now since Weather cannot be mocked easily
        // Instead, we'll handle this in the View layer
        print("Creating mock weather for \(destination.locationName)")
        return nil
    }
} 