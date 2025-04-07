import SwiftUI
import MapKit
import CoreLocation

struct DestinationsView: View {
    @State private var searchText = ""
    
    private var filteredDestinations: [CaminoDestination] {
        if searchText.isEmpty {
            return CaminoDestination.allDestinations
        } else {
            return CaminoDestination.allDestinations.filter { destination in
                destination.locationName.localizedCaseInsensitiveContains(searchText) ||
                destination.hotelName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var destinationsByWeek: [(week: Int, destinations: [CaminoDestination])] {
        Dictionary(grouping: filteredDestinations) { destination in
            (destination.day - 1) / 7 + 1
        }
        .sorted { $0.key < $1.key }
        .map { (week: $0.key, destinations: $0.value.sorted { $0.day < $1.day }) }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(destinationsByWeek, id: \.week) { weekData in
                    Section(header: Text("Week \(weekData.week)")) {
                        ForEach(weekData.destinations) { destination in
                            NavigationLink {
                                DestinationDetailView(destination: destination)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Day \(destination.day)")
                                            .font(.headline)
                                        Text("(\(destination.formattedDate))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(destination.locationName)
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                    
                                    Text(destination.hotelName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search destinations")
            .navigationTitle("Destinations")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    DestinationsView()
} 