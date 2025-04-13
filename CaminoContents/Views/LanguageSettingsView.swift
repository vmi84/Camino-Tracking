import SwiftUI

struct LanguageSettingsView: View {
    @Binding var sourceLanguage: String
    @Binding var targetLanguage: String
    @Environment(\.dismiss) private var dismiss
    
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
        ("pt-PT", "Portuguese"),
        ("eu", "Basque"),
        ("gl", "Galician")
    ]
    
    var body: some View {
        List {
            Section(header: Text("Source Language")) {
                ForEach(availableLanguages, id: \.0) { language in
                    Button(action: {
                        sourceLanguage = language.0
                    }) {
                        HStack {
                            Text(language.1)
                            Spacer()
                            if sourceLanguage == language.0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Section(header: Text("Target Language")) {
                ForEach(availableLanguages, id: \.0) { language in
                    Button(action: {
                        targetLanguage = language.0
                    }) {
                        HStack {
                            Text(language.1)
                            Spacer()
                            if targetLanguage == language.0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Language Settings")
        .navigationBarItems(trailing: Button("Done") {
            dismiss()
        })
        .onChange(of: sourceLanguage) { oldValue, newValue in
            // If user selects the same language for both, swap them
            if newValue == targetLanguage {
                targetLanguage = oldValue
            }
        }
        .onChange(of: targetLanguage) { oldValue, newValue in
            // If user selects the same language for both, swap them
            if newValue == sourceLanguage {
                sourceLanguage = oldValue
            }
        }
    }
}

#Preview {
    NavigationView {
        LanguageSettingsView(
            sourceLanguage: .constant("en"),
            targetLanguage: .constant("es")
        )
    }
} 