import Foundation
import Combine
import SwiftUI

/// Service responsible for fetching weather data using the NetworkService
class WeatherService: ObservableObject {
    private let networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    /// Current weather condition for UI display
    @Published var currentCondition: WeatherCondition?
    
    /// Loading state indicator
    @Published var isLoading = false
    
    /// Error state
    @Published var hasError = false
    
    /// Initializes the WeatherService with the dependencies
    /// - Parameter networkService: The NetworkService to use for HTTP requests
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// Fetches weather data for a given location
    /// - Parameters:
    ///   - latitude: Location latitude
    ///   - longitude: Location longitude
    ///   - completion: Completion handler called when the operation finishes
    func fetchWeather(
        latitude: Double,
        longitude: Double,
        completion: ((Models.ApiResponse<WeatherData>) -> Void)? = nil
    ) {
        isLoading = true
        hasError = false
        
        guard let url = createWeatherURL(latitude: latitude, longitude: longitude) else {
            handleError(Models.AppError.invalidData(message: "Failed to create weather API URL"))
            completion?(Models.ApiResponse(error: Models.AppError.invalidData(message: "Invalid URL"), success: false))
            return
        }
        
        networkService.get(url: url, headers: [:], shouldShowError: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.isLoading = false
                    self.hasError = true
                    print("Error in fetchWeather: \(error)")
                }
            } receiveValue: { [weak self] (response: Models.ApiResponse<WeatherData>) in
                guard let self = self else { return }
                self.isLoading = false
                
                if let weatherData = response.data {
                    // Successfully fetched weather data
                    self.updateCurrentCondition(from: weatherData)
                } else {
                    // Handle error
                    self.hasError = true
                }
                
                completion?(response)
            }
            .store(in: &cancellables)
    }
    
    /// Creates the URL for the weather API
    /// - Parameters:
    ///   - latitude: Location latitude
    ///   - longitude: Location longitude
    /// - Returns: URL for the weather API request
    private func createWeatherURL(latitude: Double, longitude: Double) -> URL? {
        // In a real app, this would use your actual weather API endpoint
        // This is just an example structure
        var components = URLComponents(string: "https://api.example.com/weather")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: "YOUR_API_KEY") // Would come from secure storage
        ]
        return components?.url
    }
    
    /// Updates the current weather condition from the weather data
    /// - Parameter weatherData: The weather data from the API
    private func updateCurrentCondition(from weatherData: WeatherData) {
        guard let weather = weatherData.current.weather.first else { return }
        
        let condition = WeatherCondition(
            temperature: weatherData.current.temp,
            feelsLike: weatherData.current.feelsLike,
            humidity: weatherData.current.humidity,
            windSpeed: weatherData.current.windSpeed,
            description: weather.description,
            icon: weather.icon,
            main: weather.main
        )
        
        self.currentCondition = condition
    }
    
    /// Handles errors in the weather service
    /// - Parameter error: The error that occurred
    private func handleError(_ error: Models.AppError) {
        hasError = true
        isLoading = false
        // Error is already handled by NetworkService through AlertManager
    }
}

// MARK: - Weather Data Models

/// Weather condition for display in the UI
struct WeatherCondition {
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let description: String
    let icon: String
    let main: String
    
    var iconURL: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
    
    var formattedTemperature: String {
        return String(format: "%.1f°C", temperature)
    }
    
    var formattedFeelsLike: String {
        return String(format: "%.1f°C", feelsLike)
    }
}

/// Weather API response model
struct WeatherData: Decodable {
    let current: CurrentWeather
    let daily: [DailyForecast]
}

struct CurrentWeather: Decodable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let weather: [Weather]
}

struct DailyForecast: Decodable {
    let temp: Temperature
    let weather: [Weather]
    let dt: TimeInterval
    
    var date: Date {
        return Date(timeIntervalSince1970: dt)
    }
}

struct Temperature: Decodable {
    let day: Double
    let night: Double
    let min: Double
    let max: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// MARK: - Example View

/// Example view that shows how to use the WeatherService
struct WeatherExample: View {
    @ObservedObject private var weatherService: WeatherService
    @State private var location = (latitude: 42.3601, longitude: -71.0589) // Boston
    
    init(networkService: NetworkService) {
        self.weatherService = WeatherService(networkService: networkService)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Weather Example")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if weatherService.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                Text("Loading weather data...")
            } else if let condition = weatherService.currentCondition {
                weatherInfoView(condition)
            } else if weatherService.hasError {
                Text("Failed to load weather data")
                    .foregroundColor(.red)
            } else {
                Text("No weather data")
                    .foregroundColor(.secondary)
            }
            
            Button(action: fetchWeather) {
                Text("Refresh Weather")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
        }
        .padding()
        .onAppear(perform: fetchWeather)
    }
    
    /// Fetches weather data for the current location
    private func fetchWeather() {
        weatherService.fetchWeather(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
    
    /// Displays weather information
    /// - Parameter condition: The weather condition to display
    @ViewBuilder
    private func weatherInfoView(_ condition: WeatherCondition) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(condition.formattedTemperature)
                        .font(.system(size: 42, weight: .bold))
                    
                    Text(condition.main)
                        .font(.title2)
                        .foregroundColor(.primary)
                    
                    Text(condition.description.capitalized)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let iconURL = condition.iconURL {
                    AsyncImage(url: iconURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Feels like:")
                        .fontWeight(.medium)
                    Text(condition.formattedFeelsLike)
                }
                
                HStack {
                    Text("Humidity:")
                        .fontWeight(.medium)
                    Text("\(condition.humidity)%")
                }
                
                HStack {
                    Text("Wind:")
                        .fontWeight(.medium)
                    Text("\(String(format: "%.1f", condition.windSpeed)) m/s")
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
} 