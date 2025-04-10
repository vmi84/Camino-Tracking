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
            ),
            // Adding the remaining destinations
            CaminoDestination(
                day: 11,
                date: calendar.date(byAdding: .day, value: 10, to: startDate) ?? Date(),
                locationName: "Belorado",
                hotelName: "Hostel Cuatro Cantones",
                coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910),
                actualRouteDistance: 22.7,
                cumulativeDistance: 232.3,
                content: "Medieval town with arcaded Plaza Mayor"
            ),
            CaminoDestination(
                day: 12,
                date: calendar.date(byAdding: .day, value: 11, to: startDate) ?? Date(),
                locationName: "San Juan de Ortega",
                hotelName: "Albergue San Juan",
                coordinate: CLLocationCoordinate2D(latitude: 42.3750, longitude: -3.4370),
                actualRouteDistance: 24.0,
                cumulativeDistance: 256.3,
                content: "Monastery founded by San Juan de Ortega"
            ),
            CaminoDestination(
                day: 13,
                date: calendar.date(byAdding: .day, value: 12, to: startDate) ?? Date(),
                locationName: "Burgos",
                hotelName: "Hotel Norte y Londres",
                coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7040),
                actualRouteDistance: 25.3,
                cumulativeDistance: 281.6,
                content: "Magnificent Gothic cathedral and medieval center"
            ),
            CaminoDestination(
                day: 14,
                date: calendar.date(byAdding: .day, value: 13, to: startDate) ?? Date(),
                locationName: "Hornillos del Camino",
                hotelName: "Albergue El Alfar",
                coordinate: CLLocationCoordinate2D(latitude: 42.3390, longitude: -3.9240),
                actualRouteDistance: 21.0,
                cumulativeDistance: 302.6,
                content: "Small village in the meseta (high plateau)"
            ),
            CaminoDestination(
                day: 15,
                date: calendar.date(byAdding: .day, value: 14, to: startDate) ?? Date(),
                locationName: "Castrojeriz",
                hotelName: "Albergue Casa Nostra",
                coordinate: CLLocationCoordinate2D(latitude: 42.2880, longitude: -4.1380),
                actualRouteDistance: 20.0,
                cumulativeDistance: 322.6,
                content: "Village built on a hill below castle ruins"
            ),
            CaminoDestination(
                day: 16,
                date: calendar.date(byAdding: .day, value: 15, to: startDate) ?? Date(),
                locationName: "Frómista",
                hotelName: "Hostal Camino de Santiago",
                coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060),
                actualRouteDistance: 25.0,
                cumulativeDistance: 347.6,
                content: "Home to the perfect Romanesque church of San Martín"
            ),
            CaminoDestination(
                day: 17,
                date: calendar.date(byAdding: .day, value: 16, to: startDate) ?? Date(),
                locationName: "Carrión de los Condes",
                hotelName: "Hotel Real Monasterio",
                coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030),
                actualRouteDistance: 19.5,
                cumulativeDistance: 367.1,
                content: "Historic town with impressive churches"
            ),
            CaminoDestination(
                day: 18,
                date: calendar.date(byAdding: .day, value: 17, to: startDate) ?? Date(),
                locationName: "Terradillos de los Templarios",
                hotelName: "Albergue Los Templarios",
                coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.9022),
                actualRouteDistance: 26.5,
                cumulativeDistance: 393.6,
                content: "Village with historical connections to the Knights Templar"
            ),
            CaminoDestination(
                day: 19,
                date: calendar.date(byAdding: .day, value: 18, to: startDate) ?? Date(),
                locationName: "El Burgo Ranero",
                hotelName: "Albergue Domenico Laffi",
                coordinate: CLLocationCoordinate2D(latitude: 42.4230, longitude: -5.2210),
                actualRouteDistance: 24.0,
                cumulativeDistance: 417.6,
                content: "Simple village in the middle of the meseta"
            ),
            CaminoDestination(
                day: 20,
                date: calendar.date(byAdding: .day, value: 19, to: startDate) ?? Date(),
                locationName: "León",
                hotelName: "Hotel Real Colegiata",
                coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710),
                actualRouteDistance: 37.0,
                cumulativeDistance: 454.6,
                content: "Major city with stunning cathedral and historic center"
            ),
            CaminoDestination(
                day: 21,
                date: calendar.date(byAdding: .day, value: 20, to: startDate) ?? Date(),
                locationName: "León",
                hotelName: "Hotel Real Colegiata",
                coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710),
                actualRouteDistance: 0.0,
                cumulativeDistance: 454.6,
                content: "Rest day to explore the city and recover"
            ),
            CaminoDestination(
                day: 22,
                date: calendar.date(byAdding: .day, value: 21, to: startDate) ?? Date(),
                locationName: "San Martín del Camino",
                hotelName: "Albergue Santa Ana",
                coordinate: CLLocationCoordinate2D(latitude: 42.4947, longitude: -5.7947),
                actualRouteDistance: 24.8,
                cumulativeDistance: 479.4,
                content: "Small village with several pilgrims' hostels"
            ),
            CaminoDestination(
                day: 23,
                date: calendar.date(byAdding: .day, value: 22, to: startDate) ?? Date(),
                locationName: "Astorga",
                hotelName: "Hotel Gaudi",
                coordinate: CLLocationCoordinate2D(latitude: 42.4580, longitude: -6.0530),
                actualRouteDistance: 23.7,
                cumulativeDistance: 503.1,
                content: "Roman city with Gaudí-designed Episcopal Palace"
            ),
            CaminoDestination(
                day: 24,
                date: calendar.date(byAdding: .day, value: 23, to: startDate) ?? Date(),
                locationName: "Rabanal del Camino",
                hotelName: "El Refugio",
                coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840),
                actualRouteDistance: 21.0,
                cumulativeDistance: 524.1,
                content: "Traditional mountain village before the climb to Cruz de Ferro"
            ),
            CaminoDestination(
                day: 25,
                date: calendar.date(byAdding: .day, value: 24, to: startDate) ?? Date(),
                locationName: "Ponferrada",
                hotelName: "Hotel Temple",
                coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5900),
                actualRouteDistance: 32.0,
                cumulativeDistance: 556.1,
                content: "City with impressive Templar Castle"
            ),
            CaminoDestination(
                day: 26,
                date: calendar.date(byAdding: .day, value: 25, to: startDate) ?? Date(),
                locationName: "Villafranca del Bierzo",
                hotelName: "Hospedería San Nicolás el Real",
                coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110),
                actualRouteDistance: 24.5,
                cumulativeDistance: 580.6,
                content: "Beautiful town with the 'Puerta del Perdón'"
            ),
            CaminoDestination(
                day: 27,
                date: calendar.date(byAdding: .day, value: 26, to: startDate) ?? Date(),
                locationName: "O Cebreiro",
                hotelName: "Albergue O Cebreiro",
                coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0020),
                actualRouteDistance: 28.5,
                cumulativeDistance: 609.1,
                content: "Mythical mountain village with pre-Roman pallozas"
            ),
            CaminoDestination(
                day: 28,
                date: calendar.date(byAdding: .day, value: 27, to: startDate) ?? Date(),
                locationName: "Triacastela",
                hotelName: "Albergue A Horta de Abel",
                coordinate: CLLocationCoordinate2D(latitude: 42.7560, longitude: -7.2340),
                actualRouteDistance: 21.0,
                cumulativeDistance: 630.1,
                content: "Small town at the base of O Cebreiro mountain"
            ),
            CaminoDestination(
                day: 29,
                date: calendar.date(byAdding: .day, value: 28, to: startDate) ?? Date(),
                locationName: "Sarria",
                hotelName: "Hotel Alfonso IX",
                coordinate: CLLocationCoordinate2D(latitude: 42.7810, longitude: -7.4140),
                actualRouteDistance: 18.7,
                cumulativeDistance: 648.8,
                content: "Popular starting point for many pilgrims (100km to Santiago)"
            ),
            CaminoDestination(
                day: 30,
                date: calendar.date(byAdding: .day, value: 29, to: startDate) ?? Date(),
                locationName: "Portomarín",
                hotelName: "Pousada de Portomarín",
                coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160),
                actualRouteDistance: 22.0,
                cumulativeDistance: 670.8,
                content: "Town rebuilt on a hillside after the original was flooded"
            ),
            CaminoDestination(
                day: 31,
                date: calendar.date(byAdding: .day, value: 30, to: startDate) ?? Date(),
                locationName: "Palas de Rei",
                hotelName: "A Parada das Bestas",
                coordinate: CLLocationCoordinate2D(latitude: 42.8730, longitude: -7.8690),
                actualRouteDistance: 24.0,
                cumulativeDistance: 694.8,
                content: "Town with strong connections to medieval Galician nobility"
            ),
            CaminoDestination(
                day: 32,
                date: calendar.date(byAdding: .day, value: 31, to: startDate) ?? Date(),
                locationName: "Melide",
                hotelName: "Posada Chiquitín",
                coordinate: CLLocationCoordinate2D(latitude: 42.9291, longitude: -7.9472),
                actualRouteDistance: 14.0,
                cumulativeDistance: 708.8,
                content: "Known for its octopus restaurants and ancient cruceiro"
            ),
            CaminoDestination(
                day: 33,
                date: calendar.date(byAdding: .day, value: 32, to: startDate) ?? Date(),
                locationName: "Arzúa",
                hotelName: "Pensión Domus Gallery",
                coordinate: CLLocationCoordinate2D(latitude: 42.9280, longitude: -8.1600),
                actualRouteDistance: 14.0,
                cumulativeDistance: 722.8,
                content: "Famous for its local cheese (Queixo de Arzúa)"
            ),
            CaminoDestination(
                day: 34,
                date: calendar.date(byAdding: .day, value: 33, to: startDate) ?? Date(),
                locationName: "O Pedrouzo",
                hotelName: "Albergue O Pedrouzo",
                coordinate: CLLocationCoordinate2D(latitude: 42.9080, longitude: -8.3670),
                actualRouteDistance: 19.0,
                cumulativeDistance: 741.8,
                content: "Final stop before Santiago de Compostela"
            ),
            CaminoDestination(
                day: 35,
                date: calendar.date(byAdding: .day, value: 34, to: startDate) ?? Date(),
                locationName: "Santiago de Compostela",
                hotelName: "Parador Hostal dos Reis Católicos",
                coordinate: CLLocationCoordinate2D(latitude: 42.8800, longitude: -8.5450),
                actualRouteDistance: 19.0,
                cumulativeDistance: 760.8,
                content: "Final destination with the magnificent Cathedral of Santiago"
            ),
            CaminoDestination(
                day: 36,
                date: calendar.date(byAdding: .day, value: 35, to: startDate) ?? Date(),
                locationName: "Finisterre",
                hotelName: "Hotel Finisterre",
                coordinate: CLLocationCoordinate2D(latitude: 42.9050, longitude: -9.2640),
                actualRouteDistance: 90.0, // By bus or additional walking days
                cumulativeDistance: 850.8,
                content: "Optional extension to the 'End of the Earth' on the Atlantic coast"
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

