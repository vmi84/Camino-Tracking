import Foundation
import WeatherKit
import CoreLocation

@available(iOS 16.0, macOS 13.0, *)
@MainActor
public class WeatherViewModel: ObservableObject {
    @Published public var weatherData: [CaminoDestination: Weather] = [:]
    @Published public var destinations: [CaminoDestination] = []
    
    private let weatherService = WeatherService.shared
    
    public init() {
        destinations = CaminoDestination.allDestinations
    }
    
    public func refreshWeather() async {
        for destination in destinations {
            do {
                let location = CLLocation(latitude: destination.coordinate.latitude, 
                                        longitude: destination.coordinate.longitude)
                let weather = try await weatherService.weather(for: location)
                weatherData[destination] = weather
            } catch {
                print("Error fetching weather for \(destination.locationName): \(error.localizedDescription)")
            }
        }
    }
} 