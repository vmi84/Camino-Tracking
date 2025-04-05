//
//  ContentView.swift
//  Camino
//
//  Created by Jeff White on 4/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var hasSeenWelcome = false
    
    var body: some View {
        NavigationView {
            if !hasSeenWelcome {
                WelcomeView(hasSeenWelcome: $hasSeenWelcome)
            } else {
                TabView {
                    Text("Journey")
                        .tabItem {
                            Image(systemName: "figure.hiking")
                            Text("Journey")
                        }
                    
                    Text("Map")
                        .tabItem {
                            Image(systemName: "map")
                            Text("Map")
                        }
                    
                    Text("Details")
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("Details")
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
            
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Text("Camino Frances")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                // Subtitle
                Text("Begin Your Journey")
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                
                // Start button
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
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.top, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    ContentView()
}
