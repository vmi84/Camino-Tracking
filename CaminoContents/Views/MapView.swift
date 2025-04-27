//
//  MapView.swift
//  Camino
//
//  Created by Jeff White on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation
import CaminoModels

// MARK: - MKCoordinateRegion Extension for Comparison
extension MKCoordinateRegion {
    func isApproximatelyEqual(to otherRegion: MKCoordinateRegion, tolerance: Double = 0.0001) -> Bool {
        let latDiff = abs(self.center.latitude - otherRegion.center.latitude)
        let lonDiff = abs(self.center.longitude - otherRegion.center.longitude)
        let spanLatDiff = abs(self.span.latitudeDelta - otherRegion.span.latitudeDelta)
        let spanLonDiff = abs(self.span.longitudeDelta - otherRegion.span.longitudeDelta)

        return latDiff < tolerance && lonDiff < tolerance && spanLatDiff < tolerance && spanLonDiff < tolerance
    }
}

// MARK: - Main Map View using UIViewRepresentable
struct MapView: View {
    // Inject AppState
    @EnvironmentObject private var appState: CaminoAppState 
    // Use StateObject for the ViewModel owned by this View
    @StateObject private var viewModel = MapViewModel()
    // ADDED: State for presenting the detail sheet
    @State private var showingDetailSheet = false
    
    @AppStorage("mapStyle") private var mapStyleSetting = "Standard"
    
    // Convert string map style to MapKit mapType
    private var mapType: MKMapType {
        switch mapStyleSetting {
        case "Satellite":
            return .satellite
        case "Hybrid":
            return .hybrid
        default:
            return .standard
        }
    }

