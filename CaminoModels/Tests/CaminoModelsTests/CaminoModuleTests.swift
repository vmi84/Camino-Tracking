import XCTest
import CoreLocation
import AVFoundation
@testable import CaminoModels

final class CaminoModuleTests: XCTestCase {
    func testModuleBundle() {
        // Test bundle identifier
        XCTAssertNotNil(Bundle.main.bundleIdentifier)
        
        // Test resource bundle access
        let resourceBundle = Bundle.main
        XCTAssertNotNil(resourceBundle)
        
        // Test module structure
        let moduleURL = Bundle.main.bundleURL
        let fileManager = FileManager.default
        
        // Verify Managers directory exists
        let managersURL = moduleURL.appendingPathComponent("Sources/CaminoModels/Managers")
        var isDirectory: ObjCBool = false
        XCTAssertTrue(fileManager.fileExists(atPath: managersURL.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        
        // Verify Types directory exists
        let typesURL = moduleURL.appendingPathComponent("Sources/CaminoModels/Types")
        isDirectory = false
        XCTAssertTrue(fileManager.fileExists(atPath: typesURL.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        
        // Verify Resources directory exists
        let resourcesURL = moduleURL.appendingPathComponent("Sources/CaminoModels/Resources")
        isDirectory = false
        XCTAssertTrue(fileManager.fileExists(atPath: resourcesURL.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }
    
    func testDestinationModel() {
        let destinations = CaminoDestination.allDestinations
        
        // Test array is not empty
        XCTAssertFalse(destinations.isEmpty)
        
        // Test array contains correct number of destinations
        XCTAssertEqual(destinations.count, 34) // 0 to 33
        
        // Test first destination
        let firstDestination = destinations[0]
        XCTAssertEqual(firstDestination.day, 0)
        XCTAssertEqual(firstDestination.locationName, "Saint Jean Pied de Port")
        
        // Test last destination
        let lastDestination = destinations[33]
        XCTAssertEqual(lastDestination.day, 33)
        XCTAssertEqual(lastDestination.locationName, "Santiago de Compostela")
        
        // Test destination properties
        for destination in destinations {
            // Required fields should not be empty
            XCTAssertFalse(destination.locationName.isEmpty)
            XCTAssertFalse(destination.hotelName.isEmpty)
            XCTAssertFalse(destination.directions.isEmpty)
            XCTAssertFalse(destination.arrivalInstructions.isEmpty)
            XCTAssertFalse(destination.hotelDirections.isEmpty)
            
            // Coordinates should be valid
            XCTAssertTrue(destination.coordinate.latitude >= -90 && destination.coordinate.latitude <= 90)
            XCTAssertTrue(destination.coordinate.longitude >= -180 && destination.coordinate.longitude <= 180)
            
            // Distances should be positive
            XCTAssertGreaterThanOrEqual(destination.dailyDistance, 0)
            XCTAssertGreaterThanOrEqual(destination.cumulativeDistance, 0)
        }
    }
    
    func testLocationManager() {
        // Test singleton pattern
        let manager = LocationManager.shared
        XCTAssertNotNil(manager)
        XCTAssertTrue(manager === LocationManager.shared)
    }
    
    func testWeatherViewModel() {
        // Test initialization
        let viewModel = WeatherViewModel()
        XCTAssertNotNil(viewModel)
    }
} 