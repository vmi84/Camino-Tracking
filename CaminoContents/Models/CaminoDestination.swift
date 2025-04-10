//
//  CaminoDestination.swift
//  Camino
//
//  Created by Jeff White on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

// MARK: - CaminoDestination
struct CaminoDestination: Identifiable, Hashable {
    let id = UUID()
    let day: Int
    let date: Date
    let locationName: String
    let hotelName: String
    let coordinate: CLLocationCoordinate2D
    let actualRouteDistance: Double
    let cumulativeDistance: Double
    let content: String
    
    var dailyDistance: Double {
        if day == 0 { return 0 }
        guard let lastPoint = elevationProfile.last else { return 0 }
        return lastPoint.distance
    }
    
    var elevationProfile: [(distance: Double, elevation: Double)] {
        // Implementation of elevationProfile property
        []
    }
    
    // Computed property to format the date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Hashable conformance for CLLocationCoordinate2D
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(day)
        hasher.combine(locationName)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
    
    // Equatable conformance for CLLocationCoordinate2D
    static func == (lhs: CaminoDestination, rhs: CaminoDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    // Sample destinations with real Camino locations
    static var allDestinations: [CaminoDestination] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2023, month: 5, day: 15)) ?? Date()
        
        return [
            CaminoDestination(
                day: 1,
                date: calendar.date(byAdding: .day, value: 0, to: startDate) ?? Date(),
                locationName: "Saint-Jean-Pied-de-Port",
                hotelName: "Auberge du Pèlerin",
                coordinate: CLLocationCoordinate2D(latitude: 43.1634, longitude: -1.2366),
                actualRouteDistance: 0.0,
                cumulativeDistance: 0.0,
                content: "Starting point of the Camino Francés"
            ),
            CaminoDestination(
                day: 2,
                date: calendar.date(byAdding: .day, value: 1, to: startDate) ?? Date(),
                locationName: "Roncesvalles",
                hotelName: "Albergue de Roncesvalles",
                coordinate: CLLocationCoordinate2D(latitude: 43.0090, longitude: -1.3199),
                actualRouteDistance: 24.0,
                cumulativeDistance: 24.0,
                content: "First mountain pass crossing the Pyrenees"
            ),
            CaminoDestination(
                day: 3,
                date: calendar.date(byAdding: .day, value: 2, to: startDate) ?? Date(),
                locationName: "Zubiri",
                hotelName: "Albergue Zaldiko",
                coordinate: CLLocationCoordinate2D(latitude: 42.9304, longitude: -1.5023),
                actualRouteDistance: 21.5,
                cumulativeDistance: 45.5,
                content: "Cross the medieval 'Bridge of Rabies'"
            ),
            CaminoDestination(
                day: 4,
                date: calendar.date(byAdding: .day, value: 3, to: startDate) ?? Date(),
                locationName: "Pamplona",
                hotelName: "Casa Ibarrola",
                coordinate: CLLocationCoordinate2D(latitude: 42.8125, longitude: -1.6458),
                actualRouteDistance: 19.7,
                cumulativeDistance: 65.2,
                content: "Famous for the Running of the Bulls festival"
            ),
            CaminoDestination(
                day: 5,
                date: calendar.date(byAdding: .day, value: 4, to: startDate) ?? Date(),
                locationName: "Puente la Reina",
                hotelName: "Albergue Jakue",
                coordinate: CLLocationCoordinate2D(latitude: 42.6722, longitude: -1.8139),
                actualRouteDistance: 23.9,
                cumulativeDistance: 89.1,
                content: "Junction of the Aragonés and Francés routes"
            ),
            CaminoDestination(
                day: 6,
                date: calendar.date(byAdding: .day, value: 5, to: startDate) ?? Date(),
                locationName: "Estella",
                hotelName: "Hostal Cristina",
                coordinate: CLLocationCoordinate2D(latitude: 42.6714, longitude: -2.0320),
                actualRouteDistance: 21.8,
                cumulativeDistance: 110.9,
                content: "Historic town with the famous wine fountain"
            ),
            CaminoDestination(
                day: 7,
                date: calendar.date(byAdding: .day, value: 6, to: startDate) ?? Date(),
                locationName: "Los Arcos",
                hotelName: "Albergue Isaac Santiago",
                coordinate: CLLocationCoordinate2D(latitude: 42.5686, longitude: -2.1921),
                actualRouteDistance: 21.1,
                cumulativeDistance: 132.0,
                content: "Beautiful church of Santa María"
            ),
            CaminoDestination(
                day: 8,
                date: calendar.date(byAdding: .day, value: 7, to: startDate) ?? Date(),
                locationName: "Logroño",
                hotelName: "Hotel Sercotel Portales",
                coordinate: CLLocationCoordinate2D(latitude: 42.4669, longitude: -2.4449),
                actualRouteDistance: 27.7,
                cumulativeDistance: 159.7,
                content: "Capital of La Rioja wine region"
            ),
            CaminoDestination(
                day: 9,
                date: calendar.date(byAdding: .day, value: 8, to: startDate) ?? Date(),
                locationName: "Nájera",
                hotelName: "Albergue Nájera",
                coordinate: CLLocationCoordinate2D(latitude: 42.4156, longitude: -2.7288),
                actualRouteDistance: 28.9,
                cumulativeDistance: 188.6,
                content: "Red stone cliffs and Monastery of Santa María"
            ),
            CaminoDestination(
                day: 10,
                date: calendar.date(byAdding: .day, value: 9, to: startDate) ?? Date(),
                locationName: "Santo Domingo de la Calzada",
                hotelName: "Parador de Santo Domingo",
                coordinate: CLLocationCoordinate2D(latitude: 42.4434, longitude: -2.9558),
                actualRouteDistance: 21.0,
                cumulativeDistance: 209.6,
                content: "Famous for the legend of the hanged pilgrim"
            )
        ]
    }
    
    init(day: Int, date: Date, locationName: String, hotelName: String, coordinate: CLLocationCoordinate2D, actualRouteDistance: Double, cumulativeDistance: Double, content: String) {
        self.day = day
        self.date = date
        self.locationName = locationName
        self.hotelName = hotelName
        self.coordinate = coordinate
        self.actualRouteDistance = actualRouteDistance
        self.cumulativeDistance = cumulativeDistance
        self.content = content
    }
}

