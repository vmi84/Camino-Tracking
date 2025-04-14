import Foundation
import Combine

/// Service responsible for handling network requests
class NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let alertManager: AlertManager
    
    /// Initializes a new NetworkService
    /// - Parameters:
    ///   - session: URLSession to use for network requests (defaults to shared)
    ///   - alertManager: AlertManager to handle and display errors
    init(session: URLSession = .shared, alertManager: AlertManager) {
        self.session = session
        self.alertManager = alertManager
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    /// Performs a network request with the specified parameters
    /// - Parameters:
    ///   - endpoint: The endpoint URL to request
    ///   - method: HTTP method to use
    ///   - body: Optional request body
    ///   - headers: Optional HTTP headers
    ///   - shouldShowError: Whether to automatically show errors via AlertManager
    /// - Returns: A publisher that emits an ApiResponse containing the decoded data or error
    func request<T: Decodable>(
        endpoint: URL,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String] = [:],
        shouldShowError: Bool = true
    ) -> AnyPublisher<Models.ApiResponse<T>, Never> {
        var request = URLRequest(url: endpoint)
        request.httpMethod = method.rawValue
        
        // Add default headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add custom headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                return createErrorResponse(error: Models.AppError.invalidData(
                    message: "Failed to encode request body: \(error.localizedDescription)"
                ), shouldShowError: shouldShowError)
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .mapError { error -> Models.AppError in
                return Models.AppError.networkError(message: error.localizedDescription)
            }
            .flatMap { data, response -> AnyPublisher<Models.ApiResponse<T>, Models.AppError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: Models.AppError.networkError(message: "Invalid response type"))
                        .eraseToAnyPublisher()
                }
                
                // Handle HTTP errors
                if !(200...299).contains(httpResponse.statusCode) {
                    let errorMessage = self.parseErrorMessage(from: data) ?? "HTTP Error: \(httpResponse.statusCode)"
                    return Fail(error: self.mapHTTPError(statusCode: httpResponse.statusCode, message: errorMessage))
                        .eraseToAnyPublisher()
                }
                
                // Try to decode the response
                do {
                    let decodedData = try self.decoder.decode(T.self, from: data)
                    return Just(Models.ApiResponse(data: decodedData, success: true))
                        .setFailureType(to: Models.AppError.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: Models.AppError.invalidData(message: "Failed to decode response: \(error.localizedDescription)"))
                        .eraseToAnyPublisher()
                }
            }
            .catch { error -> AnyPublisher<Models.ApiResponse<T>, Never> in
                return self.createErrorResponse(error: error, shouldShowError: shouldShowError)
            }
            .eraseToAnyPublisher()
    }
    
    /// Maps HTTP status codes to appropriate AppError types
    /// - Parameters:
    ///   - statusCode: The HTTP status code
    ///   - message: Error message
    /// - Returns: Appropriate AppError for the status code
    private func mapHTTPError(statusCode: Int, message: String) -> Models.AppError {
        switch statusCode {
        case 400:
            return Models.AppError.invalidData(message: message)
        case 401:
            return Models.AppError.authenticationError(message: message)
        case 403:
            return Models.AppError.permissionError(message: message)
        case 404:
            return Models.AppError.notFoundError(message: message)
        case 500...599:
            return Models.AppError.serverError(message: message)
        default:
            return Models.AppError.networkError(message: message)
        }
    }
    
    /// Attempts to parse an error message from response data
    /// - Parameter data: Response data
    /// - Returns: Error message if parsable
    private func parseErrorMessage(from data: Data) -> String? {
        // Try to parse standard error response format
        struct ErrorResponse: Decodable {
            let message: String?
            let error: String?
        }
        
        do {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            return errorResponse.message ?? errorResponse.error
        } catch {
            // If we can't parse as JSON, try to convert to string
            return String(data: data, encoding: .utf8)
        }
    }
    
    /// Creates an error response publisher
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - shouldShowError: Whether to show the error via AlertManager
    /// - Returns: A publisher that emits an error response
    private func createErrorResponse<T>(error: Models.AppError, shouldShowError: Bool) -> AnyPublisher<Models.ApiResponse<T>, Never> {
        if shouldShowError {
            DispatchQueue.main.async {
                self.alertManager.showError(message: error.message, severity: self.mapErrorSeverity(error.logLevel))
            }
        }
        
        return Just(Models.ApiResponse<T>(data: nil, error: error, success: false))
            .eraseToAnyPublisher()
    }
    
    /// Maps AppError.LogLevel to ErrorSeverity
    /// - Parameter logLevel: The log level to map
    /// - Returns: Corresponding ErrorSeverity
    private func mapErrorSeverity(_ logLevel: Models.AppError.LogLevel) -> ErrorSeverity {
        switch logLevel {
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        case .critical: return .critical
        }
    }
}

/// HTTP Methods supported by the NetworkService
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Convenience extension for simple requests
extension NetworkService {
    /// Performs a GET request with the specified parameters
    /// - Parameters:
    ///   - url: The URL to request
    ///   - headers: Optional HTTP headers
    ///   - shouldShowError: Whether to automatically show errors via AlertManager
    /// - Returns: A publisher that emits an ApiResponse containing the decoded data or error
    func get<T: Decodable>(
        url: URL,
        headers: [String: String] = [:],
        shouldShowError: Bool = true
    ) -> AnyPublisher<Models.ApiResponse<T>, Never> {
        return request(
            endpoint: url,
            method: .get,
            headers: headers,
            shouldShowError: shouldShowError
        )
    }
    
    /// Performs a POST request with the specified parameters
    /// - Parameters:
    ///   - url: The URL to request
    ///   - body: The request body
    ///   - headers: Optional HTTP headers
    ///   - shouldShowError: Whether to automatically show errors via AlertManager
    /// - Returns: A publisher that emits an ApiResponse containing the decoded data or error
    func post<T: Decodable, U: Encodable>(
        url: URL,
        body: U,
        headers: [String: String] = [:],
        shouldShowError: Bool = true
    ) -> AnyPublisher<Models.ApiResponse<T>, Never> {
        return request(
            endpoint: url,
            method: .post,
            body: body,
            headers: headers,
            shouldShowError: shouldShowError
        )
    }
} 