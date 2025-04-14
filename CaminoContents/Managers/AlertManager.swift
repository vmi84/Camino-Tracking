import SwiftUI

/// Error severity levels for logging and displaying alerts
enum ErrorSeverity {
    case info
    case warning
    case error
    case critical
    
    var title: String {
        switch self {
        case .info: return "Information"
        case .warning: return "Warning"
        case .error: return "Error"
        case .critical: return "Critical Error"
        }
    }
}

/// An error that can be displayed as an alert
struct DisplayableError: Identifiable {
    let id = UUID()
    let message: String
    let severity: ErrorSeverity
    let date = Date()
}

/// Manager class responsible for handling error alerts throughout the app
class AlertManager: ObservableObject {
    @Published var activeError: DisplayableError?
    @Published var isShowingError = false
    
    private var errorLog: [DisplayableError] = []
    
    /// Shows an error alert with the given message and severity
    /// - Parameters:
    ///   - message: The error message to display
    ///   - severity: The severity level of the error
    func showError(message: String, severity: ErrorSeverity = .error) {
        let error = DisplayableError(message: message, severity: severity)
        activeError = error
        isShowingError = true
        logError(error)
    }
    
    /// Dismisses the currently displayed error
    func dismissError() {
        isShowingError = false
        activeError = nil
    }
    
    /// Logs an error to the internal error log
    /// - Parameter error: The error to log
    private func logError(_ error: DisplayableError) {
        errorLog.append(error)
        
        // Log to console for debugging
        let severityString: String
        switch error.severity {
        case .info: severityString = "INFO"
        case .warning: severityString = "WARNING"
        case .error: severityString = "ERROR"
        case .critical: severityString = "CRITICAL"
        }
        
        print("[\(severityString)] \(error.date): \(error.message)")
    }
    
    /// Returns the error log for the current session
    /// - Returns: Array of errors logged during this session
    func getErrorLog() -> [DisplayableError] {
        return errorLog
    }
}

// View extension to easily add error alerts using the AlertManager
extension View {
    func withErrorAlert(alertManager: AlertManager) -> some View {
        self.alert(
            alertManager.activeError?.severity.title ?? "Error",
            isPresented: .init(
                get: { alertManager.isShowingError },
                set: { alertManager.isShowingError = $0 }
            ),
            presenting: alertManager.activeError
        ) { _ in
            Button("OK") {
                alertManager.dismissError()
            }
        } message: { error in
            Text(error.message)
        }
    }
} 