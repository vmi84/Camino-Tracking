import SwiftUI

struct ProfileView: View {
    // These would come from a user profile or progress tracker in a real implementation
    @State private var distanceWalked: Double = 127.5 // km
    @State private var daysCompleted: Int = 5
    @State private var stagesDone: Int = 5
    @State private var totalStages: Int = 33
    
    // Mock photo journal data
    @State private var photos = [
        PhotoItem(id: UUID(), name: "St. Jean Pied de Port", day: 1, image: "photo1"),
        PhotoItem(id: UUID(), name: "Roncesvalles", day: 2, image: "photo2"),
        PhotoItem(id: UUID(), name: "Zubiri", day: 3, image: "photo3"),
        PhotoItem(id: UUID(), name: "Pamplona", day: 4, image: "photo4"),
        PhotoItem(id: UUID(), name: "Puente la Reina", day: 5, image: "photo5")
    ]
    
    // User preferences
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @AppStorage("language") private var language = "English"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Summary
                    progressSummarySection
                    
                    // Photo Journal
                    photoJournalSection
                    
                    // Quick Preferences
                    preferencesSection
                }
                .padding()
            }
            .navigationTitle("My Profile")
        }
    }
    
    private var progressSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Summary")
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack(spacing: 15) {
                ProgressCard(
                    icon: "figure.walk",
                    title: "Distance",
                    value: useMetricUnits ? "\(String(format: "%.1f", distanceWalked)) km" : "\(String(format: "%.1f", distanceWalked * 0.621371)) mi"
                )
                
                ProgressCard(
                    icon: "calendar",
                    title: "Days",
                    value: "\(daysCompleted)/33"
                )
                
                ProgressCard(
                    icon: "flag.fill",
                    title: "Stages",
                    value: "\(stagesDone)/\(totalStages)"
                )
            }
            
            Button(action: {
                // Navigate to detailed progress tracker
            }) {
                Text("View Detailed Progress")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var photoJournalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photo Journal")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Add photo action
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 4)
            
            // Photo gallery
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(photos) { photo in
                        photoThumbnail(photo)
                    }
                }
            }
            
            Button(action: {
                // Navigate to full photo journal
            }) {
                Text("View All Photos")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Preferences")
                .font(.headline)
                .padding(.bottom, 4)
            
            VStack(spacing: 16) {
                Toggle("Distance (kilometers)", isOn: $useMetricUnits)
                
                Picker("Language", selection: $language) {
                    Text("English").tag("English")
                    Text("Spanish").tag("Spanish")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: {
                    // Navigate to edit itinerary
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Itinerary")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func photoThumbnail(_ photo: PhotoItem) -> some View {
        VStack(alignment: .leading) {
            Image(photo.image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .cornerRadius(8)
                .clipped()
            
            Text("Day \(photo.day): \(photo.name)")
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
}

// MARK: - Supporting Views and Models

struct ProgressCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.bottom, 4)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PhotoItem: Identifiable {
    let id: UUID
    let name: String
    let day: Int
    let image: String
}

#Preview {
    ProfileView()
} 