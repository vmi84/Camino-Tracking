import SwiftUI
import WeatherKit
import CoreLocation
import CaminoModels

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isLoading = true
    @State private var redirectedToAppleWeather = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .padding()
                        
                        Text("Opening Weather...")
                            .font(.headline)
                    }
                } else if viewModel.shouldShowWeatherAppPrompt {
                    VStack(spacing: 20) {
                        Image(systemName: "cloud.sun.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .padding()
                        
                        Text("Weather")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Redirecting to Apple Weather for the most accurate forecasts.")
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
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error loading weather data")
                            .font(.headline)
                            .padding()
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Try Again") {
                            Task {
                                await loadWeather()
                            }
                        }
                        .padding()
                        
                        Button("Switch to Apple Weather") {
                            redirectToAppleWeather()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom)
                    }
                } else if viewModel.weatherData.isEmpty {
                    VStack {
                        Text("No weather data available")
                            .font(.headline)
                            .padding()
                        
                        Button("Refresh") {
                            Task {
                                await loadWeather()
                            }
                        }
                        .padding()
                        
                        Button("Switch to Apple Weather") {
                            redirectToAppleWeather()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom)
                    }
                } else {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Switch to Apple Weather") {
                                redirectToAppleWeather()
                            }
                            .buttonStyle(.bordered)
                            .padding(.horizontal)
                        }
                        
                        List {
                            ForEach(viewModel.destinations) { destination in
                                if let weather = viewModel.weatherData[destination] {
                                    NavigationLink(destination: WeatherDetailView(destination: destination, weather: weather)) {
                                        WeatherDataCard(destination: destination, weather: weather)
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        await loadWeather()
                    }
                }
            }
            .navigationTitle("Weather")
            .task {
                // Immediately redirect to Apple Weather on first load
                if !redirectedToAppleWeather && viewModel.shouldShowWeatherAppPrompt {
                    redirectToAppleWeather()
                } else if !viewModel.shouldShowWeatherAppPrompt {
                    await loadWeather()
                }
                
                // Hide loading after a short delay in any case
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                }
            }
            .onAppear {
                if !redirectedToAppleWeather {
                    viewModel.tabWasSelected()
                }
            }
        }
    }
    
    private func redirectToAppleWeather() {
        redirectedToAppleWeather = true
        viewModel.shouldShowWeatherAppPrompt = true
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