    var body: some View {
        NavigationView { 
            ZStack(alignment: .bottom) { // Use ZStack for overlays
                MapKitView(viewModel: viewModel, mapType: mapType)
                   // No longer ignore safe area - let TabView handle it
                   // .edgesIgnoringSafeArea(.bottom)
                   .ignoresSafeArea(.container, edges: .top) // Ignore top safe area for full map under nav bar
                   .onAppear { // Call setup when the view appears
                       viewModel.setup(appState: appState)
                   }

                // Map Controls Overlay (Bottom)
                mapControls(viewModel: viewModel)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10) // Add corner radius to background
                    .padding(.bottom, 10) // Add padding from bottom edge
                
                // Buttons Overlay (Top Right)
                if appState.focusedRouteDay != nil {
                    // Use a VStack to stack the buttons vertically
                    VStack(spacing: 8) {
                        // Existing button to show full route
                        Button {
                            appState.focusedRouteDay = nil // Clear focus
                        } label: {
                            Label("Show Full Route", systemImage: "map.circle.fill")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue) 
                        .cornerRadius(10)
                        .shadow(radius: 3)

                        // ADDED: Button to show route details sheet
                        Button {
                            showingDetailSheet = true // Trigger the sheet
                        } label: {
                            Label("Route Details", systemImage: "list.bullet.rectangle.portrait.fill")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange) // Use a different color
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing) // Position top-right
                    .padding([.top, .trailing])
                }
            }
            // ADDED: Sheet modifier to present DestinationDetailView
            .sheet(isPresented: $showingDetailSheet) {
                // Find the destination for the focused day
                if let focusedDay = appState.focusedRouteDay,
                   let destination = CaminoDestination.allDestinations.first(where: { $0.day == focusedDay }) {
                    NavigationView { // Embed in NavigationView for title bar
                        DestinationDetailView(destination: destination)
                            .environmentObject(appState)
                    }
                } else {
                    // Fallback if destination not found (should not happen in normal use)
                    Text("Details not found for day \(appState.focusedRouteDay ?? -1)")
                }
            }
            .navigationTitle("Camino Map")
            .navigationBarTitleDisplayMode(.inline)
            // Keep alert binding
            .alert("Location Error", isPresented: $viewModel.isLocationAlertPresented) { 
                Button("OK") { }
            } message: {
                Text("Unable to access your location. Please ensure location services are enabled for Camino in Settings.")
            }
            // We might reintroduce the modal sheet later if needed for annotation taps
            /*
            .sheet(item: $viewModel.selectedDestinationForModal) { destination in
                 NavigationView { // Embed in NavigationView for title/toolbar
                     DestinationDetailView(destination: destination)
                         .environmentObject(appState)
                         .environmentObject(viewModel) // Pass viewModel if DetailView needs it
                 }
            }
            */
        }
        .navigationViewStyle(.stack) 
    }

    // Map Controls function remains largely the same
    @ViewBuilder 
    private func mapControls(viewModel: MapViewModel) -> some View {
        HStack(spacing: 8) {
            // Use the passed viewModel instance
            Button(action: { viewModel.zoomIn() }) { 
                Image(systemName: "plus.circle.fill")
            }
            Button(action: { viewModel.zoomOut() }) { 
                Image(systemName: "minus.circle.fill")
            }
            Button(action: { viewModel.centerOnUserLocation() }) { 
                 Image(systemName: "location.circle.fill")
                    .foregroundColor(viewModel.userLocation != nil ? .blue : .gray) // Check viewModel property
            }
            Button(action: { viewModel.centerOnStartingPoint() }) { 
                Image(systemName: "house.circle.fill")
                     .foregroundColor(.green)
            }
        }
        .font(.title2)
        .padding(5)
        .background(.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// MARK: - MapKit UIViewRepresentable View
struct MapKitView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    var mapType: MKMapType
    typealias Context = UIViewRepresentableContext<MapKitView>

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        mapView.showsUserLocation = true // Show user location dot
        mapView.setUserTrackingMode(.none, animated: false) // ADDED: Prevent initial auto-center on user
        // Register custom annotation view class if needed later
        // mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: "custom")
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update map type if changed
        if uiView.mapType != mapType {
            uiView.mapType = mapType
        }

        // Update annotations based on *current* state
        updateAnnotations(mapView: uiView, annotations: viewModel.currentAnnotations, context: context)
        
        // Update overlays based on *current* state
        updateOverlays(mapView: uiView, polyline: viewModel.currentPolyline, context: context)

        // ---> UPDATE MAP REGION <--- 
        // Check if the viewModel's region is different enough from the map's current region
        if !uiView.region.isApproximatelyEqual(to: viewModel.region) {
            // Use the viewModel's desired region
            print("updateUIView: Setting map region to viewModel.region (Center: \(viewModel.region.center), Span: \(viewModel.region.span))")
            uiView.setRegion(viewModel.region, animated: true) // Animate the change
        }
    }

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: viewModel)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        var viewModel: MapViewModel
        // Remove initialZoomDone flag

        init(_ parent: MapKitView, viewModel: MapViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        // --- Delegate Methods ---

        // Provide annotation views (customize pins)
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let caminoAnnotation = annotation as? CaminoMapAnnotation else {
                 if annotation is MKUserLocation { return nil }
                 return nil
            }

            let identifier = "CaminoPoint"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = false // Keep false if using custom modal/interaction
                view?.animatesWhenAdded = false
            } else {
                view?.annotation = annotation
            }

            // --- Annotation Customization based on Type --- 
            if caminoAnnotation.isStartPoint {
                view?.markerTintColor = .green
                view?.glyphImage = UIImage(systemName: "flag.fill")
                view?.displayPriority = .required
            } else if caminoAnnotation.isEndPoint {
                // Overview destinations AND focused day end points
                view?.markerTintColor = .red // Use red for all end/destination points
                view?.glyphImage = UIImage(systemName: "flag.checkered.2.crossed") // More distinct end flag
                view?.displayPriority = .required 
            } else if caminoAnnotation.isWaypoint {
                 // Waypoint (only shown in focused day mode)
                 print("DEBUG: Configuring waypoint annotation: \(caminoAnnotation.title ?? "Unknown")") // Debug print
                 view?.markerTintColor = .orange
                 view?.glyphImage = UIImage(systemName: "mappin")
                 view?.displayPriority = .defaultHigh // Slightly higher than default
            } else {
                 // Default / Fallback (Shouldn't happen often with new logic)
                 view?.markerTintColor = .purple
                 view?.glyphImage = UIImage(systemName: "pin.fill")
                 view?.displayPriority = .defaultLow
            }
            // --- End Annotation Customization ---
            
            return view
        }

        // Provide overlay renderers (for the polyline)
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3.5
                return renderer
            }
            return MKOverlayRenderer() // Default renderer for other overlay types
        }

        // Handle annotation selection (tap)
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            
            // Deselect immediately to prevent default callout/behavior
            mapView.deselectAnnotation(annotation, animated: false)

            // Tell the ViewModel which annotation was selected
            viewModel.annotationSelected(annotation)
        }
    }
    
    // MARK: - Helper methods for updateUIView
    
    // Update annotations - uses viewModel.currentAnnotations
    private func updateAnnotations(mapView: MKMapView, annotations: [MKAnnotation], context: Context) { 
         // Always remove old and add new annotations for simplicity
         mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
         mapView.addAnnotations(annotations)
     }

     // Update overlays - uses viewModel.currentPolyline
     private func updateOverlays(mapView: MKMapView, polyline: MKPolyline?, context: Context) {
          // Always remove old and add new overlays for simplicity
          mapView.removeOverlays(mapView.overlays)
          if let polyline = polyline {
              mapView.addOverlay(polyline)
          }
      }
}

// MARK: - Preview
#Preview {
     let previewAppState = CaminoAppState()
     return MapView()
          // Preview requires EnvironmentObjects directly
         .environmentObject(previewAppState) 
}

