import SwiftUI
import AVFoundation
import Speech
#if os(iOS)
import UIKit
#endif

struct TranslationView: View {
    // Translation state
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var isTranslating = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var recentTranslations: [TranslationItem] = []
    @State private var mode: TranslationMode = .translate
    @State private var isDetectingLanguage = false
    @State private var isSpeaking = false
    
    // Language selection
    @State private var sourceLanguage = "en"
    @State private var targetLanguage = "es"
    
    // Speech recognition
    @StateObject private var speechManager = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    // Available languages
    private let availableLanguages = [
        ("en", "English"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("de", "German"),
        ("it", "Italian"),
        ("ja", "Japanese"),
        ("ko", "Korean"),
        ("zh", "Chinese"),
        ("ru", "Russian"),
        ("pt", "Portuguese")
    ]
    
    // Modes for the view
    enum TranslationMode {
        case translate
        case transcribe
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode Selection at the top
                modePicker
                    .padding(.horizontal)
                    .padding(.top)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 16) {
                        // Language selection (only show in translate mode)
                        if mode == .translate {
                            languageSelectionSection
                                .padding(.horizontal)
                        }
                        
                        // Input section
                        inputSection
                            .padding(.horizontal)
                        
                        // Translation/Transcription result
                        resultSection
                            .padding(.horizontal)
                        
                        // Recent translations (only in translate mode)
                        if mode == .translate && !recentTranslations.isEmpty {
                            recentTranslationsSection
                                .padding(.horizontal)
                        }
                        
                        // MARK: - Apple Translation API Note
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Note for iOS 17+ Users")
                                .font(.caption)
                                .bold()
                            
                            Text("This app uses a simplified dictionary-based translation. For better results, consider using Apple's native Translation API available in iOS 17+.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.primary.opacity(0.025))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                Spacer()
            }
            .navigationTitle(mode == .translate ? "Translation" : "Transcription")
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                requestSpeechAuthorization()
            }
            .onChange(of: speechManager.transcribedText) { oldValue, newText in
                // Update input text with transcription
                inputText = newText
                
                // In transcribe mode, directly update result
                if mode == .transcribe {
                    translatedText = newText
                }
                
                // In translate mode with real-time translation enabled,
                // translate as user speaks
                if mode == .translate && !newText.isEmpty {
                    // Translate continuously as the person speaks
                    translateText(newText)
                }
            }
            .onChange(of: speechManager.isFinal) { oldValue, isFinal in
                if isFinal && mode == .translate && !speechManager.transcribedText.isEmpty {
                    // Once speech is final, do the full translation
                    translateText(speechManager.transcribedText)
                }
            }
        }
    }
    
    // MARK: - UI Sections
    
    private var modePicker: some View {
        VStack(spacing: 8) {
            Picker("Mode", selection: $mode) {
                Text("Translate").tag(TranslationMode.translate)
                Text("Transcribe").tag(TranslationMode.transcribe)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: mode) { oldValue, _ in
                // Clear results when switching modes
                translatedText = ""
                // Update the UI to reflect the new mode
                if mode == .translate {
                    // If switching to translate mode, make sure we have a different target language
                    if sourceLanguage == targetLanguage {
                        targetLanguage = sourceLanguage == "en" ? "es" : "en"
                    }
                }
            }
            
            // Description of current mode's behavior
            Text(mode == .translate 
                ? "Translate text or speech between languages"
                : "Convert your speech to text")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var languageSelectionSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                // Source language picker with auto-detect
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        Button(action: {
                            isDetectingLanguage = true
                            detectLanguage(inputText)
                        }) {
                            Label("Detect Language", systemImage: "wand.and.stars")
                        }
                        
                        Divider()
                        
                        ForEach(availableLanguages, id: \.0) { lang in
                            Button(lang.1) {
                                sourceLanguage = lang.0
                                isDetectingLanguage = false
                            }
                        }
                    } label: {
                        HStack {
                            if isDetectingLanguage {
                                Image(systemName: "wand.and.stars")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("Detect")
                                    .font(.headline)
                            } else {
                                Text(languageName(for: sourceLanguage))
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        )
                    }
                }
                
                // Swap button
                Button(action: {
                    if !isDetectingLanguage {
                        let temp = sourceLanguage
                        sourceLanguage = targetLanguage
                        targetLanguage = temp
                        
                        // Also swap the text
                        let tempText = inputText
                        inputText = translatedText
                        translatedText = tempText
                    }
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 14))
                        .padding(8)
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                }
                
                // Target language picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        ForEach(availableLanguages, id: \.0) { lang in
                            Button(lang.1) {
                                targetLanguage = lang.0
                            }
                        }
                    } label: {
                        HStack {
                            Text(languageName(for: targetLanguage))
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 12) {
            // Text input field with Google Translate-like appearance
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.05))
                
                // Only show placeholder when not recording and input is empty
                if inputText.isEmpty && !speechManager.isRecording {
                    Text(mode == .translate 
                         ? "Enter text or tap microphone" 
                         : "Tap microphone to transcribe")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                // When recording, show transcribed text directly
                if speechManager.isRecording {
                    Text(speechManager.transcribedText)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .animation(.default, value: speechManager.transcribedText)
                } else {
                    // Only allow manual text editing when not recording
                    TextEditor(text: $inputText)
                        .frame(minHeight: 120, maxHeight: 200)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(8)
                        .onChange(of: inputText) { newText in
                            // Auto-translate after a short delay while typing
                            if mode == .translate && !newText.isEmpty {
                                debounceTranslate(newText)
                            }
                        }
                }
                
                // Toolbar for input section
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // Microphone button
                        Button(action: {
                            if speechManager.isRecording {
                                speechManager.stopRecording()
                            } else {
                                inputText = ""
                                translatedText = ""
                                speechManager.startRecording(in: sourceLanguage)
                            }
                        }) {
                            Image(systemName: speechManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(speechManager.isRecording 
                                                ? .red 
                                                : (mode == .translate ? .blue : .green))
                        }
                        .padding(8)
                        
                        // Clear button
                        if !inputText.isEmpty && !speechManager.isRecording {
                            Button(action: {
                                inputText = ""
                                translatedText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
            .frame(minHeight: 150, maxHeight: 200)
        }
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Divider between input and output
            Divider()
                .padding(.vertical, 4)
            
            if translatedText.isEmpty && !isTranslating {
                HStack {
                    Spacer()
                    Text(mode == .translate ? "Translation will appear here" : "Transcription will appear here")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(minHeight: 80)
            } else if isTranslating {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .frame(minHeight: 80)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    // Result text
                    Text(translatedText)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.secondary.opacity(0.05))
                        )
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        // Copy button
                        Button(action: {
                            #if os(iOS)
                            UIPasteboard.general.string = translatedText
                            #endif
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Text-to-speech button
                        Button(action: {
                            speakText()
                        }) {
                            Label("Listen", systemImage: isSpeaking ? "stop.fill" : "speaker.wave.2")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        // Share button
                        Button(action: {
                            // Set up share sheet
                            #if os(iOS)
                            let shareText = "\(inputText)\n\n\(translatedText)"
                            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                            
                            // Present the share sheet
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                                rootViewController.present(activityVC, animated: true, completion: nil)
                            }
                            #endif
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var recentTranslationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Translations")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(recentTranslations.prefix(3)) { item in
                    Button {
                        // Restore this translation
                        inputText = item.originalText
                        translatedText = item.translatedText
                        sourceLanguage = item.sourceLanguage
                        targetLanguage = item.targetLanguage
                    } label: {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.originalText)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(item.translatedText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text("\(languageName(for: item.sourceLanguage)) → \(languageName(for: item.targetLanguage))")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.05))
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func languageName(for code: String) -> String {
        availableLanguages.first { $0.0 == code }?.1 ?? code
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            // Handle authorization response if needed
        }
    }
    
    @State private var debounceTimer: Timer?
    
    // Debounce to prevent translation on every keystroke
    private func debounceTranslate(_ text: String) {
        debounceTimer?.invalidate()
        
        // Only translate when user pauses typing (500ms delay)
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.translateText(text)
        }
        debounceTimer = timer
    }
    
    private func translateText(_ text: String) {
        guard !text.isEmpty else { return }
        
        // Don't set isTranslating for continuous updates
        // Only set if we're doing a manual translation
        let wasManualTranslation = text == inputText && !speechManager.isRecording
        if wasManualTranslation {
            isTranslating = true
        }
        
        // For demonstration, we'll simulate a translation API call with a delay
        // Use a shorter delay for speech-to-translation for better responsiveness
        let delayDuration = wasManualTranslation ? 0.5 : 0.2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
            // This is a mock translation - in a real app, you would call an actual API
            let translatedResult = self.improvedTranslate(text: text, from: self.sourceLanguage, to: self.targetLanguage)
            self.translatedText = translatedResult
            
            // Only save to recent translations if it was a manual or final translation
            if wasManualTranslation || self.speechManager.isFinal {
                self.saveTranslation(original: text, translated: translatedResult)
            }
            
            if wasManualTranslation {
                self.isTranslating = false
            }
        }
    }
    
    private func detectLanguage(_ text: String) {
        // This is a simplified language detection based on our dictionary
        // In a real app, you would use a proper language detection service
        
        guard !text.isEmpty else {
            // If text is empty, default to English
            sourceLanguage = "en"
            isDetectingLanguage = false
            return
        }
        
        // Simple language detection logic
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var scores: [String: Int] = [:]
        
        // Initialize scores for each language
        for lang in availableLanguages {
            scores[lang.0] = 0
        }
        
        // Simple scoring: check if words from the text exist in our dictionaries
        for word in words {
            for lang in ["es", "fr", "de", "it", "pt", "ja", "ko", "zh", "ru"] {
                if dictionaryContains(word: word, forLanguage: lang) {
                    scores[lang, default: 0] += 1
                }
            }
        }
        
        // Common English words check
        let commonEnglishWords = ["the", "a", "an", "and", "is", "are", "I", "you", "he", "she", "we", "they", "this", "that"]
        for word in words {
            if commonEnglishWords.contains(word.lowercased()) {
                scores["en", default: 0] += 1
            }
        }
        
        // Find the language with the highest score
        if let bestMatch = scores.max(by: { $0.value < $1.value }), bestMatch.value > 0 {
            sourceLanguage = bestMatch.key
        } else {
            // Default to English if no match
            sourceLanguage = "en"
        }
        
        isDetectingLanguage = false
        
        // Trigger translation after detection
        translateText(text)
    }
    
    private func dictionaryContains(word: String, forLanguage lang: String) -> Bool {
        // Check if the word exists in the reverse dictionaries
        switch lang {
        case "es":
            return spanishToEnglish.keys.contains(word)
        case "fr":
            let frenchWords = englishToFrench.values
            return frenchWords.contains(word)
        case "de":
            let germanWords = englishToGerman.values
            return germanWords.contains(word)
        case "it":
            let italianWords = englishToItalian.values
            return italianWords.contains(word)
        case "pt":
            return portugueseToEnglish.keys.contains(word)
        case "ja":
            let japaneseWords = englishToJapanese.values
            return japaneseWords.contains(word)
        case "ko":
            let koreanWords = englishToKorean.values
            return koreanWords.contains(word)
        case "zh":
            let chineseWords = englishToChinese.values
            return chineseWords.contains(word)
        case "ru":
            let russianWords = englishToRussian.values
            return russianWords.contains(word)
        default:
            return false
        }
    }
    
    private func saveTranslation(original: String, translated: String) {
        // Save to recent translations
        let newTranslation = TranslationItem(
            id: UUID(),
            originalText: original,
            translatedText: translated,
            sourceLanguage: self.sourceLanguage,
            targetLanguage: self.targetLanguage,
            timestamp: Date()
        )
        
        // Insert at the beginning and maintain only the 10 most recent
        self.recentTranslations.insert(newTranslation, at: 0)
        if self.recentTranslations.count > 10 {
            self.recentTranslations = Array(self.recentTranslations.prefix(10))
        }
    }
    
    private func speakText() {
        guard !translatedText.isEmpty else { return }
        
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            return
        }
        
        let utterance = AVSpeechUtterance(string: translatedText)
        // Use the appropriate language for speech
        utterance.voice = AVSpeechSynthesisVoice(language: mode == .translate ? targetLanguage : sourceLanguage)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        isSpeaking = true
        synthesizer.speak(utterance)
        
        // Set isSpeaking to false when done
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(translatedText.count) * 0.05 + 1.0) {
            self.isSpeaking = false
        }
    }
    
    // MARK: - Language Dictionaries
    
    // English to Spanish dictionary with commonly used travel phrases
    private let englishToSpanish: [String: String] = [
        "hello": "hola",
        "goodbye": "adiós",
        "thank you": "gracias",
        "please": "por favor",
        "yes": "sí",
        "no": "no",
        "excuse me": "disculpe",
        "sorry": "lo siento",
        "how are you": "¿cómo estás?",
        "good morning": "buenos días",
        "good afternoon": "buenas tardes",
        "good evening": "buenas noches",
        "where is": "¿dónde está?",
        "where is the": "¿dónde está el?",
        "how much": "¿cuánto cuesta?",
        "what time": "¿qué hora?",
        "help": "ayuda",
        "water": "agua",
        "food": "comida",
        "restaurant": "restaurante",
        "hotel": "hotel",
        "bathroom": "baño",
        "train": "tren",
        "bus": "autobús",
        "taxi": "taxi",
        "airport": "aeropuerto",
        "where is the bathroom": "¿dónde está el baño?",
        "how do i get to": "¿cómo llego a?",
        "my name is": "me llamo",
        "do you speak english": "¿hablas inglés?"
    ]
    
    // Spanish to English dictionary (reverse mapping)
    private let spanishToEnglish: [String: String] = [
        "hola": "hello",
        "adiós": "goodbye",
        "gracias": "thank you",
        "por favor": "please",
        "sí": "yes",
        "no": "no",
        "disculpe": "excuse me",
        "lo siento": "sorry",
        "¿cómo estás?": "how are you",
        "buenos días": "good morning",
        "buenas tardes": "good afternoon",
        "buenas noches": "good evening",
        "¿dónde está?": "where is",
        "¿dónde está el?": "where is the",
        "¿cuánto cuesta?": "how much",
        "¿qué hora?": "what time",
        "ayuda": "help",
        "agua": "water",
        "comida": "food",
        "restaurante": "restaurant",
        "hotel": "hotel",
        "baño": "bathroom",
        "tren": "train",
        "autobús": "bus",
        "taxi": "taxi",
        "aeropuerto": "airport",
        "¿dónde está el baño?": "where is the bathroom",
        "¿cómo llego a?": "how do i get to",
        "me llamo": "my name is",
        "¿hablas inglés?": "do you speak english"
    ]
    
    // English to French dictionary
    private let englishToFrench: [String: String] = [
        "hello": "bonjour",
        "goodbye": "au revoir",
        "thank you": "merci",
        "please": "s'il vous plaît",
        "yes": "oui",
        "no": "non",
        "excuse me": "excusez-moi",
        "sorry": "désolé",
        "how are you": "comment allez-vous",
        "good morning": "bonjour",
        "good afternoon": "bon après-midi",
        "good evening": "bonsoir",
        "where is": "où est",
        "where is the": "où est le",
        "how much": "combien ça coûte",
        "what time": "quelle heure",
        "help": "aidez-moi",
        "water": "eau",
        "food": "nourriture",
        "restaurant": "restaurant",
        "hotel": "hôtel",
        "bathroom": "toilettes",
        "train": "train",
        "bus": "bus",
        "taxi": "taxi",
        "airport": "aéroport",
        "where is the bathroom": "où sont les toilettes",
        "how do i get to": "comment puis-je aller à",
        "my name is": "je m'appelle",
        "do you speak english": "parlez-vous anglais"
    ]
    
    // English to German dictionary
    private let englishToGerman: [String: String] = [
        "hello": "hallo",
        "goodbye": "auf wiedersehen",
        "thank you": "danke",
        "please": "bitte",
        "yes": "ja",
        "no": "nein",
        "excuse me": "entschuldigung",
        "sorry": "es tut mir leid",
        "how are you": "wie geht es dir",
        "good morning": "guten morgen",
        "good afternoon": "guten tag",
        "good evening": "guten abend",
        "where is": "wo ist",
        "where is the": "wo ist der",
        "how much": "wie viel kostet das",
        "what time": "wie spät ist es",
        "help": "hilfe",
        "water": "wasser",
        "food": "essen",
        "restaurant": "restaurant",
        "hotel": "hotel",
        "bathroom": "toilette",
        "train": "zug",
        "bus": "bus",
        "taxi": "taxi",
        "airport": "flughafen",
        "where is the bathroom": "wo ist die toilette",
        "how do i get to": "wie komme ich nach",
        "my name is": "ich heiße",
        "do you speak english": "sprechen sie englisch"
    ]
    
    // English to Italian dictionary
    private let englishToItalian: [String: String] = [
        "hello": "ciao",
        "goodbye": "arrivederci",
        "thank you": "grazie",
        "please": "per favore",
        "yes": "sì",
        "no": "no",
        "excuse me": "scusi",
        "sorry": "mi dispiace",
        "how are you": "come stai",
        "good morning": "buongiorno",
        "good afternoon": "buon pomeriggio",
        "good evening": "buonasera",
        "where is": "dov'è",
        "where is the": "dov'è il",
        "how much": "quanto costa",
        "what time": "che ora è",
        "help": "aiuto",
        "water": "acqua",
        "food": "cibo",
        "restaurant": "ristorante",
        "hotel": "albergo",
        "bathroom": "bagno",
        "train": "treno",
        "bus": "autobus",
        "taxi": "taxi",
        "airport": "aeroporto",
        "where is the bathroom": "dov'è il bagno",
        "how do i get to": "come arrivo a",
        "my name is": "mi chiamo",
        "do you speak english": "parli inglese"
    ]
    
    // English to Portuguese dictionary
    private let englishToPortuguese: [String: String] = [
        "hello": "olá",
        "goodbye": "adeus",
        "thank you": "obrigado",
        "please": "por favor",
        "yes": "sim",
        "no": "não",
        "excuse me": "com licença",
        "sorry": "desculpe",
        "how are you": "como está",
        "good morning": "bom dia",
        "good afternoon": "boa tarde",
        "good evening": "boa noite",
        "where is": "onde está",
        "where is the": "onde está o",
        "how much": "quanto custa",
        "what time": "que horas são",
        "help": "socorro",
        "water": "água",
        "food": "comida",
        "restaurant": "restaurante",
        "hotel": "hotel",
        "bathroom": "banheiro",
        "train": "trem",
        "bus": "ônibus",
        "taxi": "táxi",
        "airport": "aeroporto",
        "where is the bathroom": "onde está o banheiro",
        "how do i get to": "como chego a",
        "my name is": "meu nome é",
        "do you speak english": "você fala inglês"
    ]
    
    // Portuguese to English dictionary
    private let portugueseToEnglish: [String: String] = [
        "olá": "hello",
        "adeus": "goodbye",
        "obrigado": "thank you",
        "por favor": "please",
        "sim": "yes",
        "não": "no",
        "com licença": "excuse me",
        "desculpe": "sorry",
        "como está": "how are you",
        "bom dia": "good morning",
        "boa tarde": "good afternoon",
        "boa noite": "good evening",
        "onde está": "where is",
        "onde está o": "where is the",
        "quanto custa": "how much",
        "que horas são": "what time",
        "socorro": "help",
        "água": "water",
        "comida": "food",
        "restaurante": "restaurant",
        "hotel": "hotel",
        "banheiro": "bathroom",
        "trem": "train",
        "ônibus": "bus",
        "táxi": "taxi",
        "aeroporto": "airport",
        "onde está o banheiro": "where is the bathroom",
        "como chego a": "how do i get to",
        "meu nome é": "my name is",
        "você fala inglês": "do you speak english"
    ]
    
    // English to Japanese dictionary
    private let englishToJapanese: [String: String] = [
        "hello": "こんにちは",
        "goodbye": "さようなら",
        "thank you": "ありがとう",
        "please": "お願いします",
        "yes": "はい",
        "no": "いいえ",
        "excuse me": "すみません",
        "sorry": "ごめんなさい",
        "how are you": "お元気ですか",
        "good morning": "おはようございます",
        "good afternoon": "こんにちは",
        "good evening": "こんばんは",
        "where is": "どこですか",
        "where is the": "どこにありますか",
        "how much": "いくらですか",
        "what time": "何時ですか",
        "help": "助けて",
        "water": "水",
        "food": "食べ物",
        "restaurant": "レストラン",
        "hotel": "ホテル",
        "bathroom": "お手洗い",
        "train": "電車",
        "bus": "バス",
        "taxi": "タクシー",
        "airport": "空港",
        "where is the bathroom": "お手洗いはどこですか",
        "how do i get to": "どうやって行きますか",
        "my name is": "私の名前は",
        "do you speak english": "英語を話せますか"
    ]
    
    // English to Korean dictionary
    private let englishToKorean: [String: String] = [
        "hello": "안녕하세요",
        "goodbye": "안녕히 가세요",
        "thank you": "감사합니다",
        "please": "부탁합니다",
        "yes": "네",
        "no": "아니요",
        "excuse me": "실례합니다",
        "sorry": "죄송합니다",
        "how are you": "어떻게 지내세요",
        "good morning": "좋은 아침입니다",
        "good afternoon": "안녕하세요",
        "good evening": "안녕하세요",
        "where is": "어디에 있습니까",
        "where is the": "어디에 있습니까",
        "how much": "얼마입니까",
        "what time": "몇 시입니까",
        "help": "도와주세요",
        "water": "물",
        "food": "음식",
        "restaurant": "식당",
        "hotel": "호텔",
        "bathroom": "화장실",
        "train": "기차",
        "bus": "버스",
        "taxi": "택시",
        "airport": "공항",
        "where is the bathroom": "화장실이 어디에 있습니까",
        "how do i get to": "어떻게 가나요",
        "my name is": "제 이름은",
        "do you speak english": "영어를 할 줄 아세요"
    ]
    
    // English to Chinese dictionary
    private let englishToChinese: [String: String] = [
        "hello": "你好",
        "goodbye": "再见",
        "thank you": "谢谢",
        "please": "请",
        "yes": "是的",
        "no": "不是",
        "excuse me": "对不起",
        "sorry": "抱歉",
        "how are you": "你好吗",
        "good morning": "早上好",
        "good afternoon": "下午好",
        "good evening": "晚上好",
        "where is": "在哪里",
        "where is the": "在哪里",
        "how much": "多少钱",
        "what time": "几点了",
        "help": "帮助",
        "water": "水",
        "food": "食物",
        "restaurant": "餐厅",
        "hotel": "旅馆",
        "bathroom": "洗手间",
        "train": "火车",
        "bus": "公共汽车",
        "taxi": "出租车",
        "airport": "机场",
        "where is the bathroom": "洗手间在哪里",
        "how do i get to": "怎么去",
        "my name is": "我的名字是",
        "do you speak english": "你会说英语吗"
    ]
    
    // English to Russian dictionary
    private let englishToRussian: [String: String] = [
        "hello": "здравствуйте",
        "goodbye": "до свидания",
        "thank you": "спасибо",
        "please": "пожалуйста",
        "yes": "да",
        "no": "нет",
        "excuse me": "извините",
        "sorry": "простите",
        "how are you": "как дела",
        "good morning": "доброе утро",
        "good afternoon": "добрый день",
        "good evening": "добрый вечер",
        "where is": "где находится",
        "where is the": "где находится",
        "how much": "сколько стоит",
        "what time": "который час",
        "help": "помогите",
        "water": "вода",
        "food": "еда",
        "restaurant": "ресторан",
        "hotel": "гостиница",
        "bathroom": "туалет",
        "train": "поезд",
        "bus": "автобус",
        "taxi": "такси",
        "airport": "аэропорт",
        "where is the bathroom": "где находится туалет",
        "how do i get to": "как добраться до",
        "my name is": "меня зовут",
        "do you speak english": "вы говорите по-английски"
    ]
    
    // MARK: - Improved Translation Logic
    
    private func improvedTranslate(text: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        // If languages are the same, return the original text
        if sourceLanguage == targetLanguage {
            return text
        }
        
        // Use the mockTranslate function which has our dictionary logic
        let translatedText = mockTranslate(text: text, from: sourceLanguage, to: targetLanguage)
        
        // Add language-specific formatting
        return formatTranslation(translatedText, targetLanguage: targetLanguage)
    }
    
    private func mockTranslate(text: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        // Helper function to create reverse dictionary - carefully avoiding duplicates
        func reverseTranslationDictionary(_ dictionary: [String: String]) -> [String: String] {
            var reversed = [String: String]()
            
            for (originalKey, originalValue) in dictionary {
                // Only add if it wouldn't create a duplicate key
                if reversed[originalValue] == nil {
                    reversed[originalValue] = originalKey
                }
            }
            
            return reversed
        }
        
        // Normalize the input text - very aggressive cleaning to improve matches
        let cleanedText = text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ";", with: "")
            .replacingOccurrences(of: "¿", with: "")
            .replacingOccurrences(of: "¡", with: "")
        
        print("⌨️ Original text: '\(text)'")
        print("🧼 Normalized text: '\(cleanedText)'")
        print("🔄 Translating from \(sourceLanguage) to \(targetLanguage)")
        
        // Shared dictionary access function to handle both exact match and partial word lookups
        func findTranslation(forText inputText: String, in dictionary: [String: String]?) -> String? {
            guard let dict = dictionary else { return nil }
            
            // Try exact match first
            if let exactMatch = dict[inputText] {
                print("✅ Found exact match: '\(inputText)' -> '\(exactMatch)'")
                return exactMatch
            }
            
            // Try common patterns for travel phrases
            if inputText.contains("how do i get to") {
                let parts = inputText.components(separatedBy: "how do i get to")
                if parts.count > 1 {
                    let destination = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if let basePhrase = dict["how do i get to"] {
                        if let destTranslation = findTranslation(forText: destination, in: dict) {
                            print("🌍 Found travel phrase: 'how do i get to \(destination)' -> '\(basePhrase) \(destTranslation)'")
                            return "¿\(basePhrase) \(destTranslation)?"
                        } else {
                            // If we can't translate the destination, use it as-is
                            print("🌍 Found travel phrase with untranslated destination: 'how do i get to \(destination)'")
                            return "¿\(basePhrase) \(destination)?"
                        }
                    }
                }
            }
            
            // Try for "where is the X" pattern
            if inputText.contains("where is the") {
                let parts = inputText.components(separatedBy: "where is the")
                if parts.count > 1 {
                    let place = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if let basePhrase = dict["where is the"] {
                        if let placeTranslation = findTranslation(forText: place, in: dict) {
                            print("🌍 Found location phrase: 'where is the \(place)' -> '\(basePhrase) \(placeTranslation)'")
                            return "¿\(basePhrase) \(placeTranslation)?"
                        } else {
                            // If we can't translate the place, use it as-is
                            print("🌍 Found location phrase with untranslated place: 'where is the \(place)'")
                            return "¿\(basePhrase) \(place)?"
                        }
                    }
                }
            }
            
            // If input has multiple words, try word-by-word
            let words = inputText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            if words.count > 1 {
                print("🔍 Trying word-by-word translation for \(words.count) words: \(words)")
                
                // Look for the longest possible phrases first
                for length in (2...6).reversed() where words.count >= length {
                    for startIndex in 0...(words.count - length) {
                        let phrase = words[startIndex..<(startIndex+length)].joined(separator: " ")
                        if let phraseTranslation = dict[phrase] {
                            print("📚 Found multi-word phrase: '\(phrase)' -> '\(phraseTranslation)'")
                            // Replace the words in the original array
                            var replacedWords = words
                            replacedWords.removeSubrange(startIndex..<(startIndex+length))
                            replacedWords.insert(phraseTranslation, at: startIndex)
                            
                            // Recursively translate the remaining words
                            return findTranslation(forText: replacedWords.joined(separator: " "), in: dict)
                        }
                    }
                }
                
                // Special handling for common question patterns if not already caught
                if words.first == "how" || words.first == "where" || words.first == "what" || 
                   words.first == "when" || words.first == "why" || words.first == "who" {
                    var questionWords = [String]()
                    
                    // Try to translate the question word
                    if let questionWord = dict[words[0]] {
                        questionWords.append(questionWord)
                    } else {
                        questionWords.append(words[0])
                    }
                    
                    // Try the rest of the words
                    for word in words.dropFirst() {
                        if let translated = dict[word] {
                            questionWords.append(translated)
                        } else {
                            questionWords.append(word)
                        }
                    }
                    
                    let result = questionWords.joined(separator: " ")
                    // Add Spanish question marks if this is a question
                    if inputText.contains("?") || words.first == "how" || words.first == "where" || 
                       words.first == "what" || words.first == "when" || words.first == "why" || 
                       words.first == "who" {
                        return "¿\(result)?"
                    }
                    
                    print("❓ Handled question pattern: \(result)")
                    return result
                }
                
                // If no multi-word matches, translate word by word
                var anyTranslated = false
                var translatedWords: [String] = []
                
                var skipNext = false
                
                for (index, word) in words.enumerated() {
                    if skipNext {
                        skipNext = false
                        continue
                    }
                    
                    // Try longer phrases first - 3 words
                    if index < words.count - 2 {
                        let threeWordPhrase = [word, words[index + 1], words[index + 2]].joined(separator: " ")
                        if let phraseTranslation = dict[threeWordPhrase] {
                            print("  • Found three-word phrase: '\(threeWordPhrase)' -> '\(phraseTranslation)'")
                            translatedWords.append(phraseTranslation)
                            anyTranslated = true
                            skipNext = true
                            continue
                        }
                    }
                    
                    // Try longer phrases - 2 words
                    if index < words.count - 1 {
                        let twoWordPhrase = word + " " + words[index + 1]
                        if let phraseTranslation = dict[twoWordPhrase] {
                            print("  • Found two-word phrase: '\(twoWordPhrase)' -> '\(phraseTranslation)'")
                            translatedWords.append(phraseTranslation)
                            anyTranslated = true
                            skipNext = true
                            continue
                        }
                    }
                    
                    // Special case for "my name is X" patterns
                    if index == words.count - 2 && (word == "is" || word == "es" || word == "est") {
                        // This might be a name, keep it unchanged
                        let name = words[index + 1].capitalized
                        if let myNameIsTranslation = dict["my name is"] {
                            print("  • Found name pattern: 'my name is \(name)' -> '\(myNameIsTranslation) \(name)'")
                            translatedWords.append(myNameIsTranslation)
                            translatedWords.append(name)
                            anyTranslated = true
                            break
                        }
                    }
                    
                    // Regular single word translation
                    if let wordTranslation = dict[word] {
                        print("  • Found word: '\(word)' -> '\(wordTranslation)'")
                        translatedWords.append(wordTranslation)
                        anyTranslated = true
                    } else if word.hasSuffix("s"), let singular = dict[String(word.dropLast())] {
                        // Try singular form for plural words
                        print("  • Found singular form: '\(word)' -> '\(singular)'s")
                        translatedWords.append(singular)
                        anyTranslated = true
                    } else {
                        // Keep original word
                        translatedWords.append(word)
                    }
                }
                
                if anyTranslated {
                    let result = translatedWords.joined(separator: " ")
                    
                    // Add Spanish question marks if this seems to be a question
                    if inputText.contains("?") || words.first == "how" || words.first == "where" || 
                       words.first == "what" || words.first == "when" || words.first == "why" || 
                       words.first == "who" {
                        print("✅ Word-by-word result (as question): '¿\(result)?'")
                        return "¿\(result)?"
                    }
                    
                    print("✅ Word-by-word result: '\(result)'")
                    return result
                }
            }
            
            return nil
        }
        
        // Dictionary selection based on language pair
        var dictionary: [String: String]? = nil
        
        if sourceLanguage == "en" && targetLanguage == "es" {
            dictionary = englishToSpanish
            print("📚 Using English to Spanish dictionary")
        } else if sourceLanguage == "es" && targetLanguage == "en" {
            dictionary = spanishToEnglish
            print("📚 Using Spanish to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "fr" {
            dictionary = englishToFrench
            print("📚 Using English to French dictionary")
        } else if sourceLanguage == "fr" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToFrench)
            print("📚 Using French to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "de" {
            dictionary = englishToGerman
            print("📚 Using English to German dictionary")
        } else if sourceLanguage == "de" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToGerman)
            print("📚 Using German to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "it" {
            dictionary = englishToItalian
            print("📚 Using English to Italian dictionary")
        } else if sourceLanguage == "it" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToItalian)
            print("📚 Using Italian to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "pt" {
            dictionary = englishToPortuguese
            print("📚 Using English to Portuguese dictionary")
        } else if sourceLanguage == "pt" && targetLanguage == "en" {
            dictionary = portugueseToEnglish
            print("📚 Using Portuguese to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "ja" {
            dictionary = englishToJapanese
            print("📚 Using English to Japanese dictionary")
        } else if sourceLanguage == "ja" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToJapanese)
            print("📚 Using Japanese to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "ko" {
            dictionary = englishToKorean
            print("📚 Using English to Korean dictionary")
        } else if sourceLanguage == "ko" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToKorean)
            print("📚 Using Korean to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "zh" {
            dictionary = englishToChinese
            print("📚 Using English to Chinese dictionary")
        } else if sourceLanguage == "zh" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToChinese)
            print("📚 Using Chinese to English dictionary")
        } else if sourceLanguage == "en" && targetLanguage == "ru" {
            dictionary = englishToRussian
            print("📚 Using English to Russian dictionary")
        } else if sourceLanguage == "ru" && targetLanguage == "en" {
            dictionary = reverseTranslationDictionary(englishToRussian)
            print("📚 Using Russian to English dictionary")
        } else {
            print("⚠️ No direct dictionary available for \(sourceLanguage) to \(targetLanguage)")
        }
        
        // Try finding a translation
        if let translatedText = findTranslation(forText: cleanedText, in: dictionary) {
            // For Spanish, add proper punctuation if needed
            if targetLanguage == "es" && text.contains("?") && !translatedText.contains("¿") {
                return "¿\(translatedText)?"
            }
            return translatedText
        }
        
        // Try with a broader clean (remove spaces) for compound words
        let noSpaceText = cleanedText.replacingOccurrences(of: " ", with: "")
        if let translatedText = findTranslation(forText: noSpaceText, in: dictionary) {
            return translatedText
        }
        
        // For demo purposes, if no translation is found, provide a mock translation
        print("⚠️ Using fallback mock translation")
        
        // Use a language-specific transformation
        if targetLanguage == "es" {
            // Spanish mock
            return "\"" + text + "\" en español"
        } else if targetLanguage == "fr" {
            // French mock
            return "\"" + text + "\" en français"
        } else if targetLanguage == "de" {
            // German mock
            return "\"" + text + "\" auf Deutsch"
        } else if targetLanguage == "it" {
            // Italian mock
            return "\"" + text + "\" in italiano"
        } else if targetLanguage == "pt" {
            // Portuguese mock
            return "\"" + text + "\" em português"
        } else if targetLanguage == "ja" {
            // Japanese mock
            return "\"" + text + "\" 日本語で"
        } else if targetLanguage == "ko" {
            // Korean mock
            return "\"" + text + "\" 한국어로"
        } else if targetLanguage == "zh" {
            // Chinese mock
            return "\"" + text + "\" 用中文"
        } else if targetLanguage == "ru" {
            // Russian mock
            return "\"" + text + "\" на русском"
        } else {
            // Default mock
            return "\"" + text + "\" in " + languageName(for: targetLanguage)
        }
    }
    
    private func formatTranslation(_ text: String, targetLanguage: String) -> String {
        var formattedText = text
        
        // Apply language-specific formatting rules
        switch targetLanguage {
        case "es":
            // Spanish: ensure proper question marks and exclamation marks
            if formattedText.contains("?") && !formattedText.contains("¿") {
                formattedText = "¿" + formattedText
            }
            if formattedText.contains("!") && !formattedText.contains("¡") {
                formattedText = "¡" + formattedText
            }
        case "fr":
            // French: ensure space before punctuation
            formattedText = formattedText.replacingOccurrences(of: "!", with: " !")
            formattedText = formattedText.replacingOccurrences(of: "?", with: " ?")
            formattedText = formattedText.replacingOccurrences(of: ":", with: " :")
            formattedText = formattedText.replacingOccurrences(of: ";", with: " ;")
        case "ja", "zh":
            // Japanese/Chinese: remove unnecessary spaces
            formattedText = formattedText.replacingOccurrences(of: " ", with: "")
        default:
            break
        }
        
        return formattedText
    }
}

// MARK: - Supporting Models

struct TranslationItem: Identifiable {
    let id: UUID
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let timestamp: Date
}

// MARK: - Speech Manager

class SpeechManager: ObservableObject {
    @Published var transcribedText = ""
    @Published var isRecording = false
    @Published var isFinal = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording(in languageCode: String) {
        // Reset previous state
        stopRecording()
        transcribedText = ""
        isFinal = false
        
        // Set recognizer locale based on selected language
        let locale = Locale(identifier: languageToLocale(languageCode))
        
        guard let speechRecognizer = SFSpeechRecognizer(locale: locale),
              speechRecognizer.isAvailable else {
            return
        }
        
        // iOS-specific audio session configuration
        #if os(iOS)
        configureAudioSession()
        #endif
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine start error: \(error)")
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
                
                if result.isFinal {
                    self.isFinal = true
                    self.stopRecording()
                }
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
    }
    
    #if os(iOS)
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }
    #endif
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecording = false
    }
    
    private func languageToLocale(_ language: String) -> String {
        switch language {
        case "en": return "en-US"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "zh": return "zh-CN"
        case "ru": return "ru-RU"
        case "pt": return "pt-BR"
        default: return "en-US"
        }
    }
}

#Preview {
    TranslationView()
}
