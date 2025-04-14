import SwiftUI
import WeatherKit
import CoreLocation
#if canImport(CaminoModels)
import CaminoModels
#endif

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
                    
                    if let hotelName = destination.hotelName, !hotelName.isEmpty {
                        Text(hotelName)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("25°C")
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        VStack {
                            Image(systemName: "sun.max.fill")
                                .font(.largeTitle)
                            Text("Sunny")
                                .font(.caption)
                        }
                    }
                    .padding()
                }
            }
            
            Section("Hourly Forecast") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<24, id: \.self) { hour in
                            let hourText = "\(hour % 12 == 0 ? 12 : hour % 12)\(hour < 12 ? "AM" : "PM")"
                            VStack {
                                Text(hourText)
                                    .font(.caption)
                                
                                Image(systemName: "sun.max.fill")
                                    .font(.title2)
                                
                                Text("25°")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
            
            Section("Daily Forecast") {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                    let calendar = Calendar.current
                    let today = calendar.component(.weekday, from: Date()) - 1 // 0-based index
                    let dayName = dayNames[(today + dayOffset) % 7]
                    
                    HStack {
                        Text(dayName)
                            .frame(width: 100, alignment: .leading)
                        
                        Image(systemName: "sun.max.fill")
                        
                        Spacer()
                        
                        Text("20°")
                        Text(" - ")
                        Text("25°")
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
                    Text("25°C")
                        .font(.title2)
                    
                    Text("Sunny")
                        .font(.subheadline)
                }
                
                Spacer()
                
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 40))
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    WeatherView()
} 