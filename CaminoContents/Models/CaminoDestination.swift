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
struct CaminoDestination: Identifiable {
    let id = UUID()
    let day: Int
    let locationName: String
    let hotelName: String
    let coordinate: CLLocationCoordinate2D
    let content: String
    let date: Date
    let elevationProfile: [(distance: Double, elevation: Double)]
    
    var dailyDistance: Double {
        if day == 0 { return 0 }
        guard let lastPoint = elevationProfile.last else { return 0 }
        return lastPoint.distance
    }
    
    var cumulativeDistance: Double {
        if day == 0 { return 0 }
        let allDestinations = Self.allDestinations
        let currentIndex = allDestinations.firstIndex { $0.id == self.id } ?? 0
        return allDestinations[0...currentIndex].reduce(0) { $0 + $1.dailyDistance }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }
    
    static let allDestinations: [CaminoDestination] = [
        CaminoDestination(
            day: 0,
            locationName: "Saint-Jean-Pied-de-Port",
            hotelName: "Villa Goxoki",
            coordinate: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386),
            content: """
            Route Information:
            • Starting point of the Camino Frances
            • A beautiful medieval town with all services available
            • Key stops: Porte Saint-Jacques, Rue de la Citadelle
            • Highlights: Medieval town, Porte Saint-Jacques gate
            
            Lodging:
            Villa Goxoki - Comfortable guesthouse in the heart of the old town
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 1))!,
            elevationProfile: [
                (0, 180), (1, 200), (2, 220), (3, 250), (4, 280), (5, 300)
            ]
        ),
        CaminoDestination(
            day: 1,
            locationName: "Saint-Jean-Pied-de-Port to Roncesvalles",
            hotelName: "Hotel Roncesvalles",
            coordinate: CLLocationCoordinate2D(latitude: 43.0093, longitude: -1.3192),
            content: """
            Route Information:
            • Distance: 23.9 km
            • Elevation: ↑ 1282m ↓ 504m
            • Two options: Via Orisson (tougher, scenic) or Via Valcarlos (easier, safer)
            • Start at Saint-Jean-Pied-de-Port, cross the medieval bridge over the River Nive
            • Key stops: Orisson (7.6 km, bar/restaurant), Collado de Lepoeder (20.2 km)
            • Highlights: Collegiate Church of Santa María
            
            Lodging:
            Hotel Roncesvalles - Standard double room with breakfast included
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 2))!,
            elevationProfile: [
                (0, 180), (5, 400), (10, 800), (15, 1200), (20, 1400), (23.9, 950)
            ]
        ),
        CaminoDestination(
            day: 2,
            locationName: "Roncesvalles to Zubiri",
            hotelName: "Hosteria de Zubiri",
            coordinate: CLLocationCoordinate2D(latitude: 42.9321, longitude: -1.5036),
            content: """
            Route Information:
            • Distance: 21.5 km
            • Elevation: ↑ 217m ↓ 633m
            • Descend through the Navarrese Pyrenees, passing alpine meadows and beech forests
            • Key stops: Burguete (2.8 km, bars/stores), Espinal (6.5 km, bar/store), Bizkarreta (9.8 km)
            • Highlights: Bridge of Rabies (14th century)
            
            Lodging:
            Hosteria de Zubiri - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 3))!,
            elevationProfile: [
                (0, 950), (5, 800), (10, 600), (15, 400), (20, 350), (21.5, 320)
            ]
        ),
        CaminoDestination(
            day: 3,
            locationName: "Zubiri to Pamplona",
            hotelName: "Hotel A Pamplona",
            coordinate: CLLocationCoordinate2D(latitude: 42.8110, longitude: -1.6450),
            content: """
            Route Information:
            • Distance: 21.8 km
            • Elevation: ↑ 72m ↓ 148m
            • A flat stage along the Arga River, ending in the vibrant city of Pamplona
            • Key stops: Larrasoaña (5.5 km, bar/store), Trinidad de Arre (16.0 km), Villava (16.4 km, all services)
            • Highlights: Old Town, Cathedral of Santa María, San Fermín streets
            
            Lodging:
            Hotel A Pamplona - Modern hotel in the city center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 4))!,
            elevationProfile: [
                (0, 320), (5, 300), (10, 280), (15, 260), (20, 250), (21.8, 240)
            ]
        ),
        CaminoDestination(
            day: 4,
            locationName: "Pamplona to Puente la Reina",
            hotelName: "Hotel Jakue",
            coordinate: CLLocationCoordinate2D(latitude: 42.6723, longitude: -1.8154),
            content: """
            Route Information:
            • Distance: 23.6 km
            • Elevation: ↑ 419m ↓ 523m
            • Climb the Sierra del Perdón (wind farm, great views) and descend to Puente la Reina
            • Key stops: Cizur Menor (4.9 km, all services), Zariquiegui (11.0 km, store), Alto del Perdón (13.3 km, store)
            • Highlights: Romanesque bridge, Church of Santiago
            
            Lodging:
            Hotel Jakue - Comfortable hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 5))!,
            elevationProfile: [
                (0, 240), (4.9, 300), (11, 400), (13.3, 500)
            ]
        ),
        CaminoDestination(
            day: 5,
            locationName: "Puente la Reina to Estella",
            hotelName: "Hotel Tximista",
            coordinate: CLLocationCoordinate2D(latitude: 42.6705, longitude: -2.0320),
            content: """
            Route Information:
            • Distance: 21.8 km
            • Elevation: ↑ 352m ↓ 272m
            • A scenic stage through vineyards and rural Navarra, altered by the A-12 highway
            • Key stops: Mañeru (4.4 km, bar/restaurant), Cirauqui (11.0 km, all services), Lorca (13.2 km, bar/restaurant)
            • Highlights: Vineyards of Navarra, Medieval town center
            
            Lodging:
            Hotel Tximista - Modern hotel with spa facilities
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 6))!,
            elevationProfile: [
                (0, 272), (4.4, 300), (11, 400), (13.2, 500)
            ]
        ),
        CaminoDestination(
            day: 6,
            locationName: "Estella",
            hotelName: "Alda Estella Hostal",
            coordinate: CLLocationCoordinate2D(latitude: 42.6708, longitude: -2.0295),
            content: """
            Route Information:
            • Rest day in Estella
            • Explore the medieval town center
            • Visit the Church of San Pedro de la Rúa
            • Highlights: Romanesque architecture, Pilgrim's fountain
            
            Lodging:
            Alda Estella Hostal - Comfortable accommodation in the town center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 7))!,
            elevationProfile: []
        ),
        CaminoDestination(
            day: 7,
            locationName: "Los Arcos",
            hotelName: "Pensión Los Arcos",
            coordinate: CLLocationCoordinate2D(latitude: 42.5715, longitude: -2.1918),
            content: """
            Route Information:
            • Distance: 21.0 km
            • Elevation: ↑ 150m ↓ 200m
            • Rolling hills through vineyards and olive groves
            • Key stops: Villamayor de Monjardín (5.5 km, bar/store)
            • Highlights: Church of Santa María de los Arcos
            
            Lodging:
            Pensión Los Arcos - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 8))!,
            elevationProfile: [
                (0, 150), (5.5, 200)
            ]
        ),
        CaminoDestination(
            day: 8,
            locationName: "Logroño",
            hotelName: "Hotel Ciudad de Logroño",
            coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450),
            content: """
            Route Information:
            • Distance: 28.0 km
            • Elevation: ↑ 200m ↓ 250m
            • Enter the Rioja wine region
            • Key stops: Viana (8.5 km, all services)
            • Highlights: Cathedral of Santa María de la Redonda, Calle Laurel (tapas street)
            
            Lodging:
            Hotel Ciudad de Logroño - Modern hotel in the city center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 9))!,
            elevationProfile: [
                (0, 200), (8.5, 250)
            ]
        ),
        CaminoDestination(
            day: 9,
            locationName: "Nájera",
            hotelName: "Hotel Duques de Nájera",
            coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7290),
            content: """
            Route Information:
            • Distance: 30.0 km
            • Elevation: ↑ 300m ↓ 350m
            • Follow the Najerilla River valley
            • Key stops: Navarrete (8.0 km, all services)
            • Highlights: Monastery of Santa María la Real
            
            Lodging:
            Hotel Duques de Nájera - Comfortable hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10))!,
            elevationProfile: [
                (0, 300), (8, 350)
            ]
        ),
        CaminoDestination(
            day: 10,
            locationName: "Santo Domingo de la Calzada",
            hotelName: "El Molino de Floren",
            coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530),
            content: """
            Route Information:
            • Distance: 21.0 km
            • Elevation: ↑ 150m ↓ 200m
            • Cross the Oja River valley
            • Key stops: Azofra (6.5 km, bar/store)
            • Highlights: Cathedral with live chickens, Medieval bridge
            
            Lodging:
            El Molino de Floren - Converted mill with modern amenities
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 11))!,
            elevationProfile: [
                (0, 150), (6.5, 200)
            ]
        ),
        CaminoDestination(
            day: 11,
            locationName: "Belorado",
            hotelName: "Hostel Punto B",
            coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910),
            content: """
            Route Information:
            • Distance: 22.5 km
            • Elevation: ↑ 200m ↓ 250m
            • Enter Castilla y León region
            • Key stops: Grañón (5.5 km, bar/store)
            • Highlights: Church of Santa María
            
            Lodging:
            Hostel Punto B - Modern hostel with shared facilities
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
            elevationProfile: [
                (0, 200), (5.5, 250)
            ]
        ),
        CaminoDestination(
            day: 12,
            locationName: "San Juan de Ortega",
            hotelName: "Hotel Rural la Iglesia",
            coordinate: CLLocationCoordinate2D(latitude: 42.3760, longitude: -3.4370),
            content: """
            Route Information:
            • Distance: 24.0 km
            • Elevation: ↑ 300m ↓ 350m
            • Cross the Montes de Oca
            • Key stops: Villafranca Montes de Oca (8.0 km, bar/store)
            • Highlights: Romanesque church, Pilgrim's fountain
            
            Lodging:
            Hotel Rural la Iglesia - Rural hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 13))!,
            elevationProfile: [
                (0, 300), (8, 350)
            ]
        ),
        CaminoDestination(
            day: 13,
            locationName: "Burgos",
            hotelName: "Hotel Cordón",
            coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7010),
            content: """
            Route Information:
            • Distance: 26.0 km
            • Elevation: ↑ 250m ↓ 300m
            • Enter the historic city of Burgos
            • Key stops: Atapuerca (10.0 km, bar/store)
            • Highlights: Cathedral of Burgos, Old Town
            
            Lodging:
            Hotel Cordón - Historic hotel in the city center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 14))!,
            elevationProfile: [
                (0, 250), (10, 300)
            ]
        ),
        CaminoDestination(
            day: 14,
            locationName: "Hornillos del Camino",
            hotelName: "De Sol A Sol",
            coordinate: CLLocationCoordinate2D(latitude: 42.3130, longitude: -4.0460),
            content: """
            Route Information:
            • Distance: 20.0 km
            • Elevation: ↑ 150m ↓ 200m
            • Cross the Meseta plateau
            • Key stops: Rabé de las Calzadas (5.0 km, bar/store)
            • Highlights: Roman road, Medieval bridge
            
            Lodging:
            De Sol A Sol - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 15))!,
            elevationProfile: [
                (0, 150), (5, 200)
            ]
        ),
        CaminoDestination(
            day: 15,
            locationName: "Castrojeriz",
            hotelName: "A Cien Leguas",
            coordinate: CLLocationCoordinate2D(latitude: 42.2900, longitude: -4.1380),
            content: """
            Route Information:
            • Distance: 19.0 km
            • Elevation: ↑ 100m ↓ 150m
            • Follow the ancient Roman road
            • Key stops: Hontanas (10.0 km, bar/store)
            • Highlights: Castle ruins, Collegiate church
            
            Lodging:
            A Cien Leguas - Comfortable guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 16))!,
            elevationProfile: [
                (0, 100), (10, 150)
            ]
        ),
        CaminoDestination(
            day: 16,
            locationName: "Frómista",
            hotelName: "Eco Hotel Doña Mayor",
            coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060),
            content: """
            Route Information:
            • Distance: 25.0 km
            • Elevation: ↑ 200m ↓ 250m
            • Cross the Pisuerga River
            • Key stops: Itero de la Vega (12.0 km, bar/store)
            • Highlights: Church of San Martín
            
            Lodging:
            Eco Hotel Doña Mayor - Eco-friendly hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 17))!,
            elevationProfile: [
                (0, 200), (12, 250)
            ]
        ),
        CaminoDestination(
            day: 17,
            locationName: "Carrión de los Condes",
            hotelName: "Hostal La Corte",
            coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030),
            content: """
            Route Information:
            • Distance: 19.0 km
            • Elevation: ↑ 100m ↓ 150m
            • Follow the ancient Roman road
            • Key stops: Villalcázar de Sirga (6.0 km, bar/store)
            • Highlights: Monastery of San Zoilo
            
            Lodging:
            Hostal La Corte - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 18))!,
            elevationProfile: [
                (0, 100), (6, 150)
            ]
        ),
        CaminoDestination(
            day: 18,
            locationName: "Calzadilla de la Cueza",
            hotelName: "Hostal Camino Real",
            coordinate: CLLocationCoordinate2D(latitude: 42.3630, longitude: -4.8860),
            content: """
            Route Information:
            • Distance: 17.0 km
            • Elevation: ↑ 50m ↓ 100m
            • Cross the Meseta plateau
            • Key stops: Ledigos (10.0 km, bar/store)
            • Highlights: Roman road
            
            Lodging:
            Hostal Camino Real - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 19))!,
            elevationProfile: [
                (0, 50), (10, 100)
            ]
        ),
        CaminoDestination(
            day: 19,
            locationName: "Sahagún",
            hotelName: "Hostal Domus Viatoris",
            coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290),
            content: """
            Route Information:
            • Distance: 22.0 km
            • Elevation: ↑ 100m ↓ 150m
            • Cross the Cea River
            • Key stops: Terradillos de los Templarios (8.0 km, bar/store)
            • Highlights: Church of San Tirso
            
            Lodging:
            Hostal Domus Viatoris - Comfortable guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 20))!,
            elevationProfile: [
                (0, 100), (8, 150)
            ]
        ),
        CaminoDestination(
            day: 20,
            locationName: "El Burgo Ranero",
            hotelName: "Hotel Castillo El Burgo",
            coordinate: CLLocationCoordinate2D(latitude: 42.4220, longitude: -5.2200),
            content: """
            Route Information:
            • Distance: 19.0 km
            • Elevation: ↑ 50m ↓ 100m
            • Follow the ancient Roman road
            • Key stops: Bercianos del Real Camino (10.0 km, bar/store)
            • Highlights: Church of San Pedro
            
            Lodging:
            Hotel Castillo El Burgo - Comfortable hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 21))!,
            elevationProfile: [
                (0, 50), (10, 100)
            ]
        ),
        CaminoDestination(
            day: 21,
            locationName: "Mansilla de las Mulas",
            hotelName: "Alberguería del Camino",
            coordinate: CLLocationCoordinate2D(latitude: 42.4990, longitude: -5.4170),
            content: """
            Route Information:
            • Distance: 18.0 km
            • Elevation: ↑ 50m ↓ 100m
            • Cross the Esla River
            • Key stops: Reliegos (12.0 km, bar/store)
            • Highlights: Medieval walls
            
            Lodging:
            Alberguería del Camino - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 22))!,
            elevationProfile: [
                (0, 50), (12, 100)
            ]
        ),
        CaminoDestination(
            day: 22,
            locationName: "León",
            hotelName: "Hotel Alda Vía León",
            coordinate: CLLocationCoordinate2D(latitude: 42.5990, longitude: -5.5710),
            content: """
            Route Information:
            • Distance: 18.0 km
            • Elevation: ↑ 50m ↓ 100m
            • Enter the historic city of León
            • Key stops: Arcahueja (8.0 km, bar/store)
            • Highlights: Cathedral, Old Town
            
            Lodging:
            Hotel Alda Vía León - Modern hotel in the city center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 23))!,
            elevationProfile: [
                (0, 50), (8, 100)
            ]
        ),
        CaminoDestination(
            day: 23,
            locationName: "Villadangos del Páramo",
            hotelName: "TBD",
            coordinate: CLLocationCoordinate2D(latitude: 42.5160, longitude: -5.7660),
            content: """
            Route Information:
            • Distance: 20.0 km
            • Elevation: ↑ 100m ↓ 150m
            • Cross the Páramo Leonés
            • Key stops: Valverde de la Virgen (10.0 km, bar/store)
            • Highlights: Church of Santiago
            
            Lodging:
            To be determined
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 24))!,
            elevationProfile: []
        ),
        CaminoDestination(
            day: 24,
            locationName: "Chozas de Abajo",
            hotelName: "Albergue San Antonio",
            coordinate: CLLocationCoordinate2D(latitude: 42.5060, longitude: -5.6830),
            content: """
            Route Information:
            • Distance: 15.0 km
            • Elevation: ↑ 50m ↓ 100m
            • Follow the ancient Roman road
            • Key stops: San Miguel del Camino (8.0 km, bar/store)
            • Highlights: Church of San Antonio
            
            Lodging:
            Albergue San Antonio - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 25))!,
            elevationProfile: [
                (0, 50), (8, 100)
            ]
        ),
        CaminoDestination(
            day: 25,
            locationName: "Astorga",
            hotelName: "Hotel Astur Plaza",
            coordinate: CLLocationCoordinate2D(latitude: 42.4570, longitude: -6.0560),
            content: """
            Route Information:
            • Distance: 16.0 km
            • Elevation: ↑ 100m ↓ 150m
            • Enter the historic city of Astorga
            • Key stops: Valdeviejas (8.0 km, bar/store)
            • Highlights: Episcopal Palace, Cathedral
            
            Lodging:
            Hotel Astur Plaza - Comfortable hotel in the city center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 26))!,
            elevationProfile: [
                (0, 100), (8, 150)
            ]
        ),
        CaminoDestination(
            day: 26,
            locationName: "Rabanal del Camino",
            hotelName: "Hotel Rural Casa Indie",
            coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840),
            content: """
            Route Information:
            • Distance: 20.0 km
            • Elevation: ↑ 300m ↓ 350m
            • Begin ascent into the Montes de León
            • Key stops: Santa Catalina de Somoza (10.0 km, bar/store)
            • Highlights: Church of Santa María
            
            Lodging:
            Hotel Rural Casa Indie - Rural hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 27))!,
            elevationProfile: [
                (0, 300), (10, 350)
            ]
        ),
        CaminoDestination(
            day: 27,
            locationName: "Ponferrada",
            hotelName: "Hotel El Castillo",
            coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5960),
            content: """
            Route Information:
            • Distance: 32.0 km
            • Elevation: ↑ 400m ↓ 450m
            • Cross the highest point (Cruz de Ferro)
            • Key stops: Molinaseca (8.0 km, bar/store)
            • Highlights: Templar Castle
            
            Lodging:
            Hotel El Castillo - Comfortable hotel near the castle
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 28))!,
            elevationProfile: [
                (0, 400), (8, 450)
            ]
        ),
        CaminoDestination(
            day: 28,
            locationName: "Villafranca del Bierzo",
            hotelName: "Hostal Tres Campanas",
            coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110),
            content: """
            Route Information:
            • Distance: 24.0 km
            • Elevation: ↑ 300m ↓ 350m
            • Enter the Bierzo region
            • Key stops: Cacabelos (8.0 km, bar/store)
            • Highlights: Church of Santiago
            
            Lodging:
            Hostal Tres Campanas - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 29))!,
            elevationProfile: [
                (0, 300), (8, 350)
            ]
        ),
        CaminoDestination(
            day: 29,
            locationName: "O Cebreiro",
            hotelName: "Casa Navarro",
            coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0420),
            content: """
            Route Information:
            • Distance: 28.0 km
            • Elevation: ↑ 800m ↓ 850m
            • Steep climb into Galicia
            • Key stops: La Faba (8.0 km, bar/store)
            • Highlights: Traditional pallozas, Church of Santa María
            
            Lodging:
            Casa Navarro - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 30))!,
            elevationProfile: [
                (0, 800), (8, 850)
            ]
        ),
        CaminoDestination(
            day: 30,
            locationName: "Triacastela",
            hotelName: "Complexo Xacobeo",
            coordinate: CLLocationCoordinate2D(latitude: 42.7550, longitude: -7.2370),
            content: """
            Route Information:
            • Distance: 21.0 km
            • Elevation: ↑ 200m ↓ 250m
            • Descend through Galician hills
            • Key stops: Hospital da Condesa (8.0 km, bar/store)
            • Highlights: Church of Santiago
            
            Lodging:
            Complexo Xacobeo - Modern hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 31))!,
            elevationProfile: [
                (0, 200), (8, 250)
            ]
        ),
        CaminoDestination(
            day: 31,
            locationName: "Sarria",
            hotelName: "Hotel Alfonso IX",
            coordinate: CLLocationCoordinate2D(latitude: 42.7770, longitude: -7.4140),
            content: """
            Route Information:
            • Distance: 18.5 km
            • Elevation: ↑ 150m ↓ 200m
            • Popular starting point for pilgrims
            • Key stops: Samos (8.0 km, bar/store)
            • Highlights: Monastery of Samos
            
            Lodging:
            Hotel Alfonso IX - Comfortable hotel in the town center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1))!,
            elevationProfile: [
                (0, 150), (8, 200)
            ]
        ),
        CaminoDestination(
            day: 32,
            locationName: "Portomarín",
            hotelName: "Hotel Pousada de Portomarín",
            coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160),
            content: """
            Route Information:
            • Distance: 22.2 km
            • Elevation: ↑ 200m ↓ 250m
            • Cross the Miño River
            • Key stops: Mercadoiro (12.0 km, bar/store)
            • Highlights: Church of San Juan
            
            Lodging:
            Hotel Pousada de Portomarín - Modern hotel with river views
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 2))!,
            elevationProfile: [
                (0, 200), (12, 250)
            ]
        ),
        CaminoDestination(
            day: 33,
            locationName: "Palas de Rei",
            hotelName: "Hotel Casa Benilde",
            coordinate: CLLocationCoordinate2D(latitude: 42.8740, longitude: -7.8680),
            content: """
            Route Information:
            • Distance: 24.8 km
            • Elevation: ↑ 250m ↓ 300m
            • Cross the Serra de Ligonde
            • Key stops: Gonzar (8.0 km, bar/store)
            • Highlights: Church of San Tirso
            
            Lodging:
            Hotel Casa Benilde - Traditional guesthouse with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 3))!,
            elevationProfile: [
                (0, 250), (8, 300)
            ]
        ),
        CaminoDestination(
            day: 34,
            locationName: "Arzúa",
            hotelName: "Hotel Arzúa",
            coordinate: CLLocationCoordinate2D(latitude: 42.9270, longitude: -8.1930),
            content: """
            Route Information:
            • Distance: 28.5 km
            • Elevation: ↑ 300m ↓ 350m
            • Enter the province of A Coruña
            • Key stops: Melide (14.0 km, all services)
            • Highlights: Church of Santiago
            
            Lodging:
            Hotel Arzúa - Comfortable hotel in the town center
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 4))!,
            elevationProfile: [
                (0, 300), (14, 350)
            ]
        ),
        CaminoDestination(
            day: 35,
            locationName: "Pedrouzo",
            hotelName: "Hotel O Acivro",
            coordinate: CLLocationCoordinate2D(latitude: 42.9090, longitude: -8.3730),
            content: """
            Route Information:
            • Distance: 19.3 km
            • Elevation: ↑ 150m ↓ 200m
            • Final stage before Santiago
            • Key stops: Santa Irene (10.0 km, bar/store)
            • Highlights: Church of Santa Eulalia
            
            Lodging:
            Hotel O Acivro - Modern hotel with restaurant
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 5))!,
            elevationProfile: [
                (0, 150), (10, 200)
            ]
        ),
        CaminoDestination(
            day: 36,
            locationName: "Santiago de Compostela",
            hotelName: "Hotel Compostela",
            coordinate: CLLocationCoordinate2D(latitude: 42.8800, longitude: -8.5450),
            content: """
            Route Information:
            • Distance: 20.2 km
            • Elevation: ↑ 200m ↓ 250m
            • Final destination of the Camino
            • Key stops: Monte do Gozo (5.0 km, bar/store)
            • Highlights: Cathedral of Santiago, Old Town
            
            Lodging:
            Hotel Compostela - Historic hotel near the cathedral
            """,
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 6))!,
            elevationProfile: [
                (0, 200), (5, 250)
            ]
        )
    ]
    
    init(day: Int, locationName: String, hotelName: String, coordinate: CLLocationCoordinate2D, content: String, date: Date, elevationProfile: [(distance: Double, elevation: Double)]) {
        self.day = day
        self.locationName = locationName
        self.hotelName = hotelName
        self.coordinate = coordinate
        self.content = content
        self.date = date
        self.elevationProfile = elevationProfile
    }
}

