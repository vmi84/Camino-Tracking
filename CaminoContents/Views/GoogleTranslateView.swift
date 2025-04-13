import SwiftUI
import WebKit
import CaminoModels

struct GoogleTranslateView: View {
    @State private var isShowingTranslate = false
    @State private var sourceLanguage = "es"
    @State private var targetLanguage = "en"
    @State private var inputText = ""
    @AppStorage("sourceLanguageCode") private var savedSourceLanguage = "es"
    @AppStorage("targetLanguageCode") private var savedTargetLanguage = "en"
    @EnvironmentObject private var appState: CaminoAppState
    
    var body: some View {
        NavigationView {
            VStack {
                if isShowingTranslate {
                    TranslateWebView(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, inputText: inputText)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: 
                            Button(action: {
                                isShowingTranslate = false
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back to Camino")
                                }
                            }
                        )
                } else {
                    languageSelectionView
                }
            }
            .navigationTitle("Translation")
            .onAppear {
                // Use user's saved language preferences
                sourceLanguage = savedSourceLanguage
                targetLanguage = savedTargetLanguage
            }
        }
    }
    
    private var languageSelectionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("Google Translate")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Translate text to help you communicate during your Camino journey")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .foregroundColor(.secondary)
            
            TextField("Enter text to translate (optional)", text: $inputText)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal, 40)
                .padding(.top, 20)
            
            languagePicker
            
            Spacer()
            
            Button(action: {
                isShowingTranslate = true
            }) {
                Text("Open Google Translate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
    
    private var languagePicker: some View {
        VStack(spacing: 15) {
            HStack {
                Text("From:")
                    .font(.headline)
                
                Picker("Source Language", selection: $sourceLanguage) {
                    Text("Spanish").tag("es")
                    Text("English").tag("en")
                    Text("French").tag("fr")
                    Text("German").tag("de")
                    Text("Italian").tag("it")
                    Text("Portuguese").tag("pt")
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: sourceLanguage) { _, newValue in
                    savedSourceLanguage = newValue
                }
            }
            .padding(.horizontal, 40)
            
            HStack {
                Text("To:")
                    .font(.headline)
                
                Picker("Target Language", selection: $targetLanguage) {
                    Text("English").tag("en")
                    Text("Spanish").tag("es")
                    Text("French").tag("fr")
                    Text("German").tag("de")
                    Text("Italian").tag("it")
                    Text("Portuguese").tag("pt")
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: targetLanguage) { _, newValue in
                    savedTargetLanguage = newValue
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}

struct TranslateWebView: UIViewRepresentable {
    var sourceLanguage: String
    var targetLanguage: String
    var inputText: String
    
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
        var urlString = "https://translate.google.com/?sl=\(sourceLanguage)&tl=\(targetLanguage)&op=translate"
        
        if !inputText.isEmpty {
            guard let escapedText = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("Failed to encode text for URL")
                return
            }
            urlString += "&text=\(escapedText)"
        }
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
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