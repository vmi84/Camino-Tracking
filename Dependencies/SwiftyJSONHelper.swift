import Foundation
import SwiftyJSON

// This file is a helper to ensure SwiftyJSON is correctly linked
// It provides a thin wrapper around SwiftyJSON functionality to make it 
// easily accessible throughout the app

public class SwiftyJSONHelper {
    public static func parse(jsonString: String) -> JSON? {
        if let data = jsonString.data(using: .utf8) {
            return try? JSON(data: data)
        }
        return nil
    }
    
    public static func parse(data: Data) -> JSON? {
        return try? JSON(data: data)
    }
    
    public static func createJSON(from dictionary: [String: Any]) -> JSON {
        return JSON(dictionary)
    }
} 