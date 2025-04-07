//
//  ContentView.swift
//  Camino
//
//  Created by Jeff White on 4/4/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var hasSeenWelcome = false
    
    var body: some View {
        NavigationView {
            if !hasSeenWelcome {
                WelcomeView(hasSeenWelcome: $hasSeenWelcome)
            } else {
                TabView {
                    MapView()
                        .tabItem {
                            Image(systemName: "figure.hiking")
                            Text("Journey")
                        }
                    
                    Text("Lodging")
                        .tabItem {
                            Image(systemName: "house")
                            Text("Lodging")
                        }
                    
                    Text("Routes")
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("Routes")
                        }
                    
                    Text("Weather")
                        .tabItem {
                            Image(systemName: "cloud.sun")
                            Text("Weather")
                        }
                    
                    Text("Settings")
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                }
            }
        }
    }
}

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool
    
    var body: some View {
        ZStack {
            // Background image
            Image("CaminoWelcome")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            
            VStack {
                // Start button at the top
                Button(action: {
                    withAnimation {
                        hasSeenWelcome = true
                    }
                }) {
                    Text("Start")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(red: 0.7, green: 0.8, blue: 0.9)) // Light blue-gray
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Title and subtitle
                VStack(spacing: 20) {
                    Text("Camino Frances")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text("Begin Your Journey")
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
