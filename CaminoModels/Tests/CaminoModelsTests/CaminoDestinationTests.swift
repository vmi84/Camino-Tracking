import XCTest
@testable import CaminoModels

final class CaminoDestinationTests: XCTestCase {
    func testDestinationInitialization() {
        let destination = CaminoDestination.allDestinations.first!
        XCTAssertEqual(destination.day, 1)
        XCTAssertEqual(destination.locationName, "Saint-Jean-Pied-de-Port")
        XCTAssertEqual(destination.hotelName, "Villa Goxoki")
    }
} 