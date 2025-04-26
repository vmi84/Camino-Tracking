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
        // NOTE: Distances below need recalculation based on updated coordinates from RouteDetail_Update.txt
        CaminoDestination(day: 0, date: Self.dateFormatter.date(from: "2025-05-01")!, locationName: "Saint Jean Pied de Port", hotelName: "Villa Goxoki", 
            coordinate: CLLocationCoordinate2D(latitude: 43.1630, longitude: -1.2380), // From TXT Day 1 Start
            elevationProfileAssetName: "elevation_day1",
            dailyDistance: 0.0, // Needs recalc
            cumulativeDistance: 0.0, // Needs recalc
            checkInInfo: "Villa Goxoki, 01-May-2025", 
            checkOutInfo: "02-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: nil),
        
        CaminoDestination(day: 1, date: Self.dateFormatter.date(from: "2025-05-02")!, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", 
            coordinate: CLLocationCoordinate2D(latitude: 43.0090, longitude: -1.3190), // From TXT Day 1 End
            elevationProfileAssetName: "elevation_day1", // Asset name may need updating based on route change
            dailyDistance: 25.0, // Needs recalc
            cumulativeDistance: 25.0, // Needs recalc
            checkInInfo: "Hotel Roncesvalles, 02-May-2025", 
            checkOutInfo: "03-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Villa Goxoki on 02-May-2025, delivered to Hotel Roncesvalles. Note: If cycling, luggage must be left at reception by 07:30."),
        
        CaminoDestination(day: 2, date: Self.dateFormatter.date(from: "2025-05-03")!, locationName: "Zubiri", hotelName: "Hostería de Zubiri", 
            coordinate: CLLocationCoordinate2D(latitude: 42.9320, longitude: -1.5030), // From TXT Day 2 End
            elevationProfileAssetName: "elevation_day2",
            dailyDistance: 22.0, // Needs recalc
            cumulativeDistance: 47.0, // Needs recalc
            checkInInfo: "Hostería de Zubiri, 03-May-2025", 
            checkOutInfo: "04-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Roncesvalles on 03-May-2025, delivered to Hostería de Zubiri."),
        
        CaminoDestination(day: 3, date: Self.dateFormatter.date(from: "2025-05-04")!, locationName: "Pamplona", hotelName: "Hotel A Pamplona", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8120, longitude: -1.6450), // From TXT Day 3 End
            elevationProfileAssetName: "elevation_day3",
            dailyDistance: 20.0, // Needs recalc
            cumulativeDistance: 67.0, // Needs recalc
            checkInInfo: "Hotel A Pamplona, 04-May-2025", 
            checkOutInfo: "05-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostería de Zubiri on 04-May-2025, delivered to Hotel A Pamplona."),
        
        CaminoDestination(day: 4, date: Self.dateFormatter.date(from: "2025-05-05")!, locationName: "Puente la Reina", hotelName: "Hotel El Cerco", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6720, longitude: -1.8140), // From TXT Day 4 End
            elevationProfileAssetName: "elevation_day4",
            dailyDistance: 24.0, // Needs recalc
            cumulativeDistance: 91.0, // Needs recalc
            checkInInfo: "Hotel El Cerco, 05-May-2025", 
            checkOutInfo: "06-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel A Pamplona on 05-May-2025, delivered to Hotel El Cerco."),
        
        CaminoDestination(day: 5, date: Self.dateFormatter.date(from: "2025-05-06")!, locationName: "Estella", hotelName: "Alda Estella Hostel", // TXT uses "Estella"
            coordinate: CLLocationCoordinate2D(latitude: 42.6710, longitude: -2.0320), // From TXT Day 5 End
            elevationProfileAssetName: "elevation_day5",
            dailyDistance: 22.0, // Needs recalc
            cumulativeDistance: 113.0, // Needs recalc
            checkInInfo: "Alda Estella Hostel, 06-May-2025", 
            checkOutInfo: "07-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel El Cerco on 06-May-2025, delivered to Alda Estella Hostel."),
        
        CaminoDestination(day: 6, date: Self.dateFormatter.date(from: "2025-05-07")!, locationName: "Los Arcos", hotelName: "Pensión Los Arcos", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5710, longitude: -2.1920), // From TXT Day 6 End
            elevationProfileAssetName: "elevation_day6",
            dailyDistance: 21.0, // Needs recalc
            cumulativeDistance: 134.0, // Needs recalc
            checkInInfo: "Pensión Los Arcos, 07-May-2025", 
            checkOutInfo: "08-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Alda Estella Hostel on 07-May-2025, delivered to Pensión Los Arcos."),
        
        CaminoDestination(day: 7, date: Self.dateFormatter.date(from: "2025-05-08")!, locationName: "Logroño", hotelName: "Hotel Ciudad de Logroño", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450), // From TXT Day 7 End
            elevationProfileAssetName: "elevation_day7",
            dailyDistance: 28.0, // Needs recalc
            cumulativeDistance: 162.0, // Needs recalc
            checkInInfo: "Hotel Ciudad de Logroño, 08-May-2025", 
            checkOutInfo: "09-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Pensión Los Arcos on 08-May-2025, delivered to Hotel Ciudad de Logroño."),
        
        CaminoDestination(day: 8, date: Self.dateFormatter.date(from: "2025-05-09")!, locationName: "Nájera", hotelName: "Hotel Duques de Nájera", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7320), // From TXT Day 8 End
            elevationProfileAssetName: "elevation_day8",
            dailyDistance: 21.0, // Needs recalc (was 21 before)
            cumulativeDistance: 183.0, // Needs recalc
            checkInInfo: "Hotel Duques de Nájera, 09-May-2025", 
            checkOutInfo: "10-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Ciudad de Logroño on 09-May-2025, delivered to Hotel Duques de Nájera."),
        
        CaminoDestination(day: 9, date: Self.dateFormatter.date(from: "2025-05-10")!, locationName: "Santo Domingo de la Calzada", hotelName: "El Molino de Floren", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530), // From TXT Day 9 End
            elevationProfileAssetName: "elevation_day9",
            dailyDistance: 21.0, // Needs recalc
            cumulativeDistance: 204.0, // Needs recalc
            checkInInfo: "El Molino de Floren, 10-May-2025", 
            checkOutInfo: "11-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Duques de Nájera on 10-May-2025, delivered to El Molino de Floren."),
        
        CaminoDestination(day: 10, date: Self.dateFormatter.date(from: "2025-05-11")!, locationName: "Belorado", hotelName: "Hostel Punto B", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910), // From TXT Day 10 End
            elevationProfileAssetName: "elevation_day10",
            dailyDistance: 22.0, // Needs recalc (was 22 before)
            cumulativeDistance: 226.0, // Needs recalc
            checkInInfo: "Hostel Punto B, 11-May-2025", 
            checkOutInfo: "12-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from El Molino de Floren on 11-May-2025, delivered to Hostel Punto B."),
        
        CaminoDestination(day: 11, date: Self.dateFormatter.date(from: "2025-05-12")!, locationName: "San Juan de Ortega", hotelName: "Hotel Rural la Henera", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3750, longitude: -3.4370), // From TXT Day 11 End
            elevationProfileAssetName: "elevation_day11",
            dailyDistance: 24.0, // Needs recalc
            cumulativeDistance: 250.0, // Needs recalc
            checkInInfo: "Hotel Rural la Henera, 12-May-2025", 
            checkOutInfo: "13-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostel Punto B on 12-May-2025, delivered to Hotel Rural la Henera."),
        
        CaminoDestination(day: 12, date: Self.dateFormatter.date(from: "2025-05-13")!, locationName: "Burgos", hotelName: "Hotel Cordón", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7040), // From TXT Day 12 End
            elevationProfileAssetName: "elevation_day12",
            dailyDistance: 26.0, // Needs recalc (was 26 before)
            cumulativeDistance: 276.0, // Needs recalc
            checkInInfo: "Hotel Cordón, 13-May-2025", 
            checkOutInfo: "14-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Rural la Henera on 13-May-2025, delivered to Hotel Cordón."),
        
        CaminoDestination(day: 13, date: Self.dateFormatter.date(from: "2025-05-14")!, locationName: "Hornillos del Camino", hotelName: "De Sol A Sol", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3390, longitude: -3.9240), // From TXT Day 13 End
            elevationProfileAssetName: "elevation_day13",
            dailyDistance: 21.0, // Needs recalc
            cumulativeDistance: 297.0, // Needs recalc
            checkInInfo: "De Sol A Sol, 14-May-2025", 
            checkOutInfo: "15-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Cordón on 14-May-2025, delivered to De Sol A Sol."),
        
        CaminoDestination(day: 14, date: Self.dateFormatter.date(from: "2025-05-15")!, locationName: "Castrojeriz", hotelName: "A Cien Leguas", 
            coordinate: CLLocationCoordinate2D(latitude: 42.2880, longitude: -4.1380), // From TXT Day 14 End
            elevationProfileAssetName: "elevation_day14",
            dailyDistance: 20.0, // Needs recalc
            cumulativeDistance: 317.0, // Needs recalc
            checkInInfo: "A Cien Leguas, 15-May-2025", 
            checkOutInfo: "16-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from De Sol A Sol on 15-May-2025, delivered to A Cien Leguas."),
        
        CaminoDestination(day: 15, date: Self.dateFormatter.date(from: "2025-05-16")!, locationName: "Frómista", hotelName: "Eco Hotel Doña Mayor", 
            coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060), // From TXT Day 15 End
            elevationProfileAssetName: "elevation_day15",
            dailyDistance: 25.0, // Needs recalc
            cumulativeDistance: 342.0, // Needs recalc
            checkInInfo: "Eco Hotel Doña Mayor, 16-May-2025", 
            checkOutInfo: "17-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from A Cien Leguas on 16-May-2025, delivered to Eco Hotel Doña Mayor."),
        
        CaminoDestination(day: 16, date: Self.dateFormatter.date(from: "2025-05-17")!, locationName: "Carrión de los Condes", hotelName: "Hostal La Corte", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030), // From TXT Day 16 End
            elevationProfileAssetName: "elevation_day16",
            dailyDistance: 19.0, // Needs recalc (was 19 before)
            cumulativeDistance: 361.0, // Needs recalc
            checkInInfo: "Hostal La Corte, 17-May-2025", 
            checkOutInfo: "18-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Eco Hotel Doña Mayor on 17-May-2025, delivered to Hostal La Corte."),
        
        CaminoDestination(day: 17, date: Self.dateFormatter.date(from: "2025-05-18")!, locationName: "Calzadilla de la Cueza", hotelName: "Hostal Camino Real", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.8020), // From TXT Day 17 End
            elevationProfileAssetName: "elevation_day17",
            dailyDistance: 17.0, // Needs recalc (was 17 before)
            cumulativeDistance: 378.0, // Needs recalc
            checkInInfo: "Hostal Camino Real, 18-May-2025", 
            checkOutInfo: "19-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal La Corte on 18-May-2025, delivered to Hostal Camino Real."),

        CaminoDestination(day: 18, date: Self.dateFormatter.date(from: "2025-05-19")!, locationName: "Sahagún", hotelName: "Hostal Domus Viatoris", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290), // From TXT Day 18 End
            elevationProfileAssetName: "elevation_day18",
            dailyDistance: 22.0, // Needs recalc (was 22 before)
            cumulativeDistance: 400.0, // Needs recalc
            checkInInfo: "Hostal Domus Viatoris, 19-May-2025", 
            checkOutInfo: "20-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal Camino Real on 19-May-2025, delivered to Hostal Domus Viatoris."),

        CaminoDestination(day: 19, date: Self.dateFormatter.date(from: "2025-05-20")!, locationName: "El Burgo Ranero", hotelName: "Hotel Castillo El Burgo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4230, longitude: -5.2210), // From TXT Day 19 End
            elevationProfileAssetName: "elevation_day19",
            dailyDistance: 18.0, // Needs recalc (was 18 before)
            cumulativeDistance: 418.0, // Needs recalc
            checkInInfo: "Hotel Castillo El Burgo, 20-May-2025", 
            checkOutInfo: "21-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal Domus Viatoris on 20-May-2025, delivered to Hotel Castillo El Burgo."),
        
        CaminoDestination(day: 20, date: Self.dateFormatter.date(from: "2025-05-21")!, locationName: "Mansilla de las Mulas", hotelName: "Albergueria del Camino", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.4170), // From TXT Day 20 End
            elevationProfileAssetName: "elevation_day20", // Corrected from day 21
            dailyDistance: 19.0, // Needs recalc
            cumulativeDistance: 437.0, // Needs recalc
            checkInInfo: "Albergueria del Camino, 21-May-2025", 
            checkOutInfo: "22-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Castillo El Burgo on 21-May-2025, delivered to Albergueria del Camino."),

        CaminoDestination(day: 21, date: Self.dateFormatter.date(from: "2025-05-22")!, locationName: "León", hotelName: "Hotel Alda Vía León", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710), // From TXT Day 21 End
            elevationProfileAssetName: "elevation_day21", // Corrected from day 22
            dailyDistance: 18.0, // Needs recalc
            cumulativeDistance: 455.0, // Needs recalc
            checkInInfo: "Hotel Alda Vía León, 22-May-2025", 
            checkOutInfo: "23-May-2025", // Check-out aligns with start of rest day
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Albergueria del Camino on 22-May-2025, delivered to Hotel Alda Vía León."),
            
        // Day 22 is the Rest Day in León as per TXT file
        CaminoDestination(day: 22, date: Self.dateFormatter.date(from: "2025-05-23")!, locationName: "León (Rest Day)", hotelName: "Hotel Alda Vía León", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710), // Same as Day 21 End
            elevationProfileAssetName: "elevation_day22", // Placeholder, might need removing or specific asset
            dailyDistance: 0.0, // Rest day
            cumulativeDistance: 455.0, // Same as previous day
            checkInInfo: "Rest day at Hotel Alda Vía León", // Update check-in info
            checkOutInfo: "24-May-2025", // Check-out for Day 23 start
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: nil), // No transfer on rest day

        CaminoDestination(day: 23, date: Self.dateFormatter.date(from: "2025-05-24")!, locationName: "Chozas de Abajo", hotelName: "Albergue San Antonio de Padua", // Original hotel kept
            coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.6860), // From TXT Day 23 End
            elevationProfileAssetName: "elevation_day23",
            dailyDistance: 22.0, // Needs recalc
            cumulativeDistance: 477.0, // Needs recalc
            checkInInfo: "Albergue San Antonio de Padua, 24-May-2025", 
            checkOutInfo: "25-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Alda Vía León on 24-May-2025, delivered to Albergue San Antonio de Padua."),

        CaminoDestination(day: 24, date: Self.dateFormatter.date(from: "2025-05-25")!, locationName: "Astorga", hotelName: "Hotel Astur Plaza", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4580, longitude: -6.0530), // From TXT Day 24 End
            elevationProfileAssetName: "elevation_day24",
            dailyDistance: 27.0, // Needs recalc (was 27 before)
            cumulativeDistance: 504.0, // Needs recalc
            checkInInfo: "Hotel Astur Plaza, 25-May-2025", 
            checkOutInfo: "26-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Albergue San Antonio de Padua on 25-May-2025, delivered to Hotel Astur Plaza."),

        CaminoDestination(day: 25, date: Self.dateFormatter.date(from: "2025-05-26")!, locationName: "Rabanal del Camino", hotelName: "Hotel Rural Casa Indie", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840), // From TXT Day 25 End
            elevationProfileAssetName: "elevation_day25",
            dailyDistance: 20.0, // Needs recalc (was 20 before)
            cumulativeDistance: 524.0, // Needs recalc
            checkInInfo: "Hotel Rural Casa Indie, 26-May-2025", 
            checkOutInfo: "27-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Astur Plaza on 26-May-2025, delivered to Hotel Rural Casa Indie."),

        CaminoDestination(day: 26, date: Self.dateFormatter.date(from: "2025-05-27")!, locationName: "Ponferrada", hotelName: "Hotel El Castillo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5900), // From TXT Day 26 End
            elevationProfileAssetName: "elevation_day26",
            dailyDistance: 32.0, // Needs recalc (was 32 before)
            cumulativeDistance: 556.0, // Needs recalc
            checkInInfo: "Hotel El Castillo, 27-May-2025", 
            checkOutInfo: "28-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Rural Casa Indie on 27-May-2025, delivered to Hotel El Castillo."),

        CaminoDestination(day: 27, date: Self.dateFormatter.date(from: "2025-05-28")!, locationName: "Villafranca del Bierzo", hotelName: "Hostal Tres Campanas", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110), // From TXT Day 27 End
            elevationProfileAssetName: "elevation_day27",
            dailyDistance: 24.0, // Needs recalc (was 24 before)
            cumulativeDistance: 580.0, // Needs recalc
            checkInInfo: "Hostal Tres Campanas, 28-May-2025", 
            checkOutInfo: "29-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel El Castillo on 28-May-2025, delivered to Hostal Tres Campanas."),

        CaminoDestination(day: 28, date: Self.dateFormatter.date(from: "2025-05-29")!, locationName: "O Cebreiro", hotelName: "Casa Navarro", 
            coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0020), // From TXT Day 28 End
            elevationProfileAssetName: "elevation_day28",
            dailyDistance: 28.0, // Needs recalc (was 28 before)
            cumulativeDistance: 608.0, // Needs recalc
            checkInInfo: "Casa Navarro, 29-May-2025", 
            checkOutInfo: "30-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hostal Tres Campanas on 29-May-2025, delivered to Casa Navarro."),
        
        CaminoDestination(day: 29, date: Self.dateFormatter.date(from: "2025-05-30")!, locationName: "Triacastela", hotelName: "Complexo Xacobeo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.7560, longitude: -7.2340), // From TXT Day 29 End
            elevationProfileAssetName: "elevation_day29",
            dailyDistance: 21.0, // Needs recalc (was 21 before)
            cumulativeDistance: 629.0, // Needs recalc
            checkInInfo: "Complexo Xacobeo, 30-May-2025", 
            checkOutInfo: "31-May-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Casa Navarro on 30-May-2025, delivered to Complexo Xacobeo."),
        
        CaminoDestination(day: 30, date: Self.dateFormatter.date(from: "2025-05-31")!, locationName: "Sarria", hotelName: "Hotel Mar de Plata", 
            coordinate: CLLocationCoordinate2D(latitude: 42.7810, longitude: -7.4140), // From TXT Day 30 End (via San Xil)
            elevationProfileAssetName: "elevation_day30",
            dailyDistance: 18.5, // Needs recalc (was 18.5 before)
            cumulativeDistance: 647.5, // Needs recalc
            checkInInfo: "Hotel Mar de Plata, 31-May-2025", 
            checkOutInfo: "01-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Complexo Xacobeo on 31-May-2025, delivered to Hotel Mar de Plata."),

        CaminoDestination(day: 31, date: Self.dateFormatter.date(from: "2025-06-01")!, locationName: "Portomarín", hotelName: "Casona Da Ponte Portomarín", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160), // From TXT Day 31 End
            elevationProfileAssetName: "elevation_day31",
            dailyDistance: 22.0, // Needs recalc (was 22 before)
            cumulativeDistance: 669.5, // Needs recalc
            checkInInfo: "Casona Da Ponte Portomarín, 01-Jun-2025", 
            checkOutInfo: "02-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Mar de Plata on 01-Jun-2025, delivered to Casona Da Ponte Portomarín."),
        
        CaminoDestination(day: 32, date: Self.dateFormatter.date(from: "2025-06-02")!, locationName: "Palas de Rei", hotelName: "Hotel Mica", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8730, longitude: -7.8690), // From TXT Day 32 End
            elevationProfileAssetName: "elevation_day32",
            dailyDistance: 25.0, // Needs recalc (was 25 before)
            cumulativeDistance: 694.5, // Needs recalc
            checkInInfo: "Hotel Mica, 02-Jun-2025", 
            checkOutInfo: "03-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Casona Da Ponte Portomarín on 02-Jun-2025, delivered to Hotel Mica."),

        CaminoDestination(day: 33, date: Self.dateFormatter.date(from: "2025-06-03")!, locationName: "Arzúa", hotelName: "Hotel Arzúa", 
            coordinate: CLLocationCoordinate2D(latitude: 42.9280, longitude: -8.1600), // From TXT Day 33 End
            elevationProfileAssetName: "elevation_day33",
            dailyDistance: 29.0, // Needs recalc (was 29 before)
            cumulativeDistance: 723.5, // Needs recalc
            checkInInfo: "Hotel Arzúa, 03-Jun-2025", 
            checkOutInfo: "04-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Mica on 03-Jun-2025, delivered to Hotel Arzúa."),

        CaminoDestination(day: 34, date: Self.dateFormatter.date(from: "2025-06-04")!, locationName: "A Rúa", hotelName: "Hotel Rural O Acivro", // TXT file uses A Rúa, original had O Pedrouzo
            coordinate: CLLocationCoordinate2D(latitude: 42.9080, longitude: -8.3670), // From TXT Day 34 End (A Rúa)
            elevationProfileAssetName: "elevation_day34",
            dailyDistance: 19.0, // Needs recalc (was 19 before)
            cumulativeDistance: 742.5, // Needs recalc
            checkInInfo: "Hotel Rural O Acivro, 04-Jun-2025", 
            checkOutInfo: "05-Jun-2025", 
            bookingReference: "SW28984", 
            roomDetails: "1 Twin room", 
            mealDetails: "Breakfast", 
            luggageTransferInfo: "Collected from Hotel Arzúa on 04-Jun-2025, delivered to Hotel Rural O Acivro."),

        CaminoDestination(day: 35, date: Self.dateFormatter.date(from: "2025-06-05")!, locationName: "Santiago de Compostela", hotelName: "Hotel Alda Avenida", // TXT Day 35 End
            coordinate: CLLocationCoordinate2D(latitude: 42.8800, longitude: -8.5450), // From TXT Day 35 End
            elevationProfileAssetName: "elevation_day35",
            dailyDistance: 20.0, // Needs recalc (was 20 before)
            cumulativeDistance: 762.5, // Needs recalc
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