import SwiftUI
import WeatherKit
import CoreLocation
import CaminoModels

struct WeatherView: View {
    // @StateObject private var viewModel = WeatherViewModel() // Keep if needed for destination list later
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.colorScheme) var colorScheme

    @State private var weather: Weather?
    @State private var attributionLink: URL?
    @State private var attributionLogo: URL?
    @State private var weatherError: Error?
    @State private var isLoadingWeather = false

    // @State private var hasAttemptedRedirect = false // No longer needed

    var body: some View {
        NavigationView {
            VStack(spacing: 10) { // Added spacing
                if isLoadingWeather {
                    Spacer() // Push progress view to center
                    ProgressView("Fetching Weather...")
                        .padding()
                    Spacer()
                } else if let error = weatherError {
                    Spacer()
                    ContentUnavailableView {
                        Label("Weather Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("Could not load weather data.\n\(error.localizedDescription)")
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
                } else if let weather = weather {
                    // --- Current Weather Display ---
                    Spacer() // Push weather content towards center

                    Text("Current Weather") // Section Title
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

                    Spacer() // Push attribution down

                    // --- WeatherKit Attribution ---
                    if let link = attributionLink, let logoURL = attributionLogo {
                        HStack {
                            AsyncImage(url: logoURL) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView().frame(width: 20, height: 20) // Placeholder size
                            }
                            .scaledToFit()
                            .frame(height: 20) // Constrain logo height

                            Link("Weather data provided by Apple Weather", destination: link)
                                .font(.caption2)
                        }
                        .padding(.bottom, 5) // Add padding below attribution
                    } else {
                        // Fallback text if attribution isn't loaded yet or fails
                         Text("Weather data provided by Apple Weather")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 5)
                    }

                } else {
                     Spacer() // Push placeholder to center
                     ContentUnavailableView {
                         Label("No Weather Data", systemImage: "cloud.questionmark")
                     } description: {
                         Text("Weather data could not be loaded.")
                             .multilineTextAlignment(.center)
                     }
                     Spacer()
                }

                // --- Destination Weather List (Kept commented out for now) ---
                /*
                 Divider()

                 Text("Select a destination to view weather:")
                 .font(.headline)
                 .padding(.top)

                 List {
                 ForEach(viewModel.destinations) { destination in
                 VStack(alignment: .leading, spacing: 8) {
                 Text("Day \(destination.day): \(destination.locationName)")
                 .font(.headline)

                 Button(action: {
                 // TODO: Fetch weather for destination or navigate
                 // viewModel.openNativeWeatherApp(for: destination)
                 }) {
                 Label("View Weather", systemImage: "cloud.sun") // Changed label/icon
                 .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.bordered) // Changed style
                 }
                 .padding(.vertical, 4)
                 }
                 }
                 */
            }
            .navigationTitle("Weather")
            .task(id: locationManager.location) { // Use .location (Equatable)
                await fetchWeather()
            }
            // Removed .onAppear - task handles initial load
        }
    }

    // --- Fetch Weather Function ---
    private func fetchWeather() async {
        guard let location = locationManager.location else { // Use .location
            // Optionally set an error state or message here if needed
            print("WeatherView: Location not available.")
            self.weather = nil // Clear previous weather if location lost
            self.weatherError = nil // Clear previous error
            self.isLoadingWeather = false // Ensure loading stops
            return
        }

        isLoadingWeather = true
        weatherError = nil // Clear previous errors
        // print("WeatherView: Fetching weather for location: \(location)") // Debug print

        let weatherService = WeatherService.shared

        do {
            // Fetch weather data
            let weatherData = try await weatherService.weather(for: location)
            self.weather = weatherData
             // print("WeatherView: Successfully fetched weather.") // Debug print

            // Fetch attribution data
            let attribution = try await weatherService.attribution
            self.attributionLink = attribution.legalPageURL
            // Choose logo based on color scheme
            self.attributionLogo = colorScheme == .light ? attribution.combinedMarkLightURL : attribution.combinedMarkDarkURL
             // print("WeatherView: Successfully fetched attribution.") // Debug print

        } catch {
            print("WeatherView: Failed to fetch weather or attribution - \(error)")
            self.weatherError = error // Store the error
            self.weather = nil // Clear any stale weather data
        }
        isLoadingWeather = false // Mark loading as complete
    }
}


// --- Preview ---
#Preview {
    WeatherView()
        .environmentObject(LocationManager.shared) // Provide LocationManager
        .environmentObject(CaminoAppState()) // Keep if needed elsewhere
}

// --- Unchanged Helper Views ---
struct WeatherDetailView: View {
    let destination: CaminoDestination
    let weather: Weather

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text(destination.locationName)
                        .font(.title)

                    if !destination.hotelName.isEmpty {
                        Text(destination.hotelName)
                            .font(.subheadline)
                    }

                    HStack {
                        Text(weather.currentWeather.temperature.formatted())
                            .font(.largeTitle)

                        Spacer()

                        VStack {
                            Image(systemName: weather.currentWeather.symbolName)
                                .font(.largeTitle)
                            Text(weather.currentWeather.condition.description)
                                .font(.caption)
                        }
                    }
                    .padding()
                }
            }

            Section("Hourly Forecast") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(weather.hourlyForecast.prefix(24), id: \.date) { hourWeather in
                            VStack {
                                Text(hourlyFormatter.string(from: hourWeather.date))
                                    .font(.caption)

                                Image(systemName: hourWeather.symbolName)
                                    .font(.title2)

                                Text(hourWeather.temperature.formatted())
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }

            Section("Daily Forecast") {
                ForEach(weather.dailyForecast.prefix(7), id: \.date) { dayWeather in
                    HStack {
                        Text(dailyFormatter.string(from: dayWeather.date))
                            .frame(width: 100, alignment: .leading)

                        Image(systemName: dayWeather.symbolName)

                        Spacer()

                        Text(dayWeather.lowTemperature.formatted())
                        Text(" - ")
                        Text(dayWeather.highTemperature.formatted())
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Weather Details")
    }

    private let hourlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha" // Example: 3PM
        return formatter
    }()

    private let dailyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Example: Monday
        return formatter
    }()
}

struct WeatherDataCard: View {
    let destination: CaminoDestination
    let weather: Weather

    var body: some View {
        VStack(alignment: .leading) {
            Text("Day \(destination.day): \(destination.locationName)")
                .font(.headline)

            HStack {
                VStack(alignment: .leading) {
                    Text(weather.currentWeather.temperature.formatted())
                        .font(.title2)

                    Text(weather.currentWeather.condition.description)
                        .font(.subheadline)
                }

                Spacer()

                Image(systemName: weather.currentWeather.symbolName)
                    .font(.system(size: 40))
            }
        }
        .padding(.vertical, 5)
    }
} 