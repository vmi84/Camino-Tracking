import SwiftUI

struct ContentView: View {
    @State private var hasSeenWelcome = false
    
    var body: some View {
        if !hasSeenWelcome {
            WelcomeView(onGetStarted: {
                withAnimation {
                    hasSeenWelcome = true
                }
            })
        } else {
            TabView {
                RouteView()
                    .tabItem {
                        Label("Journey", systemImage: "map")
                    }
                
                LodgingView()
                    .tabItem {
                        Label("Lodging", systemImage: "house")
                    }
                
                DestinationView()
                    .tabItem {
                        Label("Routes", systemImage: "list.bullet")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .accentColor(.green)
        }
    }
}

struct WelcomeView: View {
    let onGetStarted: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("welcome-screen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("CAMINO FRANCES")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.75), radius: 5, x: 2, y: 2)
                        
                        Text("ST JEAN PIED DE PORT TO SANTIAGO")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.75), radius: 3, x: 1, y: 1)
                        
                        Button(action: onGetStarted) {
                            Text("Begin Your Journey")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 80)
                    .padding(.horizontal, 20)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct RouteView: View {
    var body: some View {
        NavigationView {
            Text("Route View")
                .navigationTitle("Your Journey")
        }
    }
}

struct LodgingView: View {
    var body: some View {
        NavigationView {
            Text("Lodging View")
                .navigationTitle("Accommodation")
        }
    }
}

struct DestinationView: View {
    var body: some View {
        NavigationView {
            Text("Destination View")
                .navigationTitle("Daily Routes")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings View")
                .navigationTitle("Settings")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 