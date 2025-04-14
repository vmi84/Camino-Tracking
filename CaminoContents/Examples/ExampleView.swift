import SwiftUI
import Combine

/// Example view demonstrating the AlertManager and NetworkService
struct ExampleView: View {
    @StateObject private var alertManager = AlertManager()
    private var networkService: NetworkService
    private var weatherService: WeatherService
    
    @State private var cancellables = Set<AnyCancellable>()
    @State private var exampleText = "No data fetched yet"
    @State private var isLoading = false
    
    init() {
        let alertManager = AlertManager()
        self._alertManager = StateObject(wrappedValue: alertManager)
        self.networkService = NetworkService(alertManager: alertManager)
        self.weatherService = WeatherService(networkService: networkService)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("API and Alert Examples")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                // Example error buttons
                Group {
                    Text("Trigger example alerts:")
                        .font(.headline)
                    
                    HStack {
                        errorButton(
                            title: "Info",
                            color: .blue,
                            action: { showInfoAlert() }
                        )
                        
                        errorButton(
                            title: "Warning",
                            color: .orange,
                            action: { showWarningAlert() }
                        )
                        
                        errorButton(
                            title: "Error",
                            color: .red,
                            action: { showErrorAlert() }
                        )
                        
                        errorButton(
                            title: "Critical",
                            color: .purple,
                            action: { showCriticalAlert() }
                        )
                    }
                }
                
                Divider()
                
                // Network examples
                Group {
                    Text("Network request examples:")
                        .font(.headline)
                    
                    HStack {
                        networkButton(
                            title: "Valid Request",
                            color: .green,
                            action: { makeSuccessfulRequest() }
                        )
                        
                        networkButton(
                            title: "Invalid URL",
                            color: .red,
                            action: { makeInvalidURLRequest() }
                        )
                        
                        networkButton(
                            title: "Server Error",
                            color: .orange,
                            action: { makeServerErrorRequest() }
                        )
                    }
                }
                
                Divider()
                
                // Result area
                Group {
                    Text("Result:")
                        .font(.headline)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(exampleText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Weather example
                NavigationLink(destination: WeatherExample(networkService: networkService)) {
                    Text("Open Weather Example")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Example View")
        }
        .withErrorAlert(alertManager: alertManager)
    }
    
    // MARK: - Button Builders
    
    @ViewBuilder
    private func errorButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func networkButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    // MARK: - Alert Examples
    
    private func showInfoAlert() {
        alertManager.showError(message: "This is an information message.", severity: .info)
    }
    
    private func showWarningAlert() {
        alertManager.showError(message: "This is a warning message!", severity: .warning)
    }
    
    private func showErrorAlert() {
        alertManager.showError(message: "This is an error message!", severity: .error)
    }
    
    private func showCriticalAlert() {
        alertManager.showError(message: "This is a critical error message!", severity: .critical)
    }
    
    // MARK: - Network Examples
    
    private func makeSuccessfulRequest() {
        isLoading = true
        exampleText = "Loading..."
        
        // Mock successful response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.exampleText = "Successfully fetched data!"
        }
    }
    
    private func makeInvalidURLRequest() {
        isLoading = true
        exampleText = "Loading..."
        
        let error = Models.AppError.invalidData(message: "The URL was invalid or malformed")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.alertManager.showError(message: error.message, severity: .error)
            self.isLoading = false
            self.exampleText = "Request failed: Invalid URL"
        }
    }
    
    private func makeServerErrorRequest() {
        isLoading = true
        exampleText = "Loading..."
        
        let error = Models.AppError.serverError(message: "The server returned a 500 error")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.alertManager.showError(message: error.message, severity: .critical)
            self.isLoading = false
            self.exampleText = "Request failed: Server error"
        }
    }
}

// MARK: - Preview

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
} 