import Foundation

public enum Language: String, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt-PT"
    case basque = "eu"
    case galician = "gl"
    
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .basque: return "Euskara"
        case .galician: return "Galego"
        }
    }
    
    public var locale: Locale {
        Locale(identifier: self.rawValue)
    }
} 