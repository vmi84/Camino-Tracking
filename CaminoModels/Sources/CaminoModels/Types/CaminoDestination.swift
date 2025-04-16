import SwiftUI
import MapKit
import CoreLocation

public struct CaminoDestination: Identifiable, Hashable {
    public let id = UUID()
    public let day: Int
    public let date: Date
    public let locationName: String
    public let hotelName: String
    public let coordinate: CLLocationCoordinate2D
    public let elevationProfileAssetName: String
    public let dailyDistance: Double
    public let cumulativeDistance: Double
    
    // Add new properties for detailed hotel info
    public let checkInInfo: String?
    public let checkOutInfo: String?
    public let bookingReference: String?
    public let roomDetails: String?
    public let mealDetails: String?
    public let luggageTransferInfo: String?
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter.string(from: date)
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public static var totalDistance: Double {
        allDestinations.last?.cumulativeDistance ?? 0.0
    }
    
    public var actualRouteDistance: Double {
        return dailyDistance
    }
    
    public static let allDestinations: [CaminoDestination] = [
        CaminoDestination(day: 0, date: Self.dateFormatter.date(from: "2025-05-01")!, locationName: "Saint Jean Pied de Port", hotelName: "Villa Goxoki", 
            coordinate: CLLocationCoordinate2D(latitude: 43.1630, longitude: -1.2380),
            elevationProfileAssetName: "elevation_day1",
            dailyDistance: 0.0,
            cumulativeDistance: 0.0,
            checkInInfo: "Villa Goxoki, 01-May-2025", 
            checkOutInfo: "02-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: nil), // No luggage transfer for Day 0
        
        CaminoDestination(day: 1, date: Self.dateFormatter.date(from: "2025-05-02")!, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", 
            coordinate: CLLocationCoordinate2D(latitude: 43.0090, longitude: -1.3190),
            elevationProfileAssetName: "elevation_day2",
            dailyDistance: 25.0,
            cumulativeDistance: 25.0,
            checkInInfo: "Hotel Roncesvalles, 02-May-2025", 
            checkOutInfo: "03-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Villa Goxoki on 02-May-2025, delivered to Hotel Roncesvalles. Note: If cycling, luggage must be left at reception by 07:30."),
        
        CaminoDestination(day: 2, date: Self.dateFormatter.date(from: "2025-05-03")!, locationName: "Zubiri", hotelName: "Hostería de Zubiri", 
            coordinate: CLLocationCoordinate2D(latitude: 42.9320, longitude: -1.5030),
            elevationProfileAssetName: "elevation_day3",
            dailyDistance: 22.0,
            cumulativeDistance: 47.0,
            checkInInfo: "Hostería de Zubiri, 03-May-2025", 
            checkOutInfo: "04-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Roncesvalles on 03-May-2025, delivered to Hostería de Zubiri."),
        
        CaminoDestination(day: 3, date: Self.dateFormatter.date(from: "2025-05-04")!, locationName: "Pamplona", hotelName: "Hotel A Pamplona", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8120, longitude: -1.6450),
            elevationProfileAssetName: "elevation_day4",
            dailyDistance: 20.0,
            cumulativeDistance: 67.0,
            checkInInfo: "Hotel A Pamplona, 04-May-2025", 
            checkOutInfo: "05-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostería de Zubiri on 04-May-2025, delivered to Hotel A Pamplona."),
        
        CaminoDestination(day: 4, date: Self.dateFormatter.date(from: "2025-05-05")!, locationName: "Puente la Reina", hotelName: "Hotel El Cerco", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6720, longitude: -1.8140),
            elevationProfileAssetName: "elevation_day5",
            dailyDistance: 24.0,
            cumulativeDistance: 91.0,
            checkInInfo: "Hotel El Cerco, 05-May-2025", 
            checkOutInfo: "06-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel A Pamplona on 05-May-2025, delivered to Hotel El Cerco."),
        
