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
    public let elevationProfile: [(distance: Double, elevation: Double)]
    public let dailyDistance: Double
    public let cumulativeDistance: Double
    public let content: String
    
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
            dailyDistance: 0.0,
            cumulativeDistance: 0.0,
            elevationProfile: [],
            content: "Arrive at Villa Goxoki to begin your Camino journey. Located at 75 Dead-end Alley of Iparrenea, near the historic town center."),
        
        CaminoDestination(day: 1, date: Self.dateFormatter.date(from: "2025-05-02")!, locationName: "Roncesvalles", hotelName: "Hotel Roncesvalles", 
            coordinate: CLLocationCoordinate2D(latitude: 43.0090, longitude: -1.3190),
            dailyDistance: 25.0,
            cumulativeDistance: 25.0,
            elevationProfile: [],
            content: "From Villa Goxoki, head uphill via Rue de la Citadelle, following Camino signs. Ascend steeply over the Pyrenees via the Route Napoléon, passing Valcarlos (10 km) and the Col de Lepoeder (20 km, high point). Descend to Roncesvalles (25 km). Enter Roncesvalles near the Collegiate Church. Your hotel is located near the main square, a short walk from the Camino entrance."),
        
        CaminoDestination(day: 2, date: Self.dateFormatter.date(from: "2025-05-03")!, locationName: "Zubiri", hotelName: "Hostería de Zubiri", 
            coordinate: CLLocationCoordinate2D(latitude: 42.9320, longitude: -1.5030),
            dailyDistance: 22.0,
            cumulativeDistance: 47.0,
            elevationProfile: [],
            content: "From Hotel Roncesvalles, head south along the Camino trail. Pass Burguete (3 km, all services), Espinal (6 km), and descend through forests via Viscarret (12 km). Cross the Arga River to Zubiri (22 km) and enter near the medieval bridge. From the bridge, proceed to Av. de Roncesvalles Orreagako Etorbidea, 6, about 200 meters."),
        
        CaminoDestination(day: 3, date: Self.dateFormatter.date(from: "2025-05-04")!, locationName: "Pamplona", hotelName: "Hotel A Pamplona", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8120, longitude: -1.6450),
            dailyDistance: 20.0,
            cumulativeDistance: 67.0,
            elevationProfile: [],
            content: "From Hostería de Zubiri, head south along the Camino. Pass Larrasoaña (6 km, bar), Trinidad de Arre (15 km), and enter Pamplona (20 km) via the Magdalena Bridge and city walls. Arrive near Plaza del Castillo. From Plaza del Castillo, head to Calle Sancho Ramirez, 15, about 1 km."),
        
        CaminoDestination(day: 4, date: Self.dateFormatter.date(from: "2025-05-05")!, locationName: "Puente la Reina", hotelName: "Hotel El Cerco", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6720, longitude: -1.8140),
            dailyDistance: 24.0,
            cumulativeDistance: 91.0,
            elevationProfile: [],
            content: "From Hotel A Pamplona, head west from the city center via Camino signs. Climb to Alto del Perdón (10 km, ridge), descend via Uterga (17 km) and Obanos (20 km), and arrive in Puente la Reina (24 km). Enter via the medieval bridge. From the bridge, head to Calle de Rodrigo Ximenez de Rada, 36, about 300 meters."),
        
        CaminoDestination(day: 5, date: Self.dateFormatter.date(from: "2025-05-06")!, locationName: "Estella-Lizarra", hotelName: "Alda Estella Hostel", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6710, longitude: -2.0320),
            dailyDistance: 22.0,
            cumulativeDistance: 113.0,
            elevationProfile: [],
            content: "From Hotel El Cerco, head southwest along the Camino. Pass Cirauqui (6 km, bar), Lorca (12 km), and Villatuerta (18 km). Arrive in Estella (22 km) via the historic center. Enter near Plaza de San Martín. From the Camino entrance, head to Plaza Santiago 41, about 200 meters."),
        
        CaminoDestination(day: 6, date: Self.dateFormatter.date(from: "2025-05-07")!, locationName: "Los Arcos", hotelName: "Pensión Los Arcos", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5710, longitude: -2.1920),
            dailyDistance: 21.0,
            cumulativeDistance: 134.0,
            elevationProfile: [],
            content: "From Alda Estella Hostel, head southwest along the Camino. Pass the Monastery of Irache (3 km), Azqueta (8 km), and Villamayor de Monjardín (10 km). Continue to Los Arcos (21 km). Enter near Plaza del Coso. From the Camino entrance, head to Calle la Carrera, 8A, about 200 meters."),
        
        CaminoDestination(day: 7, date: Self.dateFormatter.date(from: "2025-05-08")!, locationName: "Logroño", hotelName: "Hotel Ciudad de Logroño", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4660, longitude: -2.4450),
            dailyDistance: 28.0,
            cumulativeDistance: 162.0,
            elevationProfile: [],
            content: "From Pensión Los Arcos, head southwest along the Camino. Pass Torres del Río (7 km), Viana (18 km, all services), and cross into La Rioja. Enter Logroño (28 km) via the Ebro River bridge. Arrive near Calle Portales. From the bridge, head to Menendez Pelayo, 7, about 1 km."),
        
        CaminoDestination(day: 8, date: Self.dateFormatter.date(from: "2025-05-09")!, locationName: "Nájera", hotelName: "Hotel Duques de Nájera", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4160, longitude: -2.7320),
            dailyDistance: 21.0,
            cumulativeDistance: 183.0,
            elevationProfile: [],
            content: "From Hotel Ciudad de Logroño, head southwest via Camino signs. Pass Navarrete (12 km, all services) and Ventosa (17 km). Arrive in Nájera (21 km) via the Najerilla River bridge. Enter near Plaza de San Miguel. From the bridge, head to Calle Carmen, 7, about 300 meters."),
        
        CaminoDestination(day: 9, date: Self.dateFormatter.date(from: "2025-05-10")!, locationName: "Santo Domingo de la Calzada", hotelName: "El Molino de Floren", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4400, longitude: -2.9530),
            dailyDistance: 21.0,
            cumulativeDistance: 204.0,
            elevationProfile: [],
            content: "From Hotel Duques de Nájera, head southwest along the Camino. Pass Azofra (6 km, bar) and Cirueña (15 km). Arrive in Santo Domingo de la Calzada (21 km) via Calle Mayor. Enter near the Cathedral. From Calle Mayor, head to Calle Margubete, 5, about 200 meters."),
        
        CaminoDestination(day: 10, date: Self.dateFormatter.date(from: "2025-05-11")!, locationName: "Belorado", hotelName: "Hostel Punto B", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4200, longitude: -3.1910),
            dailyDistance: 22.0,
            cumulativeDistance: 226.0,
            elevationProfile: [],
            content: "From El Molino de Floren, head southwest along the Camino. Pass Grañón (6 km), Redecilla del Camino (10 km), and Viloria de Rioja (15 km). Arrive in Belorado (22 km). Enter near Plaza Mayor. From Plaza Mayor, head to Calle Cuatro Cantones, 4, about 100 meters."),
        
        CaminoDestination(day: 11, date: Self.dateFormatter.date(from: "2025-05-12")!, locationName: "San Juan de Ortega", hotelName: "Hotel Rural la Henera", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3750, longitude: -3.4370),
            dailyDistance: 24.0,
            cumulativeDistance: 250.0,
            elevationProfile: [],
            content: "From Hostel Punto B, head southwest along the Camino. Pass Tosantos (5 km), Villafranca Montes de Oca (12 km), and climb through forests. Arrive in San Juan de Ortega (24 km). Enter near the monastery. Check in at Bar Marcela (in front of the church), then proceed to Calle Iglesia, 4, behind the church."),
        
        CaminoDestination(day: 12, date: Self.dateFormatter.date(from: "2025-05-13")!, locationName: "Burgos", hotelName: "Hotel Cordón", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3410, longitude: -3.7040),
            dailyDistance: 26.0,
            cumulativeDistance: 276.0,
            elevationProfile: [],
            content: "From Hotel Rural la Henera, head southwest along the Camino. Pass Agés (4 km), Atapuerca (7 km), and Orbaneja (15 km). Enter Burgos (26 km) via the historic center. Arrive near the Cathedral of Santa María. From the Cathedral, head to Calle La Puebla, 6, about 300 meters."),
        
        CaminoDestination(day: 13, date: Self.dateFormatter.date(from: "2025-05-14")!, locationName: "Hornillos del Camino", hotelName: "De Sol A Sol", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3390, longitude: -3.9240),
            dailyDistance: 21.0,
            cumulativeDistance: 297.0,
            elevationProfile: [],
            content: "From Hotel Cordón, head west from the city center via Camino signs. Pass Tardajos (10 km) and Rabé de las Calzadas (13 km). Arrive in Hornillos del Camino (21 km). Enter near the main street. From the Camino entrance, head to Calle Cantarranas, 7 Bajo, about 100 meters."),
        
        CaminoDestination(day: 14, date: Self.dateFormatter.date(from: "2025-05-15")!, locationName: "Castrojeriz", hotelName: "A Cien Leguas", 
            coordinate: CLLocationCoordinate2D(latitude: 42.2880, longitude: -4.1380),
            dailyDistance: 20.0,
            cumulativeDistance: 317.0,
            elevationProfile: [],
            content: "From De Sol A Sol, head southwest along the Camino. Pass San Antón ruins (10 km) and Hontanas (6 km). Climb to Alto Mostelares, then descend to Castrojeriz (20 km). Enter near the Church of Santo Domingo. From the Camino entrance, head to Real de Oriente, 78, about 200 meters."),
        
        CaminoDestination(day: 15, date: Self.dateFormatter.date(from: "2025-05-16")!, locationName: "Frómista", hotelName: "Eco Hotel Doña Mayor", 
            coordinate: CLLocationCoordinate2D(latitude: 42.2670, longitude: -4.4060),
            dailyDistance: 25.0,
            cumulativeDistance: 342.0,
            elevationProfile: [],
            content: "From A Cien Leguas, head southwest along the Camino. Cross the Pisuerga River at Itero de la Vega (10 km), pass Boadilla del Camino (18 km), and arrive in Frómista (25 km). Enter near the Church of San Martín. From the Camino entrance, head to Francesa, 31, about 200 meters."),
        
        CaminoDestination(day: 16, date: Self.dateFormatter.date(from: "2025-05-17")!, locationName: "Carrión de los Condes", hotelName: "Hostal La Corte", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3380, longitude: -4.6030),
            dailyDistance: 19.0,
            cumulativeDistance: 361.0,
            elevationProfile: [],
            content: "From Eco Hotel Doña Mayor, head southwest along the Camino. Pass Población de Campos (6 km) and Villalcázar de Sirga (13 km). Arrive in Carrión de los Condes (19 km). Enter near Plaza Mayor. From Plaza Mayor, head to Calle Santa Maria, 32, about 200 meters."),
        
        CaminoDestination(day: 17, date: Self.dateFormatter.date(from: "2025-05-18")!, locationName: "Calzadilla de la Cueza", hotelName: "Hostal Camino Real", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3300, longitude: -4.8020),
            dailyDistance: 17.0,
            cumulativeDistance: 378.0,
            elevationProfile: [],
            content: "From Hostal La Corte, head southwest along the Camino. Cross flat meseta terrain with few services. Arrive in Calzadilla de la Cueza (17 km). Enter near the main street. From the Camino entrance, head to Calle Tras Mayor Cacu, 8, about 100 meters."),
        
        CaminoDestination(day: 18, date: Self.dateFormatter.date(from: "2025-05-19")!, locationName: "Sahagún", hotelName: "Hostal Domus Viatoris", 
            coordinate: CLLocationCoordinate2D(latitude: 42.3710, longitude: -5.0290),
            dailyDistance: 22.0,
            cumulativeDistance: 400.0,
            elevationProfile: [],
            content: "From Hostal Camino Real, head southwest along the Camino. Pass Ledigos (6 km) and Terradillos de los Templarios (10 km). Arrive in Sahagún (22 km) via the historic center. Enter near the Arco de San Benito. From the Camino entrance, head to Travesia del Arco, 25, about 200 meters."),
        
        CaminoDestination(day: 19, date: Self.dateFormatter.date(from: "2025-05-20")!, locationName: "El Burgo Ranero", hotelName: "Hotel Castillo El Burgo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4230, longitude: -5.2210),
            dailyDistance: 18.0,
            cumulativeDistance: 418.0,
            elevationProfile: [],
            content: "From Hostal Domus Viatoris, head southwest along the Camino. Pass Bercianos del Real Camino (10 km). Arrive in El Burgo Ranero (18 km). Enter near the main road. Located at Autovia León-Burgos km 34, near the Camino."),
        
        CaminoDestination(day: 20, date: Self.dateFormatter.date(from: "2025-05-21")!, locationName: "Mansilla de las Mulas", hotelName: "Albergueria del Camino", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.4170),
            dailyDistance: 19.0,
            cumulativeDistance: 437.0,
            elevationProfile: [],
            content: "From Hotel Castillo El Burgo, head southwest along the Camino. Pass Reliegos (6 km). Arrive in Mansilla de las Mulas (19 km) via the old town walls. Enter near Plaza del Grano. From the Camino entrance, head to Calle Concepción 12, about 200 meters."),
        
        CaminoDestination(day: 21, date: Self.dateFormatter.date(from: "2025-05-22")!, locationName: "León", hotelName: "Hotel Alda Vía León", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710),
            dailyDistance: 18.0,
            cumulativeDistance: 455.0,
            elevationProfile: [],
            content: "From Albergueria del Camino, head southwest along the Camino. Pass Puente Castro (12 km) and enter León (18 km) via the historic center. Arrive near the Cathedral of León. From the Cathedral, head to Calle El Paso 5, about 300 meters."),
        
        CaminoDestination(day: 22, date: Self.dateFormatter.date(from: "2025-05-23")!, locationName: "León (Rest Day)", hotelName: "Hotel Alda Vía León", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5980, longitude: -5.5710),
            dailyDistance: 0.0,
            cumulativeDistance: 455.0,
            elevationProfile: [],
            content: "Rest day in León. Take time to explore the historic center, visit the Gothic cathedral with its magnificent stained glass windows, and enjoy the city's excellent cuisine. Your accommodation remains at Hotel Alda Vía León, Calle El Paso 5."),
        
        CaminoDestination(day: 23, date: Self.dateFormatter.date(from: "2025-05-24")!, locationName: "Chozas de Abajo", hotelName: "Albergue San Antonio de Padua", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4980, longitude: -5.6860),
            dailyDistance: 22.0,
            cumulativeDistance: 477.0,
            elevationProfile: [],
            content: "From Hotel Alda Vía León, head southwest, taking the alternate Villar de Mazarife route. Pass La Virgen del Camino (7 km) and diverge to Villar de Mazarife (20 km). Arrive in Chozas de Abajo (22 km). Enter near Camino León. From the Camino, head to Camino León 33, about 100 meters."),
        
        CaminoDestination(day: 24, date: Self.dateFormatter.date(from: "2025-05-25")!, locationName: "Astorga", hotelName: "Hotel Astur Plaza", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4580, longitude: -6.0530),
            dailyDistance: 27.0,
            cumulativeDistance: 504.0,
            elevationProfile: [],
            content: "From Albergue San Antonio de Padua, head southwest along the Camino. Rejoin the main route at Hospital de Órbigo (15 km, bridge), pass Santibáñez de Valdeiglesias (20 km), and arrive in Astorga (27 km). Enter near Plaza de España. Your hotel is located at Plaza España, 2, near the Camino entrance."),
        
        CaminoDestination(day: 25, date: Self.dateFormatter.date(from: "2025-05-26")!, locationName: "Rabanal del Camino", hotelName: "Hotel Rural Casa Indie", 
            coordinate: CLLocationCoordinate2D(latitude: 42.4810, longitude: -6.2840),
            dailyDistance: 20.0,
            cumulativeDistance: 524.0,
            elevationProfile: [],
            content: "From Hotel Astur Plaza, head southwest along the Camino. Pass Santa Catalina de Somoza (8 km) and El Ganso (13 km). Climb to Rabanal del Camino (20 km). Enter near the main street. Check in at Posada El Tesin (town entrance), then proceed to Calle Medio, 4A, about 200 meters."),
        
        CaminoDestination(day: 26, date: Self.dateFormatter.date(from: "2025-05-27")!, locationName: "Ponferrada", hotelName: "Hotel El Castillo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.5460, longitude: -6.5900),
            dailyDistance: 32.0,
            cumulativeDistance: 556.0,
            elevationProfile: [],
            content: "From Hotel Rural Casa Indie, head southwest along the Camino. Climb to Cruz de Ferro (5 km), pass Foncebadón (8 km), and descend via Acebo (16 km). Continue to Molinaseca (25 km) and then to Ponferrada (32 km) near the Templar Castle."),
        
        CaminoDestination(day: 27, date: Self.dateFormatter.date(from: "2025-05-28")!, locationName: "Villafranca del Bierzo", hotelName: "Hostal Tres Campanas", 
            coordinate: CLLocationCoordinate2D(latitude: 42.6060, longitude: -6.8110),
            dailyDistance: 24.0,
            cumulativeDistance: 580.0,
            elevationProfile: [],
            content: "From Hotel El Castillo in Ponferrada, head southwest along the Camino. Pass Cacabelos (15 km) and Pieros (20 km). Arrive in Villafranca del Bierzo (24 km). Enter near the Church of Santiago. From the Camino entrance, head to Avenida de Paradaseca 27, about 300 meters."),
        
        CaminoDestination(day: 28, date: Self.dateFormatter.date(from: "2025-05-29")!, locationName: "O Cebreiro", hotelName: "Casa Navarro", 
            coordinate: CLLocationCoordinate2D(latitude: 42.7080, longitude: -7.0020),
            dailyDistance: 28.0,
            cumulativeDistance: 608.0,
            elevationProfile: [],
            content: "From Hostal Tres Campanas, head west along the Camino. Pass Pereje (5 km), Trabadelo (9 km), and Vega de Valcarce (15 km). Climb steeply to O Cebreiro (28 km). Enter near the church of Santa María la Real. From the village entrance, head to Rúa Cebreiro, 9, about 100 meters."),
        
        CaminoDestination(day: 29, date: Self.dateFormatter.date(from: "2025-05-30")!, locationName: "Triacastela", hotelName: "Complexo Xacobeo", 
            coordinate: CLLocationCoordinate2D(latitude: 42.7560, longitude: -7.2340),
            dailyDistance: 21.0,
            cumulativeDistance: 629.0,
            elevationProfile: [],
            content: "From Casa Navarro, head east along the Camino. Climb to Alto de San Roque (4 km), descend via Liñares (6 km) and Hospital da Condesa (9 km). Arrive in Triacastela (21 km). Enter near the town center. From the Camino entrance, head to Rúa Santiago 8, about 200 meters."),
        
        CaminoDestination(day: 30, date: Self.dateFormatter.date(from: "2025-05-31")!, locationName: "Sarria", hotelName: "Hotel Mar de Plata", 
            coordinate: CLLocationCoordinate2D(latitude: 42.7810, longitude: -7.4140),
            dailyDistance: 18.5,
            cumulativeDistance: 647.5,
            elevationProfile: [],
            content: "From Complexo Xacobeo, head south along the Camino (San Xil route). Ascend to San Xil (6 km), descend via Furela (12 km) and Pintín (15 km). Arrive in Sarria (18.5 km) via Rúa Maior. From Rúa Maior, head to Calle de los Formigueiros 5, about 300 meters."),
        
        CaminoDestination(day: 31, date: Self.dateFormatter.date(from: "2025-06-01")!, locationName: "Portomarín", hotelName: "Casona Da Ponte Portomarín", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8070, longitude: -7.6160),
            dailyDistance: 22.0,
            cumulativeDistance: 669.5,
            elevationProfile: [],
            content: "From Hotel Mar de Plata, head south along Rúa Maior, following Camino signs. Pass Barbadelo (4 km), Ferreiros (10 km), and descend to the Miño River. Cross the bridge and climb to Portomarín (22 km). Enter near the Church of San Nicolás. From the town entrance, head to Camiño da Capela 10, about 200 meters."),
        
        CaminoDestination(day: 32, date: Self.dateFormatter.date(from: "2025-06-02")!, locationName: "Palas de Rei", hotelName: "Hotel Mica", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8730, longitude: -7.8690),
            dailyDistance: 25.0,
            cumulativeDistance: 694.5,
            elevationProfile: [],
            content: "From Casona Da Ponte Portomarín, head east along the Camino. Pass Gonzar (8 km), Castromaior (12 km), and Hospital da Cruz (15 km). Arrive in Palas de Rei (25 km). Enter near the town center. From the Camino entrance, head to Rúa Cruceiro, 12, about 300 meters."),
        
        CaminoDestination(day: 33, date: Self.dateFormatter.date(from: "2025-06-03")!, locationName: "Arzúa", hotelName: "Hotel Arzúa", 
            coordinate: CLLocationCoordinate2D(latitude: 42.9280, longitude: -8.1600),
            dailyDistance: 29.0,
            cumulativeDistance: 723.5,
            elevationProfile: [],
            content: "From Hotel Mica, head east along the Camino. Pass San Xulián (4 km), Melide (14 km, all services), and Boente (20 km). Arrive in Arzúa (29 km). Enter near the town center. From the Camino entrance, head to Rúa Lugo, 132, about 200 meters."),
        
        CaminoDestination(day: 34, date: Self.dateFormatter.date(from: "2025-06-04")!, locationName: "A Rúa", hotelName: "Hotel Rural O Acivro", 
            coordinate: CLLocationCoordinate2D(latitude: 42.9080, longitude: -8.3670),
            dailyDistance: 19.0,
            cumulativeDistance: 742.5,
            elevationProfile: [],
            content: "From Hotel Arzúa, head southwest along the Camino. Pass Preguntoño (5 km), Salceda (11 km), and Santa Irene (15 km). Arrive in A Rúa (19 km), near O Pedrouzo. Enter near the village center. From the Camino, head to Lugar Rúa, 28, about 100 meters."),
        
        CaminoDestination(day: 35, date: Self.dateFormatter.date(from: "2025-06-05")!, locationName: "Santiago de Compostela", hotelName: "Hotel Alda Avenida", 
            coordinate: CLLocationCoordinate2D(latitude: 42.8800, longitude: -8.5450),
            dailyDistance: 20.0,
            cumulativeDistance: 762.5,
            elevationProfile: [],
            content: "From Hotel Rural O Acivro, head southwest along the Camino. Pass O Pedrouzo (2 km), climb to Monte do Gozo (15 km), and descend into Santiago de Compostela (20 km). Enter near Praza do Obradoiro and the Cathedral. From Praza do Obradoiro, head to Rúa Fonte de San Antonio, 5, about 400 meters.")
    ]
    
    public init(day: Int, date: Date, locationName: String, hotelName: String, coordinate: CLLocationCoordinate2D, dailyDistance: Double, cumulativeDistance: Double, elevationProfile: [(distance: Double, elevation: Double)] = [], content: String = "") {
        self.day = day
        self.date = date
        self.locationName = locationName
        self.hotelName = hotelName
        self.coordinate = coordinate
        self.dailyDistance = dailyDistance
        self.cumulativeDistance = cumulativeDistance
        self.elevationProfile = elevationProfile
        self.content = content
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: CaminoDestination, rhs: CaminoDestination) -> Bool {
        lhs.id == rhs.id
    }
} 