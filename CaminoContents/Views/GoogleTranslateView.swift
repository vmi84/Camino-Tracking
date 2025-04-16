import SwiftUI
import WebKit
import CaminoModels

struct GoogleTranslateView: View {
    @State private var isLoading = true
    @State private var inputText = ""
    
    // Get the saved language settings
    @AppStorage("sourceLanguageCode") private var sourceLanguage = "en"
    @AppStorage("targetLanguageCode") private var targetLanguage = "es"
    
    @EnvironmentObject private var appState: CaminoAppState
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading Translator...")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TranslateWebView(url: constructTranslateURL())
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationTitle("Translator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 2) {
                        Picker("From", selection: $sourceLanguage) {
                            Text("Auto").tag("auto")
                            Text("English").tag("en")
                            Text("Spanish").tag("es")
                            Text("French").tag("fr")
                            Text("German").tag("de")
                            Text("Italian").tag("it")
                            Text("Portuguese").tag("pt-PT")
                            Text("Galician").tag("gl")
                            Text("Basque").tag("eu")
                        }
                        .pickerStyle(.menu)
                        .font(.caption)
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Text("→")
                            .font(.caption)
                        
                        Picker("To", selection: $targetLanguage) {
                            Text("English").tag("en")
                            Text("Spanish").tag("es")
                            Text("French").tag("fr")
                            Text("German").tag("de")
                            Text("Italian").tag("it")
                            Text("Portuguese").tag("pt-PT")
                            Text("Galician").tag("gl")
                            Text("Basque").tag("eu")
                        }
                        .pickerStyle(.menu)
                        .font(.caption)
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Option to open in external app
                        TranslationService.shared.openGoogleTranslate(
                            text: inputText,
                            sourceLanguage: sourceLanguage,
                            targetLanguage: targetLanguage
                        )
                    }) {
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                // Handle migration from old "pt" code to new "pt-PT" code
                if sourceLanguage == "pt" {
                    sourceLanguage = "pt-PT"
                }
                if targetLanguage == "pt" {
                    targetLanguage = "pt-PT"
                }
                
                // Handle migration from "pt-BR" (removed) to "pt-PT"
                if sourceLanguage == "pt-BR" {
                    sourceLanguage = "pt-PT"
                }
                if targetLanguage == "pt-BR" {
                    targetLanguage = "pt-PT"
                }
                
                // Show loading indicator briefly, then load webview
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                }
            }
            // Reload the web view when language selections change
            .onChange(of: sourceLanguage) { _, _ in
                // Brief loading state when changing languages
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isLoading = false
                }
            }
            .onChange(of: targetLanguage) { _, _ in
                // Brief loading state when changing languages
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isLoading = false
                }
            }
        }
    }
    
    private func constructTranslateURL() -> URL {
        let baseURL = "https://translate.google.com/"
        let query = "?sl=\(sourceLanguage)&tl=\(targetLanguage)&op=translate"
        
        // Add text parameter if we have input
        let textParam = !inputText.isEmpty 
            ? "&text=\(inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" 
            : ""
            
        return URL(string: baseURL + query + textParam) ?? URL(string: baseURL)!
    }
}

struct TranslateWebView: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "CaminoApp/Mobile"
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Load Google Translate
        loadTranslate(in: webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Reload when URL changes (language change)
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
            // Mobile optimization for Google Translate - this script helps improve the UI in our embedded view
            let js = """
            // Hide unnecessary elements
            try {
                // Attempt to optimize the mobile view
                const style = document.createElement('style');
                style.textContent = `
                    .frame { height: 100vh !important; }
                    header, .gp-footer, .feedback-link { display: none !important; }
                    .page { padding-top: 0 !important; }
                    .homepage-content-wrap { padding-top: 10px !important; }
                `;
                document.head.appendChild(style);
            } catch (e) { console.error("Failed to optimize UI:", e); }
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
        
        // Ensure links open within our webview
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.targetFrame == nil {
                // If the link would open in a new window, instead open it in our webview
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }
            
            // Otherwise allow the navigation within our webview
            decisionHandler(.allow)
        }
    }
}

#Preview {
    GoogleTranslateView()
        .environmentObject(CaminoAppState())
} 