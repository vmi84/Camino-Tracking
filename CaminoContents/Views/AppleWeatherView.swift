import SwiftUI
import CoreLocation
import MapKit
#if canImport(CaminoModels)
import CaminoModels
#endif
#if os(iOS)
import UIKit
#endif

struct AppleWeatherView: View {
    @EnvironmentObject private var viewModel: WeatherViewModel
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading Weather...")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ZStack {
                        Color(.systemGroupedBackground)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 24) {
                            Image(systemName: "cloud.sun.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                                .padding()
                            
                            Text("Apple Weather")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Weather information for your current location or selected destination")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: {
                                openAppleWeather()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.forward.app")
                                    Text("Open Weather for Current Location")
                                }
                                .font(.headline)
                                .frame(minWidth: 220, minHeight: 55)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.vertical)
                            
                            Spacer()
                            
                            Section {
                                Text("Select a destination to open weather:")
                                    .font(.headline)
                                    .padding(.top)
                                
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.destinations) { destination in
                                            Button(action: {
                                                viewModel.openNativeWeatherApp(for: destination)
                                            }) {
                                                HStack {
                                                    Text("Day \(destination.day): \(destination.locationName)")
                                                        .lineLimit(1)
                                                    Spacer()
                                                    Image(systemName: "arrow.up.forward.app")
                                                }
                                                .padding()
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .frame(maxHeight: 250)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 40)
                    }
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        openAppleWeather()
                    }) {
                        Image(systemName: "arrow.up.forward.app")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                    if viewModel.isTabSelected && !viewModel.hasRedirected {
                        openAppleWeather()
                    }
                }
            }
        }
    }
    
    private func openAppleWeather() {
        viewModel.openWeatherForCurrentLocation()
    }
}

#Preview {
    AppleWeatherView()
        .environmentObject(WeatherViewModel())
} 