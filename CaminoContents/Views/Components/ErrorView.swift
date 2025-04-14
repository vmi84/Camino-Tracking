import SwiftUI

struct ErrorView: View {
    var errorMessage: String
    var retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding(.bottom, 8)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
        .shadow(radius: 2)
        .padding()
    }
}

extension View {
    func errorAlert(isPresented: Binding<Bool>, message: String, onRetry: (() -> Void)? = nil) -> some View {
        self.alert("Error", isPresented: isPresented) {
            Button("OK", role: .cancel) { }
            if let retry = onRetry {
                Button("Retry", action: retry)
            }
        } message: {
            Text(message)
        }
    }
}

#Preview {
    VStack {
        ErrorView(
            errorMessage: "Unable to load weather data. Please check your internet connection and try again.",
            retryAction: { print("Retry tapped") }
        )
        
        Button("Show Alert") {
            // This would be handled with a @State var isShowingError = false
            print("Would show alert here")
        }
    }
} 