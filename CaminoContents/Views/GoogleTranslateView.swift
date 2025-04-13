import SwiftUI
import WebKit
import CaminoModels

struct GoogleTranslateView: View {
    @State private var isShowingTranslate = true
    @State private var sourceLanguage = "auto"
    @State private var targetLanguage = "en"
    @State private var inputText = ""
    @State private var isLoading = true
    
    // Get the saved language settings
    @AppStorage("sourceLanguageCode") private var savedSourceLanguage = "en"
    @AppStorage("targetLanguageCode") private var savedTargetLanguage = "es"
    
    @EnvironmentObject private var appState: CaminoAppState
    
    var body: some View {
        NavigationView {
            VStack {
                if isShowingTranslate {
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Opening Google Translate...")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            // Update source and target languages from settings
                            sourceLanguage = savedSourceLanguage
                            targetLanguage = savedTargetLanguage
                            
                            // Automatically open Google Translate when view appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                TranslationService.shared.openGoogleTranslate(
                                    text: inputText,
                                    sourceLanguage: sourceLanguage,
                                    targetLanguage: targetLanguage
                                )
                                isLoading = false
                            }
                        }
                    } else {
                        TranslateWebView(url: constructTranslateURL())
                            .navigationTitle("Google Translate")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(
                                trailing: Button(action: {
                                    // Use the current language settings
                                    TranslationService.shared.openGoogleTranslate(
                                        text: inputText,
                                        sourceLanguage: sourceLanguage,
                                        targetLanguage: targetLanguage
                                    )
                                }) {
                                    Image(systemName: "arrow.up.forward.app")
                                        .foregroundColor(.blue)
                                }
                            )
                    }
                } else {
                    VStack(spacing: 20) {
                        TextField("Text to translate", text: $inputText)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("From:")
                                .foregroundColor(.secondary)
                            Picker("Source language", selection: $sourceLanguage) {
                                Text("Auto detect").tag("auto")
                                Text("English").tag("en")
                                Text("Spanish").tag("es")
                                Text("French").tag("fr")
                            }
                            .pickerStyle(.menu)
                            
                            Spacer()
                            
                            Text("To:")
                                .foregroundColor(.secondary)
                            Picker("Target language", selection: $targetLanguage) {
                                Text("English").tag("en")
                                Text("Spanish").tag("es")
                                Text("French").tag("fr")
                                Text("German").tag("de")
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal)
                        
                        Button("Translate") {
                            isShowingTranslate = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                        
                        Spacer()
                    }
                    .navigationTitle("Google Translate")
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        // Initialize language selections from saved settings
                        sourceLanguage = savedSourceLanguage
                        targetLanguage = savedTargetLanguage
                    }
                }
            }
            .onAppear {
                // Update source and target languages from settings
                sourceLanguage = savedSourceLanguage
                targetLanguage = savedTargetLanguage
                
                // This ensures we always open Google Translate directly when viewing this tab
                if !isShowingTranslate {
                    isShowingTranslate = true
                }
            }
            // Add onChange handlers to update settings when user changes languages
            .onChange(of: sourceLanguage) { _, newValue in
                if newValue != "auto" { // Only save non-auto values
                    savedSourceLanguage = newValue
                }
            }
            .onChange(of: targetLanguage) { _, newValue in
                savedTargetLanguage = newValue
            }
        }
    }
    
    private func constructTranslateURL() -> URL {
        let baseURL = "https://translate.google.com/"
        let query = "?sl=\(sourceLanguage)&tl=\(targetLanguage)&text=\(inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return URL(string: baseURL + query) ?? URL(string: baseURL)!
    }
}

struct TranslateWebView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Load Google Translate
        loadTranslate(in: webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Reload if language changes
        loadTranslate(in: webView)
    }
    
    private func loadTranslate(in webView: WKWebView) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Hide any elements we don't want to show
            let js = """
            // Hide header elements if needed
            try {
                const header = document.querySelector('header');
                if (header) header.style.display = 'none';
            } catch (e) { console.error(e); }
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}

#Preview {
    GoogleTranslateView()
        .environmentObject(CaminoAppState())
} 