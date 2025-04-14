import SwiftUI
import Charts
import MapKit
import CoreLocation
#if canImport(CaminoModels)
#if canImport(CaminoModels)
import CaminoModels
#endif
#endif

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// Helper function to format elevation data into a human-readable string
private func formatElevationData(ascent: Int, descent: Int, useMetric: Bool = true) -> some View {
    let ascentValue = useMetric ? "\(ascent) m" : "\(Int(Double(ascent) * 3.28084)) ft"
    let descentValue = useMetric ? "\(descent) m" : "\(Int(Double(descent) * 3.28084)) ft"
    
    return HStack(spacing: 16) {
        Label(ascentValue, systemImage: "arrow.up")
            .foregroundColor(.orange)
        Label(descentValue, systemImage: "arrow.down")
            .foregroundColor(.blue)
    }
    .font(.callout)
}

struct StageProfileView: View {
    let day: Int
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    
    var body: some View {
        // Using a helper method to create the profile view
        let elevationImage = makeElevationImage()
        
        return VStack(alignment: .leading, spacing: 8) {
            // Route title if available
            let routeTitle = getRouteTitleForDay(day)
            if !routeTitle.isEmpty && day > 0 {
                Text(routeTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            
            // Elevation data if available
            let (ascent, descent) = getElevationForDay(day)
            if ascent > 0 || descent > 0 {
                formatElevationData(ascent: ascent, descent: descent, useMetric: useMetricUnits)
                    .padding(.horizontal)
            }
            
            // Main elevation image or placeholder
            elevationImage
        }
        .padding(.vertical, 8)
    }
    
    // Function to create a placeholder for any day
    private func createElevationPlaceholder(for day: Int) -> some View {
        let (ascent, descent) = getElevationForDay(day)
        let routeTitle = getRouteTitleForDay(day)
        let routeParts = routeTitle.components(separatedBy: " to ")
        let startLocation = routeParts.first ?? ""
        let endLocation = routeParts.count > 1 ? routeParts[1] : ""
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("ELEVATION PROFILE")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("↑ \(ascent) m · ↓ \(descent) m")
                    .font(.subheadline)
                    .padding(.horizontal)
                
                ZStack {
                    // Background gradient simulating elevation
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.1),
                            Color.blue.opacity(0.2),
                            Color.blue.opacity(0.3)
                        ]), 
                        startPoint: .bottom, 
                        endPoint: .top
                    )
                    .frame(height: 200)
                    .overlay(
                        // Generate elevation line pattern based on elevation data
                        Path { path in
                            let width = getScreenWidth()
                            let baseHeight: CGFloat = 170
                            // Pre-calculate scales to potentially help type checker
                            let effectiveAscent = max(ascent, 1) // Avoid division by zero or negative scale
                            let effectiveDescent = max(descent, 1)
                            let heightScale = CGFloat(min(effectiveAscent, 1500)) / 1500.0
                            let descentScale = CGFloat(min(effectiveDescent, 1500)) / 1500.0

                            path.move(to: CGPoint(x: 0, y: baseHeight))
                            
                            // Slope based on ascent/descent ratio (comparing Ints)
                            if ascent > Int(Double(descent) * 1.5) {
                                // Heavy ascent
                                path.addLine(to: CGPoint(x: width * 0.3, y: baseHeight - 40 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.5, y: baseHeight - 130 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.7, y: baseHeight - 160 * heightScale))
                                path.addLine(to: CGPoint(x: width, y: baseHeight - 150 * heightScale))
                            } else if descent > Int(Double(ascent) * 1.5) {
                                // Heavy descent
                                path.addLine(to: CGPoint(x: width * 0.3, y: baseHeight - 150 * descentScale))
                                path.addLine(to: CGPoint(x: width * 0.5, y: baseHeight - 130 * descentScale))
                                path.addLine(to: CGPoint(x: width * 0.7, y: baseHeight - 80 * descentScale))
                                path.addLine(to: CGPoint(x: width, y: baseHeight - 20 * descentScale))
                            } else if ascent > 500 && descent > 500 {
                                // Varied terrain
                                path.addLine(to: CGPoint(x: width * 0.2, y: baseHeight - 70 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.4, y: baseHeight - 140 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.6, y: baseHeight - 120 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.8, y: baseHeight - 150 * heightScale))
                                path.addLine(to: CGPoint(x: width, y: baseHeight - 80 * descentScale))
                            } else if ascent < 200 && descent < 200 {
                                // Relatively flat
                                path.addLine(to: CGPoint(x: width * 0.2, y: baseHeight - 30))
                                path.addLine(to: CGPoint(x: width * 0.4, y: baseHeight - 50))
                                path.addLine(to: CGPoint(x: width * 0.6, y: baseHeight - 40))
                                path.addLine(to: CGPoint(x: width * 0.8, y: baseHeight - 60))
                                path.addLine(to: CGPoint(x: width, y: baseHeight - 50))
                            } else {
                                // Default pattern with moderate terrain
                                path.addLine(to: CGPoint(x: width * 0.3, y: baseHeight - 60 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.5, y: baseHeight - 100 * heightScale))
                                path.addLine(to: CGPoint(x: width * 0.7, y: baseHeight - 80 * heightScale))
                                path.addLine(to: CGPoint(x: width, y: baseHeight - 70 * descentScale))
                            }
                        }
                        .stroke(Color.blue, lineWidth: 3)
                    )
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        VStack(alignment: .leading) {
                            Spacer()
                            HStack {
                                Text(startLocation)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.green)
                                Spacer()
                                Text(endLocation)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 6)
                        }
                    )
                }
            }
        }
    }
    
    // Helper method to create the elevation image with consistent return type
    private func makeElevationImage() -> some View {
        Group {
            // First try to load from the external directory for any day
            if let uiImage = loadElevationProfileImage(for: day) {
                // Return the external image if available
                if day == 1 {
                    // Special styling for Day 1 with Santiago Ways branding
                    VStack(alignment: .leading, spacing: 0) {
                        // Green header bar with title
                        HStack {
                            Rectangle()
                                .fill(Color(red: 0.53, green: 0.73, blue: 0.21)) // Santiago Ways green
                                .frame(width: 16, height: 40)
                            
                            Text("ST JEAN PIED DE PORT - RONCESVALLES")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.53, green: 0.73, blue: 0.21))
                            
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        
                        // Option A subtitle
                        Text("OPTION A: VIA ORISSON")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.53, green: 0.73, blue: 0.21))
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        // Route map label
                        HStack {
                            Text("ROUTE MAP")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding(.bottom, 2)
                        
                        // The map image
                        #if os(iOS)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        #elseif os(macOS)
                        // On macOS, we need a different approach since UIImage is not available
                        // Instead we'll use a placeholder or load an image by name if needed
                        Image(systemName: "map")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                        #endif
                        
                        // Stage profile section
                        VStack(alignment: .leading, spacing: 2) {
                            Text("STAGE PROFILE")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.53, green: 0.73, blue: 0.21))
                                .padding(.top, 8)
                                .padding(.horizontal)
                            
                            Text("↑ 1282 m · ↓ 504 m")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.bottom, 4)
                            
                            // Blue elevation profile
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue.opacity(0.5))
                                .frame(height: 100)
                                .padding(.horizontal)
                                .overlay(
                                    ZStack {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text("ST JEAN")
                                                        .font(.caption2)
                                                        .foregroundColor(Color(red: 0.53, green: 0.73, blue: 0.21))
                                                    Text("PIED DE PORT")
                                                        .font(.caption2)
                                                        .foregroundColor(Color(red: 0.53, green: 0.73, blue: 0.21))
                                                }
                                                Spacer()
                                                Text("RONCESVALLES")
                                                    .font(.caption2)
                                                    .foregroundColor(Color(red: 0.53, green: 0.73, blue: 0.21))
                                            }
                                            .padding(.horizontal, 24)
                                            .padding(.bottom, 2)
                                            
                                            HStack {
                                                Text("165 m")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                Spacer()
                                                Text("1419 m")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.horizontal, 24)
                                        }
                                    }
                                )
                        }
                    }
                } else {
                    // Other days just show the image
                    VStack(alignment: .leading, spacing: 4) {
                        #if os(iOS)
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        #elseif os(macOS)
                        Image(systemName: "map")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                        #endif
                    }
                }
            } else if day == 1 {
                // Fallback to placeholder for Day 1
                createDay1Placeholder()
            } else if day > 0 && day <= 35 {
                // Use the dynamic placeholder for days 1-35
                createElevationPlaceholder(for: day)
            } else {
                // For any other day, show a simple message
                Text("Elevation profile not available for Day \(day)")
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
    }
    
    // Helper to get route title for a day
    private func getRouteTitleForDay(_ day: Int) -> String {
        let titles = [
            1: "St Jean Pied de Port to Roncesvalles",
            2: "Roncesvalles to Zubiri",
            3: "Zubiri to Pamplona",
            4: "Pamplona to Puente la Reina",
            5: "Puente la Reina to Estella",
            6: "Estella to Los Arcos",
            7: "Los Arcos to Logroño",
            8: "Logroño to Nájera",
            9: "Nájera to Santo Domingo de la Calzada",
            10: "Santo Domingo de la Calzada to Belorado",
            11: "Belorado to San Juan de Ortega",
            12: "San Juan de Ortega to Burgos",
            13: "Burgos to Hornillos del Camino",
            14: "Hornillos del Camino to Castrojeriz",
            15: "Castrojeriz to Frómista",
            16: "Frómista to Carrión de los Condes",
            17: "Carrión de los Condes to Calzadilla de la Cueza",
            18: "Calzadilla de la Cueza to Sahagún",
            19: "Sahagún to El Burgo Ranero",
            20: "El Burgo Ranero to Mansilla de las Mulas",
            21: "Mansilla de las Mulas to León",
            22: "León (Rest Day)",
            23: "León to Chozas de Abajo",
            24: "Chozas de Abajo to Astorga",
            25: "Astorga to Rabanal del Camino",
            26: "Rabanal del Camino to Ponferrada",
            27: "Ponferrada to Villafranca del Bierzo",
            28: "Villafranca del Bierzo to O Cebreiro",
            29: "O Cebreiro to Triacastela",
            30: "Triacastela to Sarria",
            31: "Sarria to Portomarín",
            32: "Portomarín to Palas de Rei",
            33: "Palas de Rei to Arzúa",
            34: "Arzúa to A Rúa",
            35: "A Rúa to Santiago de Compostela"
        ]
        
        return titles[day] ?? ""
    }
    
    // Helper to get elevation data for a day
    private func getElevationForDay(_ day: Int) -> (Int, Int) {
        let ascents = [
            1: 1282, 2: 217, 3: 72, 4: 419, 5: 345, 6: 310, 7: 150, 8: 185, 9: 220, 10: 170,
            11: 370, 12: 150, 13: 70, 14: 140, 15: 90, 16: 120, 17: 140, 18: 60, 19: 50, 20: 100,
            21: 150, 22: 0, 23: 100, 24: 200, 25: 500, 26: 600, 27: 120, 28: 720, 29: 150, 30: 300,
            31: 380, 32: 270, 33: 180, 34: 240, 35: 180
        ]
        
        let descents = [
            1: 504, 2: 633, 3: 148, 4: 523, 5: 270, 6: 264, 7: 185, 8: 130, 9: 170, 10: 250,
            11: 210, 12: 280, 13: 90, 14: 160, 15: 175, 16: 60, 17: 110, 18: 90, 19: 120, 20: 120,
            21: 50, 22: 0, 23: 90, 24: 160, 25: 90, 26: 900, 27: 160, 28: 120, 29: 570, 30: 400,
            31: 340, 32: 380, 33: 230, 34: 310, 35: 400
        ]
        
        return (ascents[day] ?? 0, descents[day] ?? 0)
    }
    
    // Function to create a placeholder for Day 1
    private func createDay1Placeholder() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STAGE PROFILE")
                .font(.headline)
                .foregroundColor(.green)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("↑ 1282 m · ↓ 504 m")
                    .font(.subheadline)
                    .padding(.horizontal)
                
                ZStack {
                    // Background gradient simulating elevation
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.2),
                            Color.blue.opacity(0.3),
                            Color.blue.opacity(0.5)
                        ]), 
                        startPoint: .bottom, 
                        endPoint: .top
                    )
                    .frame(height: 200)
                    .overlay(
                        // Basic elevation line
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 170))
                            path.addLine(to: CGPoint(x: 100, y: 150))
                            path.addLine(to: CGPoint(x: 200, y: 130))
                            path.addLine(to: CGPoint(x: 300, y: 100))
                            path.addLine(to: CGPoint(x: 400, y: 60))
                            path.addLine(to: CGPoint(x: 500, y: 30))
                            path.addLine(to: CGPoint(x: 600, y: 30))
                        }
                        .stroke(Color.blue, lineWidth: 3)
                    )
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .overlay(
                        VStack(alignment: .leading) {
                            Spacer()
                            HStack {
                                Text("ST JEAN\nPIED DE PORT")
                                    .font(.caption2)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.green)
                                Spacer()
                                Text("RONCESVALLES")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                            HStack {
                                Text("165 m")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("1419 m")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    )
                }
            }
        }
    }
    
    // Function to load the elevation profile image from the bundle
    #if canImport(UIKit)
    private func loadElevationProfileImage(for day: Int) -> UIImage? {
        // Single source of truth - Resources directory
        let resourcesDir = "/Users/jeffwhite/Desktop/Camino/CaminoContents/Resources/ElevationProfileImages"
        
        print("👀 Searching for elevation profile image for day \(day)...")
        
        // Check for variant images, but only use "a" variant 
        // For days where variants exist like day35a.png and day35b.png
        if day >= 35 {
            // First, try the "a" variant
            let aVariantPath = "\(resourcesDir)/day\(day)a.png"
            if FileManager.default.fileExists(atPath: aVariantPath) {
                print("✅ Found 'a' variant elevation image at: \(aVariantPath)")
                return UIImage(contentsOfFile: aVariantPath)
            }
        }
        
        // Standard path for regular days
        let standardPath = "\(resourcesDir)/day\(day).png"
        if FileManager.default.fileExists(atPath: standardPath) {
            print("✅ Found elevation image at: \(standardPath)")
            return UIImage(contentsOfFile: standardPath)
        }
        
        // Try bundle resources as a fallback
        let bundleOptions = [
            (name: "day\(day)", type: "png", dir: "ElevationProfileImages"),
            (name: "day\(day)a", type: "png", dir: "ElevationProfileImages"),
            (name: "Day\(day)", type: "png", dir: "ElevationProfileImages"),
            (name: "day\(day)", type: "jpg", dir: "ElevationProfileImages"),
            (name: "Day\(day)", type: "jpg", dir: "ElevationProfileImages")
        ]
        
        for option in bundleOptions {
            if let path = Bundle.main.path(forResource: option.name, ofType: option.type, inDirectory: option.dir) {
                print("✅ Found bundle resource at: \(path)")
                return UIImage(contentsOfFile: path)
            }
        }
        
        // Last resort - try asset catalog
        let image = UIImage(named: "day\(day)") ?? UIImage(named: "day\(day)a")
        if image != nil {
            print("✅ Found image in asset catalog for day \(day)")
            return image
        }
        
        print("⚠️ No elevation profile image found for day \(day)")
        return nil
    }
    #elseif canImport(AppKit)
    private func loadElevationProfileImage(for day: Int) -> NSImage? {
        // Single source of truth - Resources directory
        let resourcesDir = "/Users/jeffwhite/Desktop/Camino/CaminoContents/Resources/ElevationProfileImages"
        
        print("👀 Searching for elevation profile image for day \(day)...")
        
        // Check for variant images, but only use "a" variant
        // For days where variants exist like day35a.png and day35b.png
        if day >= 35 {
            // First, try the "a" variant
            let aVariantPath = "\(resourcesDir)/day\(day)a.png"
            if FileManager.default.fileExists(atPath: aVariantPath) {
                print("✅ Found 'a' variant elevation image at: \(aVariantPath)")
                return NSImage(contentsOfFile: aVariantPath)
            }
        }
        
        // Standard path for regular days
        let standardPath = "\(resourcesDir)/day\(day).png"
        if FileManager.default.fileExists(atPath: standardPath) {
            print("✅ Found elevation image at: \(standardPath)")
            return NSImage(contentsOfFile: standardPath)
        }
        
        // Try bundle resources as a fallback
        let bundleOptions = [
            (name: "day\(day)", type: "png", dir: "ElevationProfileImages"),
            (name: "day\(day)a", type: "png", dir: "ElevationProfileImages"),
            (name: "Day\(day)", type: "png", dir: "ElevationProfileImages"),
            (name: "day\(day)", type: "jpg", dir: "ElevationProfileImages"),
            (name: "Day\(day)", type: "jpg", dir: "ElevationProfileImages")
        ]
        
        for option in bundleOptions {
            if let path = Bundle.main.path(forResource: option.name, ofType: option.type, inDirectory: option.dir) {
                print("✅ Found bundle resource at: \(path)")
                return NSImage(contentsOfFile: path)
            }
        }
        
        // Last resort - try asset catalog
        let image = NSImage(named: "day\(day)") ?? NSImage(named: "day\(day)a")
        if image != nil {
            print("✅ Found image in asset catalog for day \(day)")
            return image
        }
        
        print("⚠️ No elevation profile image found for day \(day)")
        return nil
    }
    #endif
}

