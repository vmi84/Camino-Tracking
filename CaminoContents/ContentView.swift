import SwiftUI
import MapKit
import CoreLocation

// MARK: - ContentView
struct ContentView: View {
    @State private var isShowingMap = false
    @State private var selectedTab = 0
    
    var body: some View {
        if isShowingMap {
            TabView(selection: $selectedTab) {
                MapView()
                    .ignoresSafeArea()
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                    }
                    .tag(0)
                
                DestinationsView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Destinations")
                    }
                    .tag(1)
                
                Text("Weather")
                    .tabItem {
                        Image(systemName: "cloud.sun")
                        Text("Weather")
                    }
                    .tag(2)
                
                Text("Profile")
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
                
                Text("Settings")
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(4)
            }
            .tint(.blue)
        } else {
            WelcomeView(isShowingMap: $isShowingMap)
        }
    }
}

// MARK: - WelcomeView
struct WelcomeView: View {
    @Binding var isShowingMap: Bool
    
    var body: some View {
        ZStack {
            Image("CaminoWelcome")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.7)
            
            VStack(spacing: 20) {
                Text("Welcome to Camino")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                
                Text("Your journey along the Camino de Santiago begins here. Explore the route, track your progress, and discover the rich history of this ancient pilgrimage.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.primary)
                
                Button(action: {
                    withAnimation {
                        isShowingMap = true
                    }
                }) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.8))
                    .padding()
            )
        }
    }
}

#Preview {
    ContentView()
} 