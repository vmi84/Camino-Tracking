import SwiftUI

struct ErrorHandlingExampleView: View {
    @State private var currentError: Models.AppError?
    @State private var isLoading = false
    @State private var weather: ExampleWeatherData?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Error Handling Example")
                .font(.title)
                .fontWeight(.bold)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            } else if let weather = weather {
                weatherView(weather)
            } else {
                instructionsView
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button("Simulate Success") {
                    simulateSuccessfulRequest()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Simulate Network Error") {
                    currentError = Models.AppError.networkError(message: "Could not connect to server")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                Button("Simulate Invalid Data Error") {
                    currentError = Models.AppError.invalidData(message: "Weather data format has changed")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                
                Button("Simulate Server Error") {
                    currentError = Models.AppError.serverError(message: "Server returned status code 500")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .padding()
        .alert(
            currentError?.title ?? "Error",
            isPresented: .init(
                get: { currentError != nil },
                set: { if !$0 { currentError = nil } }
            ),
            presenting: currentError
        ) { _ in
            Button("OK") {
                currentError = nil
            }
        } message: { error in
            Text(error.message)
        }
    }
    
    private var instructionsView: some View {
        VStack(spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .padding(.bottom, 10)
            
            Text("This example demonstrates how to use the AppError and error handling utilities")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Press one of the buttons below to see different error handling scenarios")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func weatherView(_ data: ExampleWeatherData) -> some View {
        VStack(spacing: 12) {
            Image(systemName: data.iconName)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text(data.location)
                .font(.headline)
            
            Text("\(data.temperature)°C")
                .font(.system(size: 36, weight: .bold))
            
            Text(data.description)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func simulateSuccessfulRequest() {
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let sampleWeather = ExampleWeatherData(
                location: "Santiago de Compostela",
                temperature: 22,
                description: "Partly Cloudy",
                iconName: "cloud.sun.fill"
            )
            
            // Success case
            self.weather = sampleWeather
            self.isLoading = false
        }
    }
}

// Sample data model for the example
struct ExampleWeatherData {
    let location: String
    let temperature: Int
    let description: String
    let iconName: String
}

struct ErrorHandlingExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorHandlingExampleView()
    }
} 