// Get screen width for Path drawing
private func getScreenWidth() -> CGFloat {
    #if canImport(UIKit)
    return UIScreen.main.bounds.width - 40
    #elseif canImport(AppKit)
    return NSScreen.main?.visibleFrame.width ?? 400 - 40
    #else
    return 400 - 40 // Default fallback width
    #endif
}

struct RouteDetailView: View {
    let destinationDay: Int
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    
    // Convert destination day to route day, accounting for the rest day in León
    private var routeDay: Int {
        if destinationDay == 0 {
            // Day 0 is the starting point
            return 0
        } else if destinationDay <= 22 {
            // Through León's arrival (day 21)
            return destinationDay
        } else if destinationDay == 22 {
            // Rest day in León (day 22)
            return 21 // Same as previous day
        } else {
            // After León rest day (day 23 and onward)
            return destinationDay - 1
        }
    }
    
    private var routeDetails: RouteDetail? {
        return RouteDetailProvider.getRouteDetail(for: routeDay)
    }
    
    // Helper method to format distances with proper units
    private func formatDistance(_ kilometers: Double?) -> String {
        guard let km = kilometers else { return "" }
        
        if useMetricUnits {
            return "(\(km) km)"
        } else {
            let miles = km * 0.621371
            return "(\(String(format: "%.1f", miles)) mi)"
        }
    }
    
