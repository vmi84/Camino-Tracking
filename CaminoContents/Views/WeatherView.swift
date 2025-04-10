import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @EnvironmentObject private var locationManager: LocationManager
    @State private var isLoading = true
    @State private var lastUpdated: Date?
    @AppStorage("useCelsius") private var useCelsius = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    if isLoading {
                        // Loading placeholders
                        ForEach(0..<10) { _ in
                            loadingRowView
                        }
                    } else {
                        if let errorMessage = weatherViewModel.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.gray.opacity(0.2))
                        }
                        
                        // Weather destinations
                        ForEach(weatherViewModel.destinations, id: \.id) { destination in
                            // Break up the complex NavigationLink into smaller parts
                            destinationRow(for: destination)
                        }
                    }
                }
                
                if isLoading && weatherViewModel.weatherData.isEmpty {
                    ProgressView("Loading weather data...")
                        .padding()
                        .background(Color.primary.opacity(0.05).opacity(0.8))
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Weather")
            .refreshable {
                await refreshWeather()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let lastUpdated = lastUpdated {
                        Text("Updated: \(lastUpdated, formatter: timeFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .task {
                await refreshWeather()
            }
        }
    }
    
    // Break up complex views into smaller components
    private var loadingRowView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 12)
            }
            Spacer()
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
        }
        .padding(.vertical, 8)
    }
    
    // Create a separate function for destination rows to fix type-checking error
    private func destinationRow(for destination: CaminoDestination) -> some View {
        NavigationLink {
            // Destination view
            WeatherDetailView(
                destination: destination, 
                weather: weatherViewModel.weatherData[destination]
            )
        } label: {
            // Row content
            destinationRowContent(for: destination)
        }
    }
    
    // Extract row content to reduce complexity
    private func destinationRowContent(for destination: CaminoDestination) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Day \(destination.day)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(destination.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(destination.locationName)
                    .font(.headline)
                
                if let weather = weatherViewModel.weatherData[destination] {
                    Text(formatTemperature(weather.currentWeather.temperature))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    // Mock weather for current temperature (varies based on day number)
                    let mockTemp = (15 + (destination.day % 10))
                    Text(formatTemperature(Measurement(value: Double(mockTemp), unit: UnitTemperature.celsius)))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            weatherIcon(for: destination)
        }
        .padding(.vertical, 4)
    }
    
    // Extract weather icon to further reduce complexity
    private func weatherIcon(for destination: CaminoDestination) -> some View {
        Group {
            if let weather = weatherViewModel.weatherData[destination] {
                Image(systemName: weather.currentWeather.symbolName)
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
                    .frame(width: 32, height: 32)
            } else {
                // Mock weather icon (varies based on day number)
                let mockIcons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill"]
                let iconIndex = destination.day % mockIcons.count
                Image(systemName: mockIcons[iconIndex])
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
                    .frame(width: 32, height: 32)
            }
        }
    }
    
    // Add a helper method to format temperature respecting the user setting
    private func formatTemperature(_ temperature: Measurement<UnitTemperature>) -> String {
        if useCelsius {
            // Keep celsius
            return "\(Int(temperature.value.rounded()))°C"
        } else {
            // Convert to Fahrenheit
            let fahrenheit = temperature.converted(to: .fahrenheit)
            return "\(Int(fahrenheit.value.rounded()))°F"
        }
    }
    
    private func refreshWeather() async {
        isLoading = true
        await weatherViewModel.refreshWeather()
        lastUpdated = Date()
        isLoading = false
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }
}

struct WeatherDetailView: View {
    let destination: CaminoDestination
    let weather: Weather?
    @AppStorage("useCelsius") private var useCelsius = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with location and current conditions
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Day \(destination.day) - \(destination.formattedDate)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(destination.locationName)
                            .font(.title)
                            .bold()
                            
                        if let weather = weather {
                            Text(weather.currentWeather.condition.description)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        } else {
                            // Mock condition based on day number
                            let mockConditions = ["Sunny", "Partly Cloudy", "Cloudy", "Light Rain", "Rain"]
                            let conditionIndex = destination.day % mockConditions.count
                            Text(mockConditions[conditionIndex])
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if let weather = weather {
                        VStack(alignment: .trailing) {
                            Image(systemName: weather.currentWeather.symbolName)
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 56))
                            
                            Text(formatTemperature(weather.currentWeather.temperature))
                                .font(.system(size: 32, weight: .bold))
                        }
                    } else {
                        // Mock current weather
                        VStack(alignment: .trailing) {
                            let mockIcons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill"]
                            let iconIndex = destination.day % mockIcons.count
                            Image(systemName: mockIcons[iconIndex])
                                .symbolRenderingMode(.multicolor)
                                .font(.system(size: 56))
                            
                            let temp = (15 + (destination.day % 10))
                            Text(formatTemperature(Measurement(value: Double(temp), unit: UnitTemperature.celsius)))
                                .font(.system(size: 32, weight: .bold))
                        }
                    }
                }
                .padding(.horizontal)
                
                if let weather = weather {
                    // Current details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Conditions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                WeatherDataCard(
                                    title: "Feels Like",
                                    value: formatTemperature(weather.currentWeather.apparentTemperature),
                                    icon: "thermometer"
                                )
                                
                                WeatherDataCard(
                                    title: "Humidity",
                                    value: "\(Int(weather.currentWeather.humidity * 100))%",
                                    icon: "humidity"
                                )
                            }
                            
                            HStack {
                                WeatherDataCard(
                                    title: "Wind",
                                    value: weather.currentWeather.wind.speed.formatted(),
                                    icon: "wind"
                                )
                                
                                WeatherDataCard(
                                    title: "UV Index",
                                    value: "\(weather.currentWeather.uvIndex.value)",
                                    icon: "sun.max"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Hourly forecast
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hourly Forecast")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(weather.hourlyForecast.forecast.prefix(24).enumerated()), id: \.element.date) { index, hourly in
                                    VStack(spacing: 8) {
                                        Text(hourFormatter.string(from: hourly.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Image(systemName: hourly.symbolName)
                                            .symbolRenderingMode(.multicolor)
                                            .font(.title3)
                                        
                                        Text(formatTemperature(hourly.temperature))
                                            .font(.caption)
                                            .bold()
                                        
                                        if hourly.precipitationChance > 0 {
                                            Text("\(Int(hourly.precipitationChance * 100))%")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        } else {
                                            Text(" ")
                                                .font(.caption)
                                        }
                                    }
                                    .frame(width: 60)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Daily forecast
                    VStack(alignment: .leading, spacing: 8) {
                        Text("10-Day Forecast")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(Array(weather.dailyForecast.forecast.prefix(10).enumerated()), id: \.element.date) { index, daily in
                            HStack {
                                Text(dayFormatter.string(from: daily.date))
                                    .frame(width: 80, alignment: .leading)
                                
                                Image(systemName: daily.symbolName)
                                    .symbolRenderingMode(.multicolor)
                                    .frame(width: 32)
                                
                                Spacer()
                                
                                Text(formatTemperature(daily.lowTemperature, showUnit: false))
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                                
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 100, height: 6)
                                    
                                    Capsule()
                                        .fill(LinearGradient(colors: [.blue, .orange, .red], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 100, height: 6)
                                }
                                
                                Text(formatTemperature(daily.highTemperature, showUnit: false))
                                    .frame(width: 40, alignment: .trailing)
                                
                                if daily.precipitationChance > 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        Text("\(Int(daily.precipitationChance * 100))%")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 50, alignment: .trailing)
                                } else {
                                    Text(" ")
                                        .frame(width: 50)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.primary.opacity(0.05))
                        }
                    }
                    
                    // Weather attribution
                    HStack {
                        Spacer()
                        Text("Weather data provided by Apple WeatherKit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                } else {
                    // Mock Current details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Conditions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                let feelsLike = (14 + (destination.day % 10))
                                WeatherDataCard(
                                    title: "Feels Like",
                                    value: formatTemperature(Measurement(value: Double(feelsLike), unit: UnitTemperature.celsius)),
                                    icon: "thermometer"
                                )
                                
                                let humidity = 50 + (destination.day % 40)
                                WeatherDataCard(
                                    title: "Humidity",
                                    value: "\(humidity)%",
                                    icon: "humidity"
                                )
                            }
                            
                            HStack {
                                let windSpeed = 5 + (destination.day % 20)
                                WeatherDataCard(
                                    title: "Wind",
                                    value: "\(windSpeed) km/h",
                                    icon: "wind"
                                )
                                
                                let uvIndex = 1 + (destination.day % 10)
                                WeatherDataCard(
                                    title: "UV Index",
                                    value: "\(uvIndex)",
                                    icon: "sun.max"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Mock Hourly forecast
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hourly Forecast")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Create 24 mock hourly forecasts
                                ForEach(0..<24, id: \.self) { hour in
                                    let mockTime = Calendar.current.date(
                                        bySettingHour: (Calendar.current.component(.hour, from: Date()) + hour) % 24,
                                        minute: 0,
                                        second: 0,
                                        of: Date()
                                    ) ?? Date()
                                    
                                    let icons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill"]
                                    let iconIndex = (destination.day + hour) % icons.count
                                    
                                    let baseTemp = 15 + (destination.day % 10)
                                    let hourTemp = baseTemp + Int(sin(Double(hour) * 0.5) * 5)
                                    
                                    let rainChance = (hour + destination.day) % 10 == 0 ? 30 : 0
                                    
                                    VStack(spacing: 8) {
                                        Text(hourFormatter.string(from: mockTime))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Image(systemName: icons[iconIndex])
                                            .symbolRenderingMode(.multicolor)
                                            .font(.title3)
                                        
                                        Text(formatTemperature(Measurement(value: Double(hourTemp), unit: UnitTemperature.celsius)))
                                            .font(.caption)
                                            .bold()
                                        
                                        if rainChance > 0 {
                                            Text("\(rainChance)%")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        } else {
                                            Text(" ")
                                                .font(.caption)
                                        }
                                    }
                                    .frame(width: 60)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Mock 10-Day forecast
                    VStack(alignment: .leading, spacing: 8) {
                        Text("10-Day Forecast")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Create 10 days of mock forecasts
                        ForEach(0..<10, id: \.self) { dayOffset in
                            let mockDate = Calendar.current.date(
                                byAdding: .day,
                                value: dayOffset,
                                to: Date()
                            ) ?? Date()
                            
                            let icons = ["sun.max.fill", "cloud.sun.fill", "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill"]
                            let iconIndex = (destination.day + dayOffset) % icons.count
                            
                            let baseTemp = 15 + (destination.day % 10)
                            let lowTemp = baseTemp - 5 + ((destination.day + dayOffset) % 3)
                            let highTemp = baseTemp + 5 + ((destination.day + dayOffset) % 4)
                            
                            let rainChance = (dayOffset + destination.day) % 10 == 0 ? 30 : 0
                            
                            HStack {
                                Text(dayFormatter.string(from: mockDate))
                                    .frame(width: 80, alignment: .leading)
                                
                                Image(systemName: icons[iconIndex])
                                    .symbolRenderingMode(.multicolor)
                                    .frame(width: 32)
                                
                                Spacer()
                                
                                Text(formatTemperature(Measurement(value: Double(lowTemp), unit: UnitTemperature.celsius), showUnit: false))
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, alignment: .trailing)
                                
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 100, height: 6)
                                    
                                    Capsule()
                                        .fill(LinearGradient(colors: [.blue, .orange, .red], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 100, height: 6)
                                }
                                
                                Text(formatTemperature(Measurement(value: Double(highTemp), unit: UnitTemperature.celsius), showUnit: false))
                                    .frame(width: 40, alignment: .trailing)
                                
                                if rainChance > 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                        Text("\(rainChance)%")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 50, alignment: .trailing)
                                } else {
                                    Text(" ")
                                        .frame(width: 50)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.primary.opacity(0.05))
                        }
                    }
                    
                    // Sample data notice
                    HStack {
                        Spacer()
                        Text("Sample weather data - not live")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Weather Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper method to format temperature respecting the user setting
    private func formatTemperature(_ temperature: Measurement<UnitTemperature>, showUnit: Bool = true) -> String {
        if useCelsius {
            return showUnit ? "\(Int(temperature.value.rounded()))°C" : "\(Int(temperature.value.rounded()))°"
        } else {
            let fahrenheit = temperature.converted(to: .fahrenheit)
            return showUnit ? "\(Int(fahrenheit.value.rounded()))°F" : "\(Int(fahrenheit.value.rounded()))°"
        }
    }
    
    private var hourFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
}

struct WeatherDataCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    WeatherView()
        .environmentObject(LocationManager.shared)
} 