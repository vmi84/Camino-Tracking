import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
import SwiftUI

@MainActor
class TranslationService {
    static let shared = TranslationService()
    
    enum TranslationLanguage: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case italian = "it"
        case portuguese = "pt-PT"
        case japanese = "ja"
        case korean = "ko"
        case chinese = "zh"
        case russian = "ru"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Spanish (Castilian)"
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
    
    private init() {
        // Force register all URL schemes right away
        // This improves the chances that canOpenURL will work
        #if os(iOS)
        registerGoogleTranslateSchemes()
        #endif
    }
    
    #if os(iOS)
    private func registerGoogleTranslateSchemes() {
        // Register all possible Google Translate URL schemes
        let schemes = [
            "comgoogletranslate://",
            "googletranslate://",
            "comgoogletranslate-x-callback://"
        ]
        
        for scheme in schemes {
            if let url = URL(string: scheme) {
                let canOpen = UIApplication.shared.canOpenURL(url)
                print("Registered Google Translate URL scheme: \(scheme), can open: \(canOpen)")
            }
        }
    }
    #endif
    
    func openGoogleTranslate(text: String = "", sourceLanguage: String = "auto", targetLanguage: String = "en") {
        print("Attempting to open Google Translate with text: \(text)")
        
        // Try multiple possible URL formats for Google Translate app
        let translationParams = "?source=\(sourceLanguage)&target=\(targetLanguage)"
        let textParam = !text.isEmpty ? "&text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" : ""
        
        #if os(iOS)
        let urlStrings = [
            // Standard format
            "comgoogletranslate://x-callback-url/translate\(translationParams)\(textParam)",
            // Alternative format without x-callback
            "comgoogletranslate:///translate\(translationParams)\(textParam)",
            // Alternative app identifier
            "googletranslate://x-callback-url/translate\(translationParams)\(textParam)",
            // Simplified format
            "comgoogletranslate://translate\(translationParams)\(textParam)"
        ]
        
        // Create the web fallback URL in advance
        let webURL = createGoogleTranslateWebURL(text: text, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        
        // Start an async task to try all available app URLs first
        Task {
            var appOpened = false
            
            // Try each URL format until one works
            for urlString in urlStrings {
                if let appURL = URL(string: urlString) {
                    print("Trying to open app URL: \(urlString)")
                    appOpened = await openURL(appURL)
                    
                    if appOpened {
                        print("Successfully opened Google Translate app with URL: \(urlString)")
                        break
                    }
                }
            }
            
            // If no app URL worked, fall back to web
            if !appOpened {
                print("Could not open Google Translate app with any URL format, falling back to web version")
                _ = await openURL(webURL)
            }
        }
        #else
        // macOS version - just use web URL
        let webURL = createGoogleTranslateWebURL(text: text, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        openWebURL(webURL)
        #endif
    }
    
    #if os(iOS)
    private func openURL(_ url: URL) async -> Bool {
        return await withCheckedContinuation { continuation in
            // We're already on the main actor, so this is safe
            UIApplication.shared.open(url, options: [:]) { success in
                print("URL opening result for \(url.absoluteString): \(success)")
                continuation.resume(returning: success)
            }
        }
    }
    #endif
    
    #if os(macOS)
    private func openWebURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
    #endif
    
    private func createGoogleTranslateWebURL(text: String, sourceLanguage: String, targetLanguage: String) -> URL {
        print("Creating Google Translate web URL")
        var urlComponents = URLComponents(string: "https://translate.google.com/")!
        urlComponents.queryItems = [
            URLQueryItem(name: "sl", value: sourceLanguage),
            URLQueryItem(name: "tl", value: targetLanguage),
            URLQueryItem(name: "op", value: "translate")
        ]
        
        if !text.isEmpty {
            urlComponents.queryItems?.append(
                URLQueryItem(name: "text", value: text)
            )
        }
        
        return urlComponents.url!
    }
    
    // For translating destination information (location and hotel name)
    func openGoogleTranslateForDestination(location: String, hotel: String?, targetLanguage: String = "en") {
        let textToTranslate: String
        if let hotel = hotel, !hotel.isEmpty {
            textToTranslate = "\(location) - \(hotel)"
        } else {
            textToTranslate = location
        }
        
        openGoogleTranslate(text: textToTranslate, sourceLanguage: "auto", targetLanguage: targetLanguage)
    }
} 