    var body: some View {
        if let details = routeDetails {
            VStack(alignment: .leading, spacing: 16) {
                // Title section
                VStack(alignment: .leading, spacing: 2) {
                    Text("Route Details")
                        .font(.headline)
                    
                    if let routeTitle = details.title {
                        Text(routeTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Day profile with elevation
                    if let ascent = details.ascent, let descent = details.descent {
                        HStack(spacing: 16) {
                            Label("\(ascent) m", systemImage: "arrow.up")
                                .foregroundColor(.orange)
                            Label("\(descent) m", systemImage: "arrow.down")
                                .foregroundColor(.blue)
                        }
                        .font(.callout)
                        .padding(.top, 4)
                    }
                }
                
                Divider()
                
                // For Day 0 (starting point) or Day 22 (rest day), show special message
                if destinationDay == 0 {
                    Text("Starting point of your Camino journey. No walking distance for this day.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else if destinationDay == 22 {
                    Text("Rest day in León. Take time to explore the historic city and its magnificent Cathedral.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    // Start point
                    if let start = details.startPoint {
                        VStack(alignment: .leading, spacing: 4) {
                            Label {
                                Text("Start Point: ") +
                                Text(start.name).bold() +
                                Text(start.distance != nil ? " " + formatDistance(start.distance) : "")
                            } icon: {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .font(.callout)
                            
                            if let services = start.services {
                                Text(services)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 24)
                            }
                            
                            if let details = start.details {
                                Text(details)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 24)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    
                    // Waypoints
                    if let waypoints = details.waypoints, !waypoints.isEmpty {
                        Divider()
                        
                        Text("Key Points Along the Way:")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 4)
                        
                        ForEach(Array(waypoints.enumerated()), id: \.element.name) { index, waypoint in
                            VStack(alignment: .leading, spacing: 4) {
                                Label {
                                    Text(waypoint.name).bold() +
                                    Text(waypoint.distance != nil ? " " + formatDistance(waypoint.distance) : "")
                                } icon: {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.blue)
                                }
                                .font(.callout)
                                
                                if let services = waypoint.services {
                                    Text(services)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                }
                                
                                if let details = waypoint.details {
                                    Text(details)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 24)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                if index != waypoints.count - 1 {
                                    Divider()
                                        .padding(.leading, 24)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // End point
                    if let end = details.endPoint {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label {
                                Text("End Point: ") +
                                Text(end.name).bold() +
                                Text(end.distance != nil ? " " + formatDistance(end.distance) : "")
                            } icon: {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.blue)
                            }
                            .font(.callout)
                            
                            if let services = end.services {
                                Text(services)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 24)
                            }
                            
                            if let details = end.details {
                                Text(details)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 24)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        } else {
            Text("Route details not available for day \(destinationDay)")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.05))
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
        }
    }
}

struct DestinationDetailView: View {
    let destination: CaminoDestination
    
    private var day: Int {
        return destination.day
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                DestinationHeaderView(destination: destination)
                    .padding(.bottom, 8)
                
                // Divider
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Elevation Profile
                if day > 0 && day <= 35 {
                    ElevationProfileView(day: day)
                }
                
                // Route Details
                if day > 0 {
                    RouteDetailView(destinationDay: day)
                        .padding(.horizontal)
                }
                
                // Content
                if let content = destination.content, !content.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About This Location")
                            .font(.headline)
                        
                        Text(content)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.top)
            .padding(.bottom, 24)
        }
        .navigationTitle(day == 0 ? "Starting Point" : "Day \(day)")
    }
}

// MARK: - Helper Views

struct DestinationHeaderView: View {
    let destination: CaminoDestination
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Location Name
            Text(destination.locationName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 32) {
                // Date
                if let date = destination.date {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formatDate(date))
                            .font(.headline)
                    }
                }
                
                // Daily Distance
                if destination.dailyDistance > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Distance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formatDistance(destination.dailyDistance))
                            .font(.headline)
                    }
                }
                
                // Cumulative Distance
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cumulative")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDistance(destination.cumulativeDistance))
                        .font(.headline)
                }
            }
            
            // Hotel Name
            if let hotelName = destination.hotelName, !hotelName.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Accommodation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(hotelName)
                        .font(.headline)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Format the date (now takes Date?)
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Date not available" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long // e.g., "June 15, 2025"
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Format the distance based on unit preference
    private func formatDistance(_ kilometers: Double) -> String {
        if useMetricUnits {
            return String(format: "%.1f km", kilometers)
        } else {
            let miles = kilometers * 0.621371
            return String(format: "%.1f mi", miles)
        }
    }
}

