import Foundation

/// Models namespace to avoid naming conflicts
enum Models {
    // MARK: - ApiResponse
    
    /// A generic wrapper for API responses
    struct ApiResponse<T> {
        /// The successful data from the API, if available
        let data: T?
        
        /// The error that occurred, if any
        let error: AppError?
        
        /// Indicates whether the request was successful
        var success: Bool {
            data != nil && error == nil
        }
        
        /// Initializes a successful response with data
        /// - Parameter data: The data returned from the API
        init(data: T) {
            self.data = data
            self.error = nil
        }
        
        /// Initializes a failed response with an error
        /// - Parameter error: The error that occurred
        init(error: AppError) {
            self.data = nil
            self.error = error
        }
        
        /// Initializes with optional data, error, and success flag
        init(data: T? = nil, error: AppError? = nil, success: Bool) {
            self.data = data
            self.error = error
        }
    }
    
    // MARK: - AppError
    
    /// Application-specific error types
    enum AppError: Error, Identifiable {
        /// Network-related errors (connectivity, server issues)
        case networkError(message: String)
        
        /// Data validation or parsing errors
        case invalidData(message: String)
        
        /// Authentication errors
        case authenticationError(message: String)
        
        /// Permission or access errors
        case permissionError(message: String)
        
        /// Not found errors (404, etc.)
        case notFoundError(message: String)
        
        /// Server errors (500 range)
        case serverError(message: String)
        
        /// Generic or uncategorized errors
        case generalError(message: String)
        
        /// Unique identifier for the error
        var id: String {
            switch self {
            case .networkError(let message):
                return "network-\(message.hashValue)"
            case .invalidData(let message):
                return "invalidData-\(message.hashValue)"
            case .authenticationError(let message):
                return "authentication-\(message.hashValue)"
            case .permissionError(let message):
                return "permission-\(message.hashValue)"
            case .notFoundError(let message):
                return "notFound-\(message.hashValue)"
            case .serverError(let message):
                return "server-\(message.hashValue)"
            case .generalError(let message):
                return "general-\(message.hashValue)"
            }
        }
        
        /// User-friendly message explaining the error
        var message: String {
            switch self {
            case .networkError(let message):
                return message
            case .invalidData(let message):
                return message
            case .authenticationError(let message):
                return message
            case .permissionError(let message):
                return message
            case .notFoundError(let message):
                return message
            case .serverError(let message):
                return message
            case .generalError(let message):
                return message
            }
        }
        
        /// Title for the error, used in UI presentations
        var title: String {
            switch self {
            case .networkError:
                return "Network Error"
            case .invalidData:
                return "Data Error"
            case .authenticationError:
                return "Authentication Error"
            case .permissionError:
                return "Permission Error"
            case .notFoundError:
                return "Not Found"
            case .serverError:
                return "Server Error"
            case .generalError:
                return "Error"
            }
        }
        
        /// Icon name for the error, used in UI presentations
        var iconName: String {
            switch self {
            case .networkError:
                return "wifi.slash"
            case .invalidData:
                return "doc.text.magnifyingglass"
            case .authenticationError:
                return "lock.shield"
            case .permissionError:
                return "hand.raised"
            case .notFoundError:
                return "mappin.slash"
            case .serverError:
                return "exclamationmark.server"
            case .generalError:
                return "exclamationmark.triangle"
            }
        }
        
        /// Error log level for internal logging
        var logLevel: LogLevel {
            switch self {
            case .networkError, .invalidData, .notFoundError:
                return .warning
            case .authenticationError, .permissionError:
                return .error
            case .serverError:
                return .critical
            case .generalError:
                return .info
            }
        }
        
        /// Log levels for internal error logging
        enum LogLevel: String {
            case info
            case warning
            case error
            case critical
        }
    }
} 