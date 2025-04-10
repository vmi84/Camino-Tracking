import SwiftUI
import MapKit
import CoreLocation

// MARK: - Models
public enum Models {}

extension Models {
    public struct CaminoDestination: Identifiable {
        public let id = UUID()
        public let day: Int
        public let locationName: String
        public let hotelName: String
        public let coordinate: CLLocationCoordinate2D
        public let content: String
        public let elevationProfile: [(distance: Double, elevation: Double)]
        public let formattedDate: String
        
        public init(day: Int, locationName: String, hotelName: String, coordinate: CLLocationCoordinate2D, content: String = "", elevationProfile: [(distance: Double, elevation: Double)] = [], formattedDate: String = "") {
            self.day = day
            self.locationName = locationName
            self.hotelName = hotelName
            self.coordinate = coordinate
            self.content = content
            self.elevationProfile = elevationProfile
            self.formattedDate = formattedDate
        }
        
        public static let allDestinations: [CaminoDestination] = [
            CaminoDestination(day: 0, locationName: "Saint-Jean-Pied-de-Port", hotelName: "Villa Goxoki", coordinate: CLLocationCoordinate2D(latitude: 43.1636, longitude: -1.2386)),
            CaminoDestination(day: 1, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", coordinate: CLLocationCoordinate2D(latitude: 42.9878, longitude: -1.3197)),
            CaminoDestination(day: 2, locationName: "Zubiri", hotelName: "Hosteria de Zubiri", coordinate: CLLocationCoordinate2D(latitude: 42.9321, longitude: -1.5036)),
            CaminoDestination(day: 3, locationName: "Pamplona", hotelName: "Hotel A Pamplona", coordinate: CLLocationCoordinate2D(latitude: 42.8110, longitude: -1.6450)),
            CaminoDestination(day: 4, locationName: "Puente la Reina", hotelName: "Hotel El Cerco", coordinate: CLLocationCoordinate2D(latitude: 42.6728, longitude: -1.8115)),
            CaminoDestination(day: 5, locationName: "Estella", hotelName: "Alda Estella Hostal", coordinate: CLLocationCoordinate2D(latitude: 42.6708, longitude: -2.0295)),
            CaminoDestination(day: 6, locationName: "Los Arcos", hotelName: "Pensión Los Arcos", coordinate: CLLocationCoordinate2D(latitude: 42.5715, longitude: -2.1918)),
            CaminoDestination(day: 7, locationName: "Logroño", hotelName: "Hotel Ciudad de Logroño", coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450)),
            CaminoDestination(day: 8, locationName: "Nájera", hotelName: "Hotel Duques de Nájera", coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7290)),
            CaminoDestination(day: 9, locationName: "Santo Domingo de la Calzada", hotelName: "El Molino de Floren", coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530)),
            CaminoDestination(day: 10, locationName: "Belorado", hotelName: "Hostel Punto B", coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910)),
            CaminoDestination(day: 11, locationName: "San Juan de Ortega", hotelName: "Hotel Rural la Iglesia", coordinate: CLLocationCoordinate2D(latitude: 42.3760, longitude: -3.4370)),
            CaminoDestination(day: 12, locationName: "Burgos", hotelName: "Hotel Cordón", coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7010)),
            CaminoDestination(day: 13, locationName: "Hornillos del Camino", hotelName: "De Sol A Sol", coordinate: CLLocationCoordinate2D(latitude: 42.3130, longitude: -4.0460)),
            CaminoDestination(day: 14, locationName: "Castrojeriz", hotelName: "A Cien Leguas", coordinate: CLLocationCoordinate2D(latitude: 42.2900, longitude: -4.1380)),
            CaminoDestination(day: 15, locationName: "Frómista", hotelName: "Eco Hotel Doña Mayor", coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060)),
            CaminoDestination(day: 16, locationName: "Carrión de los Condes", hotelName: "Hostal La Corte", coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030)),
            CaminoDestination(day: 17, locationName: "Calzadilla de la Cueza", hotelName: "Hostal Camino Real", coordinate: CLLocationCoordinate2D(latitude: 42.3630, longitude: -4.8860)),
            CaminoDestination(day: 18, locationName: "Sahagún", hotelName: "Hostal Domus Viatoris", coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290)),
            CaminoDestination(day: 19, locationName: "El Burgo Ranero", hotelName: "Hotel Castillo El Burgo", coordinate: CLLocationCoordinate2D(latitude: 42.4220, longitude: -5.2200)),
            CaminoDestination(day: 20, locationName: "Mansilla de las Mulas", hotelName: "Alberguería del Camino", coordinate: CLLocationCoordinate2D(latitude: 42.4990, longitude: -5.4170)),
            CaminoDestination(day: 21, locationName: "León", hotelName: "Hotel Alda Vía León", coordinate: CLLocationCoordinate2D(latitude: 42.5990, longitude: -5.5710)),
            CaminoDestination(day: 22, locationName: "Villadangos del Páramo", hotelName: "TBD", coordinate: CLLocationCoordinate2D(latitude: 42.5160, longitude: -5.7660)),
            CaminoDestination(day: 23, locationName: "Chozas de Abajo", hotelName: "Albergue San Antonio", coordinate: CLLocationCoordinate2D(latitude: 42.5060, longitude: -5.6830)),
            CaminoDestination(day: 24, locationName: "Astorga", hotelName: "Hotel Astur Plaza", coordinate: CLLocationCoordinate2D(latitude: 42.4570, longitude: -6.0560)),
            CaminoDestination(day: 25, locationName: "Rabanal del Camino", hotelName: "Hotel Rural Casa Indie", coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840)),
            CaminoDestination(day: 26, locationName: "Ponferrada", hotelName: "Hotel El Castillo", coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5960)),
            CaminoDestination(day: 27, locationName: "Villafranca del Bierzo", hotelName: "Hostal Tres Campanas", coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110)),
            CaminoDestination(day: 28, locationName: "O Cebreiro", hotelName: "Casa Navarro", coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0420)),
            CaminoDestination(day: 29, locationName: "Triacastela", hotelName: "Complexo Xacobeo", coordinate: CLLocationCoordinate2D(latitude: 42.7550, longitude: -7.2370))
        ]
    }
    
    public typealias Destination = CaminoDestination
} 