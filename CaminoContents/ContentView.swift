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
                ZStack {
                    MapView()
                        .edgesIgnoringSafeArea(.top)
                    VStack {
                        Spacer()
                        Color.clear.frame(height: 0)
                    }
                }
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
                .aspectRatio(1.2, contentMode: .fill)
                .scaleEffect(0.6)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.8)
            
            VStack(spacing: 0) {
                Button(action: {
                    withAnimation {
                        isShowingMap = true
                    }
                }) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("Welcome to Camino")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Text("Your journey along the Camino de Santiago begins here. Explore the route, track your progress, and discover the rich history of this ancient pilgrimage.")
                        .font(.body)
                        .lineSpacing(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 80)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.98))
                )
                .padding(.horizontal, 80)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    ContentView()
} 