// MARK: - Route Detail Models
struct LocationPoint: Equatable {
    let name: String
    let distance: Double?
    let services: String?
    let details: String?
}

struct RouteDetail {
    let title: String?
    let startPoint: LocationPoint?
    let waypoints: [LocationPoint]?
    let endPoint: LocationPoint?
    let ascent: Int?
    let descent: Int?
}

// MARK: - Route Detail Provider
struct RouteDetailProvider {
    static func getRouteDetail(for day: Int) -> RouteDetail? {
        switch day {
        case 0:
            return RouteDetail(
                title: "Starting Point: Saint Jean Pied de Port",
                startPoint: LocationPoint(
                    name: "Saint Jean Pied de Port",
                    distance: 0.0,
                    services: "All services",
                    details: "Your Camino journey begins here. Explore the historic town center, visit the Pilgrim's Office to obtain your credential, and prepare for tomorrow's challenging first stage."
                ),
                waypoints: [],
                endPoint: nil,
                ascent: 0,
                descent: 0
            )
        case 1:
            return RouteDetail(
                title: "St Jean Pied de Port to Roncesvalles (Option A: Via Orisson)",
                startPoint: LocationPoint(
                    name: "Saint Jean Pied de Port",
                    distance: 0.0,
                    services: "All services",
                    details: "Begin at the medieval bridge over the River Nive, proceed to Rue d'Espagne, turn right after 100 m onto the \"Route de Napoleon\" (steep, follows the Via Aquitaine Roman road)."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Honto",
                        distance: 5.0,
                        services: nil,
                        details: "After Honto, take a left-hand path to avoid a road curve, rejoin the road, and head to Orisson."
                    ),
                    LocationPoint(
                        name: "Orisson",
                        distance: 7.6,
                        services: "Bar, Restaurant",
                        details: "Continue on a low-traffic road through alpine meadows; 4 km ahead, spot the Virgin of Biakorri statue (shepherds' protector) on the left if clear."
                    ),
                    LocationPoint(
                        name: "Arnéguy",
                        distance: 12.7,
                        services: nil,
                        details: "Pass Arnéguy on the right (option to link to Valcarlos), leave the road after 2.0 km for a right-hand path by the Urdanarre Cross."
                    ),
                    LocationPoint(
                        name: "Collado de Bentartea",
                        distance: 16.2,
                        services: "Bentartea Pass",
                        details: "After 1.4 km, reach the pass with Roldán Fountain (commemorates Charlemagne's officer, 778). Follow a beech forest track along the border fence, pass a stone pillar marking Navarre, take a right-hand track along Txangoa and Menditxipi mountains' northern slopes."
                    ),
                    LocationPoint(
                        name: "Collado de Lepoeder",
                        distance: 20.2,
                        services: nil,
                        details: "Two descent options: 1) Direct Route: Steep descent through Mount Donsimon beech forest (caution in fog), go right then left of the road. 2) Ibañeta Pass Route: Divert to Ibañeta Pass (Monument to Roldan, Chapel), descend left of the national road."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Roncesvalles",
                    distance: 23.9,
                    services: "Bar-restaurant, Tourism Office",
                    details: "Arrive via descent into this historic Jacobean town."
                ),
                ascent: 1282,
                descent: 504
            )
        case 2:
            return RouteDetail(
                title: "Roncesvalles to Zubiri",
                startPoint: LocationPoint(
                    name: "Roncesvalles",
                    distance: 0.0,
                    services: "Bar, Restaurant, Tourism Office",
                    details: "Exit on the N-135, take a right-hand path through Sorginaritzaga Forest (oaks, beeches), pass the Cross of the Pilgrims (Gothic, 1880) after 100 m, stay right of the road, turn left at Ipetea industrial park, enter Burguete."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Burguete",
                        distance: 2.8,
                        services: "Bars, Stores, Health Center, Pharmacy, ATM",
                        details: "Cross via the main street, pass the Parish Church of San Nicolas, turn right, cross a footbridge over a stream to the Urrobi River, climb a wooded trail with water sources and a steep hill."
                    ),
                    LocationPoint(
                        name: "Espinal",
                        distance: 6.5,
                        services: "Bar, Store, Medical Clinic",
                        details: "After 2.6 km, enter via a paved path, head right (bar and bakery nearby), follow the sidewalk, turn left after a crosswalk, climb to Mezkiritz."
                    ),
                    LocationPoint(
                        name: "Alto de Mezkiritz",
                        distance: 8.2,
                        services: "924 m",
                        details: "Cross the N-135, see the Virgen of Roncesvalles carving, descend on a wooded trail (some deteriorated), enter a beech forest via a metal gate, reach Bizkarreta."
                    ),
                    LocationPoint(
                        name: "Bizkarreta",
                        distance: 11.5,
                        services: nil,
                        details: "Historic stage end with a former pilgrims' hospital (12th century)."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Zubiri",
                    distance: 21.5,
                    services: "All services",
                    details: "Cross the 14th-century \"Bridge of Rabies\" over the Arga River (Santa Quiteria legend)."
                ),
                ascent: 217,
                descent: 633
            )
        case 3:
            return RouteDetail(
                title: "Zubiri to Pamplona",
                startPoint: LocationPoint(
                    name: "Zubiri",
                    distance: 0.0,
                    services: "All services",
                    details: "Cross the entry bridge, follow the Arga River valley, pass a magnesite factory (1 km), ascend its perimeter, descend stairs, continue on pleasant roads."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Ilarratz",
                        distance: 2.9,
                        services: "Drinking fountain",
                        details: nil
                    ),
                    LocationPoint(
                        name: "Ezkirotz",
                        distance: 3.7,
                        services: "Drinking fountain",
                        details: nil
                    ),
                    LocationPoint(
                        name: "Larrasoaña",
                        distance: 5.5,
                        services: "Bar, Store, Supermarket, Medical Clinic",
                        details: "Exit via the entry bridge, keep the Arga River right, ascend to Akerreta (off-path across the river)."
                    ),
                    LocationPoint(
                        name: "Akerreta",
                        distance: 6.1,
                        services: nil,
                        details: "Pass the Church of the Transfiguration, go by a rural hotel, cross a gate and gravel stretch, reach a local road, cross it, descend to the Arga River shore, follow to Zuriain."
                    ),
                    LocationPoint(
                        name: "Zuriain",
                        distance: 9.2,
                        services: "Bar",
                        details: "Walk beside the N-135 for 600 m, turn left, cross the Arga River."
                    ),
                    LocationPoint(
                        name: "Irotz",
                        distance: 11.2,
                        services: "Bar",
                        details: "Pass the Church of San Pedro, reach the Romanesque Iturgaiz Bridge, choose: Arre (narrow trail to Zabaldika) or Riverside Walk (to Huarte)."
                    ),
                    LocationPoint(
                        name: "Trinidad de Arre",
                        distance: 16.0,
                        services: nil,
                        details: "Cross the medieval bridge over the Ultzama River, turn left."
                    ),
                    LocationPoint(
                        name: "Villava",
                        distance: 16.4,
                        services: "All services",
                        details: "Follow Mayor de Villava Street, cross the road, pass roundabouts, link to Burlada."
                    ),
                    LocationPoint(
                        name: "Burlada",
                        distance: 17.5,
                        services: "All services",
                        details: "Cross Main Street, turn right at a mechanic, cross a pedestrian walkway, follow pavement markers, turn left onto the Camino of Burlada walkway."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Pamplona",
                    distance: 21.8,
                    services: "All services",
                    details: "Cross the Magdalena Bridge over the Arga River, follow the moat (Bastion of Our Lady of Guadalupe), enter via Portal de Francia (1553), proceed through Carmen streets, turn left on De Curia Street."
                ),
                ascent: 72,
                descent: 148
            )
        case 4:
            return RouteDetail(
                title: "Pamplona to Puente la Reina",
                startPoint: LocationPoint(
                    name: "Pamplona",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit via the historic center, climb the Sierra del Perdon (260 m ascent, steeper at the end), pass wind turbines and the Pilgrims' Monument."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Cizur Menor",
                        distance: 5.0,
                        services: "Bar, store",
                        details: "Pass the Church of San Miguel, continue on a paved path."
                    ),
                    LocationPoint(
                        name: "Alto del Perdon",
                        distance: 13.0,
                        services: "770 m",
                        details: "Reach the ridge, descend on a rocky path (caution advised)."
                    ),
                    LocationPoint(
                        name: "Uterga",
                        distance: 16.5,
                        services: "Bar",
                        details: "Enter via a dirt track, continue westward."
                    ),
                    LocationPoint(
                        name: "Obanos",
                        distance: 19.5,
                        services: "Bar, store",
                        details: "Pass the Church of San Juan Bautista, merge with the Aragonés Camino route."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Puente la Reina",
                    distance: 24.0,
                    services: "All services",
                    details: "Cross the iconic 11th-century bridge over the Arga River; optional detour to the Hermitage of Santa Maria de Eunate (2 km off-route)."
                ),
                ascent: 419,
                descent: 523
            )
        case 5:
            return RouteDetail(
                title: "Puente la Reina to Estella",
                startPoint: LocationPoint(
                    name: "Puente la Reina",
                    distance: 0.0,
                    services: "All services",
                    details: "Cross the famous medieval bridge, follow the main road west, and take the path along the Arga River."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Mañeru",
                        distance: 4.6,
                        services: "Bar, store",
                        details: "Village on a hillside, follow main street through the center."
                    ),
                    LocationPoint(
                        name: "Cirauqui",
                        distance: 8.1,
                        services: "Bar, store, pharmacy",
                        details: "Enter through medieval gate, follow steep streets, exit via Roman road."
                    ),
                    LocationPoint(
                        name: "Lorca",
                        distance: 15.5,
                        services: "Bar, water fountain",
                        details: "Small village with fountain, continue straight through."
                    ),
                    LocationPoint(
                        name: "Villatuerta",
                        distance: 18.8,
                        services: "Bar, store",
                        details: "Cross river, follow path up the hill into town."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Estella",
                    distance: 22.5,
                    services: "All services",
                    details: "Historic town with many medieval buildings and churches. Enter via the north bridge and follow signs to the center."
                ),
                ascent: 345,
                descent: 270
            )
        case 6:
            return RouteDetail(
                title: "Estella to Los Arcos",
                startPoint: LocationPoint(
                    name: "Estella",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit via the Monastery of Irache, visit the famous wine fountain (Fuente del Vino)."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Irache",
                        distance: 2.2,
                        services: "Wine fountain, monastery",
                        details: "Pass the notable 12th-century monastery and the wine fountain where pilgrims can take a free drink."
                    ),
                    LocationPoint(
                        name: "Azqueta",
                        distance: 5.7,
                        services: "Bar, water",
                        details: "Small village with pilgrim fountain, continue through main street."
                    ),
                    LocationPoint(
                        name: "Villamayor de Monjardín",
                        distance: 8.1,
                        services: "Bar, fountain",
                        details: "Village at the foot of Mount Monjardín, with the ruins of San Esteban de Deyo Castle above."
                    ),
                    LocationPoint(
                        name: "Luquin",
                        distance: 14.6,
                        services: "Water",
                        details: "Cross fields, follow dirt path through olive groves."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Los Arcos",
                    distance: 21.3,
                    services: "All services",
                    details: "Town centered around the impressive Church of Santa María, with many bars and restaurants in the main square."
                ),
                ascent: 310,
                descent: 264
            )
        case 7:
            return RouteDetail(
                title: "Los Arcos to Logroño",
                startPoint: LocationPoint(
                    name: "Los Arcos",
                    distance: 0.0,
                    services: "All services",
                    details: "Leave town via the west, cross the River Odrón, follow path through vineyards and farmland."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Torres del Río",
                        distance: 7.6,
                        services: "Bar, fountain",
                        details: "Village with an octagonal church (Church of the Holy Sepulchre), continue west."
                    ),
                    LocationPoint(
                        name: "Viana",
                        distance: 17.8,
                        services: "All services",
                        details: "Historic walled town, impressive Church of Santa María, pass by where Cesare Borgia died in 1507."
                    ),
                    LocationPoint(
                        name: "Navarre-La Rioja Border",
                        distance: 20.1,
                        services: nil,
                        details: "Cross from Navarre into La Rioja region, marked by a stone monument."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Logroño",
                    distance: 28.2,
                    services: "All services",
                    details: "Capital of La Rioja, enter via the Stone Bridge (Puente de Piedra), visit the Cathedral of Santa María de la Redonda."
                ),
                ascent: 150,
                descent: 185
            )
        case 8:
            return RouteDetail(
                title: "Logroño to Nájera",
                startPoint: LocationPoint(
                    name: "Logroño",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit through the west side, pass Parque de la Grajera, follow path through vineyards."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Navarrete",
                        distance: 12.9,
                        services: "Bars, restaurants, shops",
                        details: "Town known for pottery, see the Church of the Assumption and Santiago ruins."
                    ),
                    LocationPoint(
                        name: "Ventosa",
                        distance: 18.2,
                        services: "Bar, fountain",
                        details: "Small hill village with views of vineyards, follow main road through town."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Nájera",
                    distance: 29.0,
                    services: "All services",
                    details: "Historic town on the Najerilla River, visit the Monastery of Santa María la Real with royal pantheon."
                ),
                ascent: 185,
                descent: 130
            )
        case 9:
            return RouteDetail(
                title: "Nájera to Santo Domingo de la Calzada",
                startPoint: LocationPoint(
                    name: "Nájera",
                    distance: 0.0,
                    services: "All services",
                    details: "Cross the Najerilla River, climb steadily through grain fields and vineyards."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Azofra",
                        distance: 5.5,
                        services: "Bar, fountain, store",
                        details: "Traditional pilgrim stop with fountain in the main square."
                    ),
                    LocationPoint(
                        name: "Cirueña",
                        distance: 12.0,
                        services: "Bar",
                        details: "Small village near golf course, follow path through fields."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Santo Domingo de la Calzada",
                    distance: 21.0,
                    services: "All services",
                    details: "Named after saint who built bridges for pilgrims, visit the cathedral with live chickens (related to the famous miracle)."
                ),
                ascent: 220,
                descent: 170
            )
        case 10:
            return RouteDetail(
                title: "Santo Domingo de la Calzada to Belorado",
                startPoint: LocationPoint(
                    name: "Santo Domingo de la Calzada",
                    distance: 0.0,
                    services: "All services",
                    details: "Exit via the east, pass stone crosses marking the way, enter the province of Burgos."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Grañón",
                        distance: 6.2,
                        services: "Bar, fountain",
                        details: "Last village in La Rioja, Church of San Juan Bautista with panoramic views."
                    ),
                    LocationPoint(
                        name: "Redecilla del Camino",
                        distance: 7.8,
                        services: "Bar, fountain",
                        details: "First village in Castilla y León region, 12th-century baptismal font in the Church of La Virgen de la Calle."
                    ),
                    LocationPoint(
                        name: "Viloria de Rioja",
                        distance: 9.3,
                        services: "Water",
                        details: "Birthplace of Santo Domingo, small village with stone houses."
                    ),
                    LocationPoint(
                        name: "Villamayor del Río",
                        distance: 12.7,
                        services: "Bar",
                        details: "Small village with single main street, continue along the N-120."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Belorado",
                    distance: 22.7,
                    services: "All services",
                    details: "Medieval town with arcaded Plaza Mayor, visit the Church of Santa María and the ethnographic museum."
                ),
                ascent: 170,
                descent: 250
            )
        // Update the templated cases to include all days
        case 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33:
            // For days we haven't explicitly coded yet, create basic route details with key stopping points
            let titles = [
                11: "Belorado to San Juan de Ortega",
                12: "San Juan de Ortega to Burgos",
                13: "Burgos to Hornillos del Camino",
                14: "Hornillos del Camino to Castrojeriz",
                15: "Castrojeriz to Frómista",
                16: "Frómista to Carrión de los Condes",
                17: "Carrión de los Condes to Calzadilla de la Cueza",
                18: "Calzadilla de la Cueza to Sahagún",
                19: "Sahagún to El Burgo Ranero",
                20: "El Burgo Ranero to Mansilla de las Mulas",
                21: "Mansilla de las Mulas to León",
                22: "León (Rest Day)",
                23: "León to Chozas de Abajo",
                24: "Chozas de Abajo to Astorga",
                25: "Astorga to Rabanal del Camino",
                26: "Rabanal del Camino to Ponferrada",
                27: "Ponferrada to Villafranca del Bierzo",
                28: "Villafranca del Bierzo to O Cebreiro",
                29: "O Cebreiro to Triacastela",
                30: "Triacastela to Sarria",
                31: "Sarria to Portomarín",
                32: "Portomarín to Palas de Rei",
                33: "Palas de Rei to Arzúa"
            ]
            
            let distances = [
                11: 24.0,
                12: 25.3,
                13: 21.0,
                14: 20.0,
                15: 25.0,
                16: 19.5,
                17: 17.0,
                18: 22.0,
                19: 18.0,
                20: 19.0,
                21: 18.0,
                22: 0.0,  // Rest day
                23: 22.0,
                24: 27.0,
                25: 20.0,
                26: 32.0,
                27: 24.0,
                28: 28.0,
                29: 21.0,
                30: 18.5,
                31: 22.0,
                32: 25.0,
                33: 29.0
            ]
            
            let ascents = [
                11: 370,
                12: 150,
                13: 70,
                14: 140,
                15: 90,
                16: 120,
                17: 140,
                18: 60,
                19: 50,
                20: 100,
                21: 150,
                22: 0,    // Rest day
                23: 100,
                24: 200,
                25: 500,
                26: 600,
                27: 120,
                28: 720,
                29: 150,
                30: 300,
                31: 380,
                32: 270,
                33: 180
            ]
            
            let descents = [
                11: 210,
                12: 280,
                13: 90,
                14: 160,
                15: 175,
                16: 60,
                17: 110,
                18: 90,
                19: 120,
                20: 120,
                21: 50,
                22: 0,    // Rest day
                23: 90,
                24: 160,
                25: 90,
                26: 900,
                27: 160,
                28: 120,
                29: 570,
                30: 400,
                31: 340,
                32: 380,
                33: 230
            ]
            
            // Create placeholder route details with basic information
            if let title = titles[day], let distance = distances[day] {
                let startPlace = title.components(separatedBy: " to ")[0]
                let endPlace = day == 22 ? "León (Rest Day)" : title.components(separatedBy: " to ")[1]
                
                if day == 22 {
                    // Special handling for rest day
                    return RouteDetail(
                        title: title,
                        startPoint: LocationPoint(
                            name: "León",
                            distance: 0.0,
                            services: "All services",
                            details: "Rest day in León. Take time to explore the historic center, visit the Gothic cathedral with its magnificent stained glass windows, and enjoy the city's excellent cuisine."
                        ),
                        waypoints: [],
                        endPoint: nil,
                        ascent: 0,
                        descent: 0
                    )
                }
                
                return RouteDetail(
                    title: title,
                    startPoint: LocationPoint(
                        name: startPlace,
                        distance: 0.0,
                        services: "Various services",
                        details: "Starting point for day \(day) of the Camino journey."
                    ),
                    waypoints: [
                        LocationPoint(
                            name: "Midpoint",
                            distance: distance / 2,
                            services: "Water, rest area",
                            details: "Approximately halfway point of today's journey."
                        )
                    ],
                    endPoint: LocationPoint(
                        name: endPlace,
                        distance: distance,
                        services: "Various services",
                        details: "End of day \(day) on the Camino journey."
                    ),
                    ascent: ascents[day],
                    descent: descents[day]
                )
            }
            
            return nil
            
        case 34:
            return RouteDetail(
                title: "Arzúa to A Rúa (near O Pedrouzo)",
                startPoint: LocationPoint(
                    name: "Arzúa",
                    distance: 0.0,
                    services: "All services",
                    details: "From Hotel Arzúa, head southwest along the Camino on the penultimate stage of your journey."
                ),
                waypoints: [
                    LocationPoint(
                        name: "Preguntoño",
                        distance: 5.0,
                        services: "Water fountain",
                        details: "Small hamlet with water fountain."
                    ),
                    LocationPoint(
                        name: "Salceda",
                        distance: 11.0,
                        services: "Bar, fountain",
                        details: "Village with services for pilgrims."
                    ),
                    LocationPoint(
                        name: "Santa Irene",
                        distance: 15.0,
                        services: "Albergue, fountain",
                        details: "Small hamlet with pilgrim accommodations."
                    )
                ],
                endPoint: LocationPoint(
                    name: "A Rúa",
                    distance: 19.0,
                    services: "Various services",
                    details: "Village near O Pedrouzo, your stop before the final stage to Santiago."
                ),
                ascent: 240,
                descent: 310
            )
            
        case 35:
            return RouteDetail(
                title: "A Rúa to Santiago de Compostela",
                startPoint: LocationPoint(
                    name: "A Rúa",
                    distance: 0.0,
                    services: "Basic services",
                    details: "From Hotel Rural O Acivro, head southwest along the Camino for your final stage."
                ),
                waypoints: [
                    LocationPoint(
                        name: "O Pedrouzo",
                        distance: 2.0,
                        services: "All services",
                        details: "Major stop with all services for pilgrims."
                    ),
                    LocationPoint(
                        name: "Amenal",
                        distance: 7.0,
                        services: "Bar",
                        details: "Small village along the route."
                    ),
                    LocationPoint(
                        name: "San Paio",
                        distance: 12.0,
                        services: "Water fountain",
                        details: "Continue through eucalyptus forests."
                    ),
                    LocationPoint(
                        name: "Monte do Gozo",
                        distance: 15.0,
                        services: "Monument, viewpoint",
                        details: "Hill of Joy, first glimpse of Santiago Cathedral's spires. Large monument commemorating Pope John Paul II's visit."
                    )
                ],
                endPoint: LocationPoint(
                    name: "Santiago de Compostela",
                    distance: 20.0,
                    services: "All services",
                    details: "Final destination of your Camino journey. Enter through the old town to reach the magnificent Cathedral and Praza do Obradoiro."
                ),
                ascent: 180,
                descent: 400
            )
            
        default:
            return nil
        }
    }
    
