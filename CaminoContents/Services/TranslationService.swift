import Foundation
import UIKit
import SwiftUI

class TranslationService {
    static let shared = TranslationService()
    
    enum TranslationLanguage: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case italian = "it"
        case portuguese = "pt"
        case japanese = "ja"
        case korean = "ko"
        case chinese = "zh"
        case russian = "ru"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Spanish"
            case .french: return "French"
            case .german: return "German"
            case .italian: return "Italian"
            case .portuguese: return "Portuguese"
            case .japanese: return "Japanese"
            case .korean: return "Korean"
            case .chinese: return "Chinese"
            case .russian: return "Russian"
            }
        }
    }
    
    private init() {}
    
    func openGoogleTranslate(text: String, sourceLanguage: String = "auto", targetLanguage: String = "en") {
        guard let escapedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode text for URL")
            return
        }
        
        let urlString = "https://translate.google.com/?sl=\(sourceLanguage)&tl=\(targetLanguage)&text=\(escapedText)&op=translate"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
} 