        CaminoDestination(day: 5, date: Self.dateFormatter.date(from: "2025-05-06")!, locationName: "Estella-Lizarra", hotelName: "Alda Estella Hostel", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6710, longitude: -2.0320),
            elevationProfileAssetName: "elevation_day6",
            dailyDistance: 22.0,
            cumulativeDistance: 113.0,
            checkInInfo: "Alda Estella Hostel, 06-May-2025", 
            checkOutInfo: "07-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel El Cerco on 06-May-2025, delivered to Alda Estella Hostel."),
        
        CaminoDestination(day: 6, date: Self.dateFormatter.date(from: "2025-05-07")!, locationName: "Los Arcos", hotelName: "Pensión Los Arcos", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5710, longitude: -2.1920),
            elevationProfileAssetName: "elevation_day7",
            dailyDistance: 21.0,
            cumulativeDistance: 134.0,
            checkInInfo: "Pensión Los Arcos, 07-May-2025", 
            checkOutInfo: "08-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Alda Estella Hostel on 07-May-2025, delivered to Pensión Los Arcos."),
        
        CaminoDestination(day: 7, date: Self.dateFormatter.date(from: "2025-05-08")!, locationName: "Logroño", hotelName: "Hotel Ciudad de Logroño", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450),
            elevationProfileAssetName: "elevation_day8",
            dailyDistance: 28.0,
            cumulativeDistance: 162.0,
            checkInInfo: "Hotel Ciudad de Logroño, 08-May-2025", 
            checkOutInfo: "09-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Pensión Los Arcos on 08-May-2025, delivered to Hotel Ciudad de Logroño."),
        
        CaminoDestination(day: 8, date: Self.dateFormatter.date(from: "2025-05-09")!, locationName: "Nájera", hotelName: "Hotel Duques de Nájera", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7320),
            elevationProfileAssetName: "elevation_day9",
            dailyDistance: 21.0,
            cumulativeDistance: 183.0,
            checkInInfo: "Hotel Duques de Nájera, 09-May-2025", 
            checkOutInfo: "10-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Ciudad de Logroño on 09-May-2025, delivered to Hotel Duques de Nájera."),
        
        CaminoDestination(day: 9, date: Self.dateFormatter.date(from: "2025-05-10")!, locationName: "Santo Domingo de la Calzada", hotelName: "El Molino de Floren", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530),
            elevationProfileAssetName: "elevation_day10",
            dailyDistance: 21.0,
            cumulativeDistance: 204.0,
            checkInInfo: "El Molino de Floren, 10-May-2025", 
            checkOutInfo: "11-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Duques de Nájera on 10-May-2025, delivered to El Molino de Floren."),
        
        CaminoDestination(day: 10, date: Self.dateFormatter.date(from: "2025-05-11")!, locationName: "Belorado", hotelName: "Hostel Punto B", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910),
            elevationProfileAssetName: "elevation_day11",
            dailyDistance: 22.0,
            cumulativeDistance: 226.0,
            checkInInfo: "Hostel Punto B, 11-May-2025", 
            checkOutInfo: "12-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from El Molino de Floren on 11-May-2025, delivered to Hostel Punto B."),
        
        CaminoDestination(day: 11, date: Self.dateFormatter.date(from: "2025-05-12")!, locationName: "San Juan de Ortega", hotelName: "Hotel Rural la Henera", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3750, longitude: -3.4370),
            elevationProfileAssetName: "elevation_day12",
            dailyDistance: 24.0,
            cumulativeDistance: 250.0,
            checkInInfo: "Hotel Rural la Henera, 12-May-2025", 
            checkOutInfo: "13-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostel Punto B on 12-May-2025, delivered to Hotel Rural la Henera."),
        
        CaminoDestination(day: 12, date: Self.dateFormatter.date(from: "2025-05-13")!, locationName: "Burgos", hotelName: "Hotel Cordón", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7040),
            elevationProfileAssetName: "elevation_day13",
            dailyDistance: 26.0,
            cumulativeDistance: 276.0,
            checkInInfo: "Hotel Cordón, 13-May-2025", 
            checkOutInfo: "14-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Rural la Henera on 13-May-2025, delivered to Hotel Cordón."),
        
        CaminoDestination(day: 13, date: Self.dateFormatter.date(from: "2025-05-14")!, locationName: "Hornillos del Camino", hotelName: "De Sol A Sol", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3390, longitude: -3.9240),
            elevationProfileAssetName: "elevation_day14",
            dailyDistance: 21.0,
            cumulativeDistance: 297.0,
            checkInInfo: "De Sol A Sol, 14-May-2025", 
            checkOutInfo: "15-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Cordón on 14-May-2025, delivered to De Sol A Sol."),
        
        CaminoDestination(day: 14, date: Self.dateFormatter.date(from: "2025-05-15")!, locationName: "Castrojeriz", hotelName: "A Cien Leguas", 
            coordinate: CLLocationCoordinate2D(latitude: 42.2880, longitude: -4.1380),
            elevationProfileAssetName: "elevation_day15",
            dailyDistance: 20.0,
            cumulativeDistance: 317.0,
            checkInInfo: "A Cien Leguas, 15-May-2025", 
            checkOutInfo: "16-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from De Sol A Sol on 15-May-2025, delivered to A Cien Leguas."),
        
        CaminoDestination(day: 15, date: Self.dateFormatter.date(from: "2025-05-16")!, locationName: "Frómista", hotelName: "Eco Hotel Doña Mayor", 
            coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060),
            elevationProfileAssetName: "elevation_day16",
            dailyDistance: 25.0,
            cumulativeDistance: 342.0,
            checkInInfo: "Eco Hotel Doña Mayor, 16-May-2025", 
            checkOutInfo: "17-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from A Cien Leguas on 16-May-2025, delivered to Eco Hotel Doña Mayor."),
        
        CaminoDestination(day: 16, date: Self.dateFormatter.date(from: "2025-05-17")!, locationName: "Carrión de los Condes", hotelName: "Hostal La Corte", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030),
            elevationProfileAssetName: "elevation_day17",
            dailyDistance: 19.0,
            cumulativeDistance: 361.0,
            checkInInfo: "Hostal La Corte, 17-May-2025", 
            checkOutInfo: "18-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Eco Hotel Doña Mayor on 17-May-2025, delivered to Hostal La Corte."),
        
        CaminoDestination(day: 17, date: Self.dateFormatter.date(from: "2025-05-18")!, locationName: "Calzadilla de la Cueza", hotelName: "Hostal Camino Real", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.8020),
            elevationProfileAssetName: "elevation_day18",
            dailyDistance: 17.0,
            cumulativeDistance: 378.0,
            checkInInfo: "Hostal Camino Real, 18-May-2025", 
            checkOutInfo: "19-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal La Corte on 18-May-2025, delivered to Hostal Camino Real."),
        
        CaminoDestination(day: 18, date: Self.dateFormatter.date(from: "2025-05-19")!, locationName: "Sahagún", hotelName: "Hostal Domus Viatoris", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290),
            elevationProfileAssetName: "elevation_day19",
            dailyDistance: 22.0,
            cumulativeDistance: 400.0,
            checkInInfo: "Hostal Domus Viatoris, 19-May-2025", 
            checkOutInfo: "20-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal Camino Real on 19-May-2025, delivered to Hostal Domus Viatoris."),
        
        CaminoDestination(day: 19, date: Self.dateFormatter.date(from: "2025-05-20")!, locationName: "El Burgo Ranero", hotelName: "Hotel Castillo El Burgo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4230, longitude: -5.2210),
            elevationProfileAssetName: "elevation_day20",
            dailyDistance: 18.0,
            cumulativeDistance: 418.0,
            checkInInfo: "Hotel Castillo El Burgo, 20-May-2025", 
            checkOutInfo: "21-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal Domus Viatoris on 20-May-2025, delivered to Hotel Castillo El Burgo."),
        
        CaminoDestination(day: 20, date: Self.dateFormatter.date(from: "2025-05-21")!, locationName: "Mansilla de las Mulas", hotelName: "Albergueria del Camino", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.4170),
            elevationProfileAssetName: "elevation_day21",
            dailyDistance: 19.0,
            cumulativeDistance: 437.0,
            checkInInfo: "Albergueria del Camino, 21-May-2025", 
            checkOutInfo: "22-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Castillo El Burgo on 21-May-2025, delivered to Albergueria del Camino."),
        
        CaminoDestination(day: 21, date: Self.dateFormatter.date(from: "2025-05-22")!, locationName: "León", hotelName: "Hotel Alda Vía León", // Note: Date corrected from file (was 23-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710),
            elevationProfileAssetName: "elevation_day22",
            dailyDistance: 18.0,
            cumulativeDistance: 455.0,
            checkInInfo: "Hotel Alda Vía León, 22-May-2025", 
            checkOutInfo: "23-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Albergueria del Camino on 22-May-2025, delivered to Hotel Alda Vía León."),
        
        CaminoDestination(day: 22, date: Self.dateFormatter.date(from: "2025-05-23")!, locationName: "León", hotelName: "Hotel Alda Vía León", // Note: Date corrected from file (was 24-May), this is rest day
            coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710),
            elevationProfileAssetName: "elevation_day23",
            dailyDistance: 0.0,
            cumulativeDistance: 455.0,
            checkInInfo: "Hotel Alda Vía León, 23-May-2025", // Check-in is technically 22nd, but represents stay on 23rd 
            checkOutInfo: "24-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: nil), // No transfer on rest day
        
        CaminoDestination(day: 23, date: Self.dateFormatter.date(from: "2025-05-24")!, locationName: "Villar de Mazarife", hotelName: "Albergue San Antonio de Padua", // Note: Date corrected from file (was 25-May), Location updated to match file.
            coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.6860),
            elevationProfileAssetName: "elevation_day24",
            dailyDistance: 22.0,
            cumulativeDistance: 477.0,
            checkInInfo: "Albergue San Antonio de Padua, 24-May-2025", 
            checkOutInfo: "25-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Alda Vía León on 24-May-2025, delivered to Albergue San Antonio de Padua."),
        
        CaminoDestination(day: 24, date: Self.dateFormatter.date(from: "2025-05-25")!, locationName: "Astorga", hotelName: "Hotel Astur Plaza", // Note: Date corrected from file (was 26-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.4580, longitude: -6.0530),
            elevationProfileAssetName: "elevation_day25",
            dailyDistance: 27.0,
            cumulativeDistance: 504.0,
            checkInInfo: "Hotel Astur Plaza, 25-May-2025", 
            checkOutInfo: "26-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Albergue San Antonio de Padua on 25-May-2025, delivered to Hotel Astur Plaza."),
        
        CaminoDestination(day: 25, date: Self.dateFormatter.date(from: "2025-05-26")!, locationName: "Rabanal del Camino", hotelName: "Hotel Rural Casa Indie", // Note: Date corrected from file (was 27-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840),
            elevationProfileAssetName: "elevation_day26",
            dailyDistance: 20.0,
            cumulativeDistance: 524.0,
            checkInInfo: "Hotel Rural Casa Indie, 26-May-2025", 
            checkOutInfo: "27-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Astur Plaza on 26-May-2025, delivered to Hotel Rural Casa Indie."),
        
        CaminoDestination(day: 26, date: Self.dateFormatter.date(from: "2025-05-27")!, locationName: "Ponferrada", hotelName: "Hotel El Castillo", // Note: Date corrected from file (was 28-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5900),
            elevationProfileAssetName: "elevation_day27",
            dailyDistance: 32.0,
            cumulativeDistance: 556.0,
            checkInInfo: "Hotel El Castillo, 27-May-2025", 
            checkOutInfo: "28-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Rural Casa Indie on 27-May-2025, delivered to Hotel El Castillo."),
        
        CaminoDestination(day: 27, date: Self.dateFormatter.date(from: "2025-05-28")!, locationName: "Villafranca del Bierzo", hotelName: "Hostal Tres Campanas", // Note: Date corrected from file (was 29-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110),
            elevationProfileAssetName: "elevation_day28",
            dailyDistance: 24.0,
            cumulativeDistance: 580.0,
            checkInInfo: "Hostal Tres Campanas, 28-May-2025", 
            checkOutInfo: "29-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel El Castillo on 28-May-2025, delivered to Hostal Tres Campanas."),
        
        CaminoDestination(day: 28, date: Self.dateFormatter.date(from: "2025-05-29")!, locationName: "O Cebreiro", hotelName: "Casa Navarro", // Note: Date corrected from file (was 30-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0020),
            elevationProfileAssetName: "elevation_day29",
            dailyDistance: 28.0,
            cumulativeDistance: 608.0,
            checkInInfo: "Casa Navarro, 29-May-2025", 
            checkOutInfo: "30-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal Tres Campanas on 29-May-2025, delivered to Casa Navarro."),
        
        CaminoDestination(day: 29, date: Self.dateFormatter.date(from: "2025-05-30")!, locationName: "Triacastela", hotelName: "Complexo Xacobeo", // Note: Date corrected from file (was 31-May)
            coordinate: CLLocationCoordinate2D(latitude: 42.7560, longitude: -7.2340),
            elevationProfileAssetName: "elevation_day30",
            dailyDistance: 21.0,
            cumulativeDistance: 629.0,
            checkInInfo: "Complexo Xacobeo, 30-May-2025", 
            checkOutInfo: "31-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Casa Navarro on 30-May-2025, delivered to Complexo Xacobeo."),

        CaminoDestination(day: 30, date: Self.dateFormatter.date(from: "2025-05-31")!, locationName: "Sarria", hotelName: "Hotel Mar de Plata", // Note: Date corrected from file (was 01-Jun)
            coordinate: CLLocationCoordinate2D(latitude: 42.7810, longitude: -7.4140),
            elevationProfileAssetName: "elevation_day31",
            dailyDistance: 18.5,
            cumulativeDistance: 647.5,
            checkInInfo: "Hotel Mar de Plata, 31-May-2025", 
            checkOutInfo: "01-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Complexo Xacobeo on 31-May-2025, delivered to Hotel Mar de Plata."),

        CaminoDestination(day: 31, date: Self.dateFormatter.date(from: "2025-06-01")!, locationName: "Portomarín", hotelName: "Casona Da Ponte Portomarín", // Note: Date corrected from file (was 02-Jun)
            coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160),
            elevationProfileAssetName: "elevation_day32",
            dailyDistance: 22.0,
            cumulativeDistance: 669.5,
            checkInInfo: "Casona Da Ponte Portomarín, 01-Jun-2025", 
            checkOutInfo: "02-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Mar de Plata on 01-Jun-2025, delivered to Casona Da Ponte Portomarín."),

        CaminoDestination(day: 32, date: Self.dateFormatter.date(from: "2025-06-02")!, locationName: "Palas de Rei", hotelName: "Hotel Mica", // Note: Date corrected from file (was 03-Jun)
            coordinate: CLLocationCoordinate2D(latitude: 42.8730, longitude: -7.8690),
            elevationProfileAssetName: "elevation_day33",
            dailyDistance: 25.0,
            cumulativeDistance: 694.5,
            checkInInfo: "Hotel Mica, 02-Jun-2025", 
            checkOutInfo: "03-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Casona Da Ponte Portomarín on 02-Jun-2025, delivered to Hotel Mica."),

        CaminoDestination(day: 33, date: Self.dateFormatter.date(from: "2025-06-03")!, locationName: "Arzúa", hotelName: "Hotel Arzúa", // Note: Date corrected from file (was 04-Jun)
            coordinate: CLLocationCoordinate2D(latitude: 42.9280, longitude: -8.1600),
            elevationProfileAssetName: "elevation_day34",
            dailyDistance: 29.0,
            cumulativeDistance: 723.5,
            checkInInfo: "Hotel Arzúa, 03-Jun-2025", 
            checkOutInfo: "04-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Mica on 03-Jun-2025, delivered to Hotel Arzúa."),

        CaminoDestination(day: 34, date: Self.dateFormatter.date(from: "2025-06-04")!, locationName: "A Rúa", hotelName: "Hotel Rural O Acivro", // Note: Date corrected from file (was 05-Jun)
            coordinate: CLLocationCoordinate2D(latitude: 42.9080, longitude: -8.3670),
            elevationProfileAssetName: "elevation_day35",
            dailyDistance: 19.0,
            cumulativeDistance: 742.5,
            checkInInfo: "Hotel Rural O Acivro, 04-Jun-2025", 
            checkOutInfo: "05-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Arzúa on 04-Jun-2025, delivered to Hotel Rural O Acivro."),

        CaminoDestination(day: 35, date: Self.dateFormatter.date(from: "2025-06-05")!, locationName: "Santiago de Compostela", hotelName: "Hotel Alda Avenida", // Note: Date corrected from file (was 06-Jun)
            coordinate: CLLocationCoordinate2D(latitude: 42.8800, longitude: -8.5450),
            elevationProfileAssetName: "elevation_day36",
            dailyDistance: 20.0,
            cumulativeDistance: 762.5,
            checkInInfo: "Hotel Alda Avenida, 05-Jun-2025", 
            checkOutInfo: "06-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Rural O Acivro on 05-Jun-2025, delivered to Hotel Alda Avenida.")
    ]
    
    public init(day: Int, date: Date, locationName: String, hotelName: String, coordinate: CLLocationCoordinate2D, elevationProfileAssetName: String, dailyDistance: Double, cumulativeDistance: Double, checkInInfo: String? = nil, checkOutInfo: String? = nil, bookingReference: String? = nil, roomDetails: String? = nil, mealDetails: String? = nil, luggageTransferInfo: String? = nil) {
        self.day = day
        self.date = date
        self.locationName = locationName
        self.hotelName = hotelName
        self.coordinate = coordinate
        self.elevationProfileAssetName = elevationProfileAssetName
        self.dailyDistance = dailyDistance
        self.cumulativeDistance = cumulativeDistance
        self.checkInInfo = checkInInfo
        self.checkOutInfo = checkOutInfo
        self.bookingReference = bookingReference
        self.roomDetails = roomDetails
        self.mealDetails = mealDetails
        self.luggageTransferInfo = luggageTransferInfo
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: CaminoDestination, rhs: CaminoDestination) -> Bool {
        lhs.id == rhs.id
    }
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
} 