import SwiftUI
import WeatherKit
import CoreLocation
import CaminoModels

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel // Inject ViewModel
    @EnvironmentObject var locationManager: LocationManager // Keep for checking availability
    @Environment(\.colorScheme) var colorScheme // Keep for attribution logo

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // Check prompt flag first
                if viewModel.shouldShowWeatherAppPrompt {
                    Spacer()
                    ContentUnavailableView {
                        Label("Apple Weather", systemImage: "arrow.up.forward.app")
                    } description: {
                        Text("Opening the Apple Weather app for your current location.")
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else if viewModel.isLoading { // Check loading state from ViewModel
                    Spacer()
                    ProgressView("Fetching Weather...")
                        .padding()
                    Spacer()
                } else if let errorMsg = viewModel.errorMessage { // Check error message from ViewModel
                    Spacer()
                    ContentUnavailableView {
                        Label("Weather Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("Could not load weather data.\n\(errorMsg)")
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else if locationManager.location == nil {
                     Spacer()
                     ContentUnavailableView {
                         Label("Location Needed", systemImage: "location.slash")
                     } description: {
                         Text("Please enable location services in Settings to view weather for your current location.")
                             .multilineTextAlignment(.center)
                     }
                     Spacer()
                } else if let weather = viewModel.currentLocationWeather { // Use weather from ViewModel
                    // --- Current Weather Display (Logic remains similar, uses 'weather') ---
                    Spacer()
                    Text("Current Weather")
                        .font(.title2).bold()
                        .padding(.bottom, 5)

                    Image(systemName: weather.currentWeather.symbolName)
                        .font(.system(size: 60))
                        .padding(.bottom, 5)

                    Text(weather.currentWeather.condition.description)
                        .font(.title3)

                    Text(weather.currentWeather.temperature.formatted())
                        .font(.system(size: 50, weight: .light))

                     Text("Feels like \(weather.currentWeather.apparentTemperature.formatted())")
                         .font(.caption)
                         .foregroundStyle(.secondary)

                    Spacer()

                    // --- WeatherKit Attribution (Fetch attribution in ViewModel if needed) ---
                    // For now, show static text or fetch attribution in ViewModel
                    Text("Weather data provided by Apple Weather")
                       .font(.caption2)
                       .foregroundStyle(.secondary)
                       .padding(.bottom, 5)
                    /* // Example if attribution were fetched in ViewModel
                     if let link = viewModel.attributionLink, let logoURL = viewModel.attributionLogo {
                         HStack { ... }
                     }
                     */

                } else {
                     // Show unavailable if not prompting, not loading, no error, location available, but no weather data
                     Spacer() 
                     ContentUnavailableView {
                         Label("No Weather Data", systemImage: "cloud.questionmark")
                     } description: {
                         Text("Weather data is currently unavailable for your location.")
                             .multilineTextAlignment(.center)
                     }
                     Spacer()
                }
            }
            .navigationTitle("Weather")
        }
    }
}


// --- Preview ---
#Preview {
    // Need to provide a WeatherViewModel instance for the preview
    WeatherView(viewModel: WeatherViewModel()) // Pass a new instance
        .environmentObject(LocationManager.shared)
        .environmentObject(CaminoAppState()) 
}

// --- Unchanged Helper Views ---
// WeatherDetailView can be kept or removed if no longer used
// struct WeatherDetailView: View { ... } 
// ... formatters ... 