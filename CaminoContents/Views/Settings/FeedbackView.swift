import SwiftUI
import MessageUI // Import MessageUI

struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var feedbackText: String = ""
    @State private var showingMailWithErrorAlert = false
    @State private var showingCannotSendMailAlert = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showMailView = false
    
    // ** IMPORTANT: Replace with the actual feedback email address **
    private let feedbackEmail = "vmi84@me.com" // Updated email address
    private let emailSubject = "Camino App Feedback"

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Please share your thoughts, suggestions, or any issues you've encountered with the Camino app.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)

                TextEditor(text: $feedbackText)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .frame(minHeight: 150)

                Spacer()
            }
            .padding()
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        // Check if mail can be sent
                        if MFMailComposeViewController.canSendMail() {
                            self.showMailView = true
                        } else {
                            self.showingCannotSendMailAlert = true
                        }
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            // Present the MailView sheet
            .sheet(isPresented: $showMailView) {
                MailView(result: $mailResult, 
                         recipient: feedbackEmail, 
                         subject: emailSubject, 
                         messageBody: feedbackText)
            }
            // Alert if mail services are unavailable
            .alert("Cannot Send Email", isPresented: $showingCannotSendMailAlert) {
                Button("OK") { }
            } message: {
                Text("Your device is not configured to send email. Please set up an email account in the Mail app.")
            }
            // Optional: Alert based on mail send result (uncomment if needed)
            /*
            .onChange(of: mailResult) { result in
                // Handle success/failure/cancellation if needed
                if case .success(let mailComposeResult) = result {
                    if mailComposeResult == .failed {
                       showingMailWithErrorAlert = true 
                    }
                }
            }
            .alert("Email Error", isPresented: $showingMailWithErrorAlert) {
                Button("OK") { }
            } message: {
                Text("There was an error sending your feedback. Please try again.")
            }
            */
        }
        // Add onChange to dismiss FeedbackView after MailView dismisses
        .onChange(of: showMailView) { oldValue, newValue in
            // When the mail sheet is dismissed (newValue is false)
            if !newValue {
                // Dismiss the FeedbackView itself
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    FeedbackView()
} 