    // Helper to get route title for a day
    private func getRouteTitleForDay(_ day: Int) -> String {
        let titles = [
            1: "St Jean Pied de Port to Roncesvalles",
            2: "Roncesvalles to Zubiri",
            3: "Zubiri to Pamplona",
            4: "Pamplona to Puente la Reina",
            5: "Puente la Reina to Estella",
            6: "Estella to Los Arcos",
            7: "Los Arcos to Logroño",
            8: "Logroño to Nájera",
            9: "Nájera to Santo Domingo de la Calzada",
            10: "Santo Domingo de la Calzada to Belorado",
            11: "Belorado to San Juan de Ortega",
            12: "San Juan de Ortega to Burgos",
            13: "Burgos to Hornillos del Camino",
            14: "Hornillos del Camino to Castrojeriz",
            15: "Castrojeriz to Frómista",
            16: "Frómista to Carrión de los Condes",
            17: "Carrión de los Condes to Calzadilla de la Cueza",
            18: "Calzadilla de la Cueza to Sahagún",
            19: "Sahagún to El Burgo Ranero",
            20: "El Burgo Ranero to Mansilla de las Mulas",
            21: "Mansilla de las Mulas to León",
            22: "León (Rest Day)",
            23: "León to Chozas de Abajo",
            24: "Chozas de Abajo to Astorga",
            25: "Astorga to Rabanal del Camino",
            26: "Rabanal del Camino to Ponferrada",
            27: "Ponferrada to Villafranca del Bierzo",
            28: "Villafranca del Bierzo to O Cebreiro",
            29: "O Cebreiro to Triacastela",
            30: "Triacastela to Sarria",
            31: "Sarria to Portomarín",
            32: "Portomarín to Palas de Rei",
            33: "Palas de Rei to Arzúa",
            34: "Arzúa to A Rúa",
            35: "A Rúa to Santiago de Compostela"
        ]
        
        return titles[day] ?? "Day \(day) of the Camino journey"
    }
}

