import Foundation
#if canImport(SwiftyJSON)
import SwiftyJSON

/// A simple helper class for working with JSON data
class JSONHelper {
    
    /// Parses JSON data and returns a SwiftyJSON object
    /// - Parameter data: The data to parse
    /// - Returns: A JSON object or nil if parsing fails
    static func parse(data: Data) -> JSON? {
        do {
            return try JSON(data: data)
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Converts a dictionary to JSON
    /// - Parameter dict: The dictionary to convert
    /// - Returns: A JSON object
    static func fromDictionary(_ dict: [String: Any]) -> JSON {
        return JSON(dict)
    }
    
    /// Converts JSON to a string
    /// - Parameter json: The JSON object
    /// - Returns: A string representation of the JSON
    static func toString(_ json: JSON) -> String? {
        return json.rawString()
    }
}
#else
// Fallback implementation when SwiftyJSON is not available
class JSONHelper {
    static func parse(data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> [String: Any] {
        return dict
    }
    
    static func toString(_ json: [String: Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error converting to string: \(error.localizedDescription)")
            return nil
        }
    }
}
#endif 