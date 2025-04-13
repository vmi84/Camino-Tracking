import Foundation

@MainActor
public class CaminoWeatherStore {
    public static let shared = CaminoWeatherStore()
    
    private let weatherDataKey = "cachedWeatherData"
    private let lastUpdatedKey = "weatherLastUpdated"
    
    private init() {}
    
    public func saveWeatherData(_ data: [String: Data]) {
        UserDefaults.standard.set(data, forKey: weatherDataKey)
        UserDefaults.standard.set(Date(), forKey: lastUpdatedKey)
    }
    
    public func loadWeatherData() -> [String: Data]? {
        return UserDefaults.standard.dictionary(forKey: weatherDataKey) as? [String: Data]
    }
    
    public func lastUpdated() -> Date? {
        return UserDefaults.standard.object(forKey: lastUpdatedKey) as? Date
    }
    
    // Check if we should refresh weather (more than 15 minutes old)
    public func shouldRefreshWeather() -> Bool {
        guard let lastUpdated = lastUpdated() else { return true }
        let fifteenMinutes: TimeInterval = 15 * 60
        return Date().timeIntervalSince(lastUpdated) > fifteenMinutes
    }
    
    // Clear all cached weather data
    public func clearCache() {
        UserDefaults.standard.removeObject(forKey: weatherDataKey)
        UserDefaults.standard.removeObject(forKey: lastUpdatedKey)
    }
} 