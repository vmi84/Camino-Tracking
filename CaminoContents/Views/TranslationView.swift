import SwiftUI
import AVFoundation
import Speech
#if os(iOS)
import UIKit
#endif

struct TranslationView: View {
    // Translation state
    @State private var inputText = ""
    @State private var mode: TranslationMode = .translate
    
    // Language selection from settings
    @AppStorage("sourceLanguageCode") private var sourceLanguage = "en"
    @AppStorage("targetLanguageCode") private var targetLanguage = "es"
    
    // Speech recognition
    @StateObject private var speechManager = SpeechManager()
    
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
        ("pt", "Portuguese"),
        ("eu", "Basque"),
        ("gl", "Galician")
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
                        // Language display section
                        if mode == .translate {
                            languageDisplaySection
                                .padding(.horizontal)
                        }
                        
                        // Input section
                        inputSection
                            .padding(.horizontal)
                        
                        // Translate or transcribe action buttons
                        actionButtonsSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                    }
                    .padding(.vertical)
                }
                
                Spacer()
            }
            .navigationTitle(mode == .translate ? "Translation" : "Transcription")
            .onAppear {
                requestSpeechAuthorization()
            }
            .onChange(of: speechManager.transcribedText) { oldValue, newText in
                // Update input text with transcription
                inputText = newText
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
                // Clear input when switching modes
                inputText = ""
            }
            
            // Description of current mode's behavior
            Text(mode == .translate 
                ? "Translate text or speech between languages"
                : "Convert your speech to text")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var languageDisplaySection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                // Source language display
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(languageName(for: sourceLanguage))
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
                
                // Swap button
                Button(action: {
                    let temp = sourceLanguage
                    sourceLanguage = targetLanguage
                    targetLanguage = temp
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 14))
                        .padding(8)
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                }
                
                // Target language display
                VStack(alignment: .leading, spacing: 4) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(languageName(for: targetLanguage))
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                    )
                }
            }
            
            // Add instruction to change languages
            Text("Change languages in Settings")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
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
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            if mode == .translate {
                // Google Translate button
                Button(action: openGoogleTranslate) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.headline)
                        Text("Open in Google Translate")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Text("Translations will be handled by Google Translate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                // Copy Transcription button
                Button(action: copyTranscribedText) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                            .font(.headline)
                        Text("Copy Transcribed Text")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(inputText.isEmpty)
                .opacity(inputText.isEmpty ? 0.5 : 1)
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
    
    private func openGoogleTranslate() {
        TranslationService.shared.openGoogleTranslate(
            text: inputText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
    }
    
    private func copyTranscribedText() {
        #if os(iOS)
        UIPasteboard.general.string = inputText
        #endif
    }
    
    // MARK: - Translation Logic
    func improvedTranslate(input: String, targetLang: String) {
        // Always default to using Google Translate
        TranslationService.shared.openGoogleTranslate(
            text: input,
            sourceLanguage: detectLanguage(input),
            targetLanguage: targetLang
        )
    }

    // This function only detects language for Google Translate purposes
    // It doesn't need to be complex since Google will auto-detect anyway
    func detectLanguage(_ text: String) -> String {
        // Default to auto-detection for Google Translate
        return "auto"
    }
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
        case "eu": return "eu-ES" // Basque - primarily spoken in northern Spain
        case "gl": return "gl-ES" // Galician - primarily spoken in northwestern Spain
        default: return "en-US"
        }
    }
}

#Preview {
    TranslationView()
}
