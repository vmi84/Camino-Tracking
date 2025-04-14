import Foundation
import Combine

/// A service for fetching weather data with built-in error handling
final class WeatherNetworkService {
    
    enum Endpoint {
        case currentWeather(lat: Double, lon: Double)
        case forecast(lat: Double, lon: Double)
        
        var path: String {
            switch self {
            case .currentWeather:
                return "/data/2.5/weather"
            case .forecast:
                return "/data/2.5/forecast"
            }
        }
        
        var queryItems: [URLQueryItem] {
            switch self {
            case .currentWeather(let lat, let lon), .forecast(let lat, let lon):
                return [
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "units", value: "metric"),
                    URLQueryItem(name: "appid", value: WeatherNetworkService.apiKey)
                ]
            }
        }
    }
    
    private static let baseURL = "https://api.openweathermap.org"
    private static let apiKey = "YOUR_API_KEY" // Replace with actual API key
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches weather data for a specific location
    /// - Parameters:
    ///   - latitude: The latitude coordinate
    ///   - longitude: The longitude coordinate
    /// - Returns: An `ApiResponse` containing `WeatherResponse` or an `AppError`
    func fetchWeather(latitude: Double, longitude: Double) async -> Models.ApiResponse<WeatherResponse> {
        do {
            let endpoint = Endpoint.currentWeather(lat: latitude, lon: longitude)
            return try await fetchWithErrorHandling(endpoint: endpoint, as: WeatherResponse.self)
        } catch {
            return Models.ApiResponse(error: Models.AppError.generalError(message: error.localizedDescription))
        }
    }
    
    /// Fetches a 5-day forecast for a specific location
    /// - Parameters:
    ///   - latitude: The latitude coordinate
    ///   - longitude: The longitude coordinate
    /// - Returns: An `ApiResponse` containing `ForecastResponse` or an `AppError`
    func fetchForecast(latitude: Double, longitude: Double) async -> Models.ApiResponse<ForecastResponse> {
        do {
            let endpoint = Endpoint.forecast(lat: latitude, lon: longitude)
            return try await fetchWithErrorHandling(endpoint: endpoint, as: ForecastResponse.self)
        } catch {
            return Models.ApiResponse(error: Models.AppError.generalError(message: error.localizedDescription))
        }
    }
    
    /// Generic method to fetch and decode data with comprehensive error handling
    /// - Parameters:
    ///   - endpoint: The API endpoint to fetch from
    ///   - type: The expected response type
    /// - Returns: An `ApiResponse` containing decoded data or an `AppError`
    private func fetchWithErrorHandling<T: Decodable>(endpoint: Endpoint, as type: T.Type) async throws -> Models.ApiResponse<T> {
        guard var components = URLComponents(string: Self.baseURL + endpoint.path) else {
            return Models.ApiResponse(error: Models.AppError.invalidData(message: "Invalid URL components"))
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return Models.ApiResponse(error: Models.AppError.invalidData(message: "Failed to create URL"))
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            // Check for valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                return Models.ApiResponse(error: Models.AppError.networkError(message: "Invalid HTTP response"))
            }
            
            // Handle HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success - attempt to decode the data
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    return Models.ApiResponse(data: result)
                } catch {
                    return Models.ApiResponse(error: Models.AppError.invalidData(message: "Failed to decode response: \(error.localizedDescription)"))
                }
                
            case 401:
                return Models.ApiResponse(error: Models.AppError.authenticationError(message: "Unauthorized - Check API key"))
                
            case 404:
                return Models.ApiResponse(error: Models.AppError.notFoundError(message: "Resource not found"))
                
            case 429:
                return Models.ApiResponse(error: Models.AppError.networkError(message: "Rate limit exceeded"))
                
            case 500...599:
                return Models.ApiResponse(error: Models.AppError.serverError(message: "Server error - Please try again later"))
                
            default:
                return Models.ApiResponse(error: Models.AppError.networkError(message: "HTTP Error: \(httpResponse.statusCode)"))
            }
        } catch let error as URLError {
            // Handle specific URLError cases
            switch error.code {
            case .notConnectedToInternet:
                return Models.ApiResponse(error: Models.AppError.networkError(message: "No internet connection"))
                
            case .timedOut:
                return Models.ApiResponse(error: Models.AppError.networkError(message: "Request timed out"))
                
            case .cancelled:
                return Models.ApiResponse(error: Models.AppError.generalError(message: "Request was cancelled"))
                
            default:
                return Models.ApiResponse(error: Models.AppError.networkError(message: error.localizedDescription))
            }
        } catch {
            return Models.ApiResponse(error: Models.AppError.networkError(message: error.localizedDescription))
        }
    }
}

// MARK: - Response Models

struct WeatherResponse: Decodable {
    let name: String
    let main: MainWeather
    let weather: [WeatherInfo]
    
    struct MainWeather: Decodable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let humidity: Int
    }
    
    struct WeatherInfo: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
}

struct ForecastResponse: Decodable {
    let list: [ForecastItem]
    let city: City
    
    struct ForecastItem: Decodable, Identifiable {
        let dt: TimeInterval
        let main: MainWeather
        let weather: [WeatherInfo]
        
        var id: TimeInterval { dt }
    }
    
    struct City: Decodable {
        let name: String
    }
    
    typealias MainWeather = WeatherResponse.MainWeather
    typealias WeatherInfo = WeatherResponse.WeatherInfo
} 