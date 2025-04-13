import SwiftUI
import WeatherKit
import CoreLocation
import CaminoModels

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isLoading = false
    @State private var hasAttemptedRedirect = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .padding()
                        
                        Text("Loading Weather...")
                            .font(.headline)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "cloud.sun.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .padding()
                        
                        Text("Weather")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Get accurate weather forecasts for your Camino journey.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Open Apple Weather") {
                            redirectToAppleWeather()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                        
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
                                        viewModel.openNativeWeatherApp(for: destination)
                                    }) {
                                        Label("Open in Apple Weather", systemImage: "arrow.up.forward.app")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Button("Use Camino Weather (Requires WeatherKit)") {
                            Task {
                                isLoading = true
                                await viewModel.useCaminoWeather()
                                isLoading = false
                            }
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .padding()
                    }
                }
            }
            .navigationTitle("Weather")
            .task {
                // Try to open Apple Weather when view appears, but only once
                if !hasAttemptedRedirect {
                    hasAttemptedRedirect = true
                    redirectToAppleWeather()
                }
            }
            .onAppear {
                // Signal that the tab was selected
                viewModel.tabWasSelected()
            }
        }
    }
    
    private func redirectToAppleWeather() {
        // Don't set loading to true, just immediately redirect
        viewModel.openWeatherForCurrentLocation()
    }
    
    private func loadWeather() async {
        isLoading = true
        await viewModel.refreshWeather()
        isLoading = false
    }
}

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
        formatter.dateFormat = "ha"
        return formatter
    }()
    
    private let dailyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
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

#Preview {
    WeatherView()
} 