// View for showing the elevation profile in destination detail
struct ElevationProfileView: View {
    let day: Int
    
    // Determine the best image name to use (preferring 'a' variant)
    private var imageName: String {
        let variantName = "day\\(day)a"
        if imageExistsInAssets(named: variantName) {
            return variantName // Use dayNa if it exists
        }
        return "day\\(day)" // Fallback to dayN
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Elevation Profile")
                .font(.headline)
                .padding(.horizontal)
            
            // Use the determined image name
            let currentImageName = imageName
            
            // Display Image if it exists, otherwise placeholder
            if imageExistsInAssets(named: currentImageName) {
                Image(currentImageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
            } else {
                // Fallback to placeholder if neither dayNa nor dayN exists
                createElevationPlaceholder(for: day)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    // Check if an image exists in the main bundle's asset catalog
    private func imageExistsInAssets(named name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #elseif canImport(AppKit)
        return NSImage(named: name) != nil
        #else
        return false // Platform not supported
        #endif
    }

    // Helper to get elevation data for a day
    private func getElevationForDay(_ day: Int) -> (Int, Int) {
        let ascents = [
            1: 1282, 2: 217, 3: 72, 4: 419, 5: 345, 6: 310, 7: 150, 8: 185, 9: 220, 10: 170,
            11: 370, 12: 150, 13: 70, 14: 140, 15: 90, 16: 120, 17: 140, 18: 60, 19: 50, 20: 100,
            21: 150, 22: 0, 23: 100, 24: 200, 25: 500, 26: 600, 27: 120, 28: 720, 29: 150, 30: 300,
            31: 380, 32: 270, 33: 180, 34: 240, 35: 180
        ]
        
        let descents = [
            1: 504, 2: 633, 3: 148, 4: 523, 5: 270, 6: 264, 7: 185, 8: 130, 9: 170, 10: 250,
            11: 210, 12: 280, 13: 90, 14: 160, 15: 175, 16: 60, 17: 110, 18: 90, 19: 120, 20: 120,
            21: 50, 22: 0, 23: 90, 24: 160, 25: 90, 26: 900, 27: 160, 28: 120, 29: 570, 30: 400,
            31: 340, 32: 380, 33: 230, 34: 310, 35: 400
        ]
        
        return (ascents[day] ?? 0, descents[day] ?? 0)
    }
    
    // Helper to get screen width for Path drawing
    private func getScreenWidth() -> CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.bounds.width - 40
        #elseif canImport(AppKit)
        return NSScreen.main?.visibleFrame.width ?? 400 - 40
        #else
        return 400 - 40 // Default fallback width
        #endif
    }
    
    // Create a placeholder with elevation visualization
    private func createElevationPlaceholder(for day: Int) -> some View {
        let (ascent, descent) = getElevationForDay(day)
        let routeTitle = getRouteTitleForDay(day)
        let routeParts = routeTitle.components(separatedBy: " to ")
        let startLocation = routeParts.first ?? ""
        let endLocation = routeParts.count > 1 ? routeParts[1] : ""
        
        return VStack(alignment: .leading, spacing: 2) {
            Text("↑ \(ascent) m · ↓ \(descent) m")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.blue.opacity(0.2),
                        Color.blue.opacity(0.3)
                    ]), 
                    startPoint: .bottom, 
                    endPoint: .top
                )
                .overlay(
                    // Generate elevation line pattern based on elevation data
                    Path { path in
                        let width = getScreenWidth()
                        let baseHeight: CGFloat = 170
                        // Pre-calculate scales to potentially help type checker
                        let effectiveAscent = max(ascent, 1) // Avoid division by zero or negative scale
                        let effectiveDescent = max(descent, 1)
                        let heightScale = CGFloat(min(effectiveAscent, 1500)) / 1500.0
                        let descentScale = CGFloat(min(effectiveDescent, 1500)) / 1500.0

                        path.move(to: CGPoint(x: 0, y: baseHeight))
                        
                        // Slope based on ascent/descent ratio (comparing Ints)
                        if ascent > Int(Double(descent) * 1.5) {
                            // Heavy ascent
                            path.addLine(to: CGPoint(x: width * 0.3, y: baseHeight - 40 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.5, y: baseHeight - 130 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.7, y: baseHeight - 160 * heightScale))
                            path.addLine(to: CGPoint(x: width, y: baseHeight - 150 * heightScale))
                        } else if descent > Int(Double(ascent) * 1.5) {
                            // Heavy descent
                            path.addLine(to: CGPoint(x: width * 0.3, y: baseHeight - 150 * descentScale))
                            path.addLine(to: CGPoint(x: width * 0.5, y: baseHeight - 130 * descentScale))
                            path.addLine(to: CGPoint(x: width * 0.7, y: baseHeight - 80 * descentScale))
                            path.addLine(to: CGPoint(x: width, y: baseHeight - 20 * descentScale))
                        } else if ascent > 500 && descent > 500 {
                            // Varied terrain
                            path.addLine(to: CGPoint(x: width * 0.2, y: baseHeight - 70 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.4, y: baseHeight - 140 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.6, y: baseHeight - 120 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.8, y: baseHeight - 150 * heightScale))
                            path.addLine(to: CGPoint(x: width, y: baseHeight - 80 * descentScale))
                        } else if ascent < 200 && descent < 200 {
                            // Relatively flat
                            path.addLine(to: CGPoint(x: width * 0.2, y: baseHeight - 30))
                            path.addLine(to: CGPoint(x: width * 0.4, y: baseHeight - 50))
                            path.addLine(to: CGPoint(x: width * 0.6, y: baseHeight - 40))
                            path.addLine(to: CGPoint(x: width * 0.8, y: baseHeight - 60))
                            path.addLine(to: CGPoint(x: width, y: baseHeight - 50))
                        } else {
                            // Default pattern with moderate terrain
                            path.addLine(to: CGPoint(x: width * 0.3, y: baseHeight - 60 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.5, y: baseHeight - 100 * heightScale))
                            path.addLine(to: CGPoint(x: width * 0.7, y: baseHeight - 80 * heightScale))
                            path.addLine(to: CGPoint(x: width, y: baseHeight - 70 * descentScale))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 3)
                )
                .cornerRadius(12)
                .shadow(radius: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text(startLocation)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.green)
                            Spacer()
                            Text(endLocation)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    }
                )
            }
            .frame(height: 150)
        }
    }
    
    // Helper to get route title for a day
    private func getRouteTitleForDay(_ day: Int) -> String {
        let titles = [
            1: "St Jean Pied de Port to Roncesvalles",
            2: "Roncesvalles to Zubiri",
            3: "Zubiri to Pamplona",
            4: "Pamplona to Puente la Reina",
            5: "Puente la Reina to Estella",
            6: "Estella to Los Arcos",
            7: "Los Arcos to Logroño",
            8: "Logroño to Nájera",
            9: "Nájera to Santo Domingo de la Calzada",
            10: "Santo Domingo de la Calzada to Belorado",
            11: "Belorado to San Juan de Ortega",
            12: "San Juan de Ortega to Burgos",
            13: "Burgos to Hornillos del Camino",
            14: "Hornillos del Camino to Castrojeriz",
            15: "Castrojeriz to Frómista",
            16: "Frómista to Carrión de los Condes",
            17: "Carrión de los Condes to Calzadilla de la Cueza",
            18: "Calzadilla de la Cueza to Sahagún",
            19: "Sahagún to El Burgo Ranero",
            20: "El Burgo Ranero to Mansilla de las Mulas",
            21: "Mansilla de las Mulas to León",
            22: "León (Rest Day)",
            23: "León to Chozas de Abajo",
            24: "Chozas de Abajo to Astorga",
            25: "Astorga to Rabanal del Camino",
            26: "Rabanal del Camino to Ponferrada",
            27: "Ponferrada to Villafranca del Bierzo",
            28: "Villafranca del Bierzo to O Cebreiro",
            29: "O Cebreiro to Triacastela",
            30: "Triacastela to Sarria",
            31: "Sarria to Portomarín",
            32: "Portomarín to Palas de Rei",
            33: "Palas de Rei to Arzúa",
            34: "Arzúa to A Rúa",
            35: "A Rúa to Santiago de Compostela"
        ]
        
        return titles[day] ?? ""
    }
} 

// Previews
#Preview("Day 0") {
    NavigationView {
        // Use index 0 for the starting point preview
        DestinationDetailView(destination: CaminoDestination.allDestinations[0])
    }
}

#Preview("Day 1") {
    NavigationView {
        // Use index 1 for the first stage preview
        DestinationDetailView(destination: CaminoDestination.allDestinations[1])
    }
}

// REMOVED: Preview for Day 35 as it might crash with shim data
// #Preview("Day 35") {
//     NavigationView {
//         DestinationDetailView(destination: CaminoDestination.allDestinations[35])
//     }
// }

#Preview("No Elevation Day") {
    // Example for a day where elevation might not be available or relevant (using index 0)
    NavigationView {
        DestinationDetailView(destination: CaminoDestination.allDestinations[0])
    }
}