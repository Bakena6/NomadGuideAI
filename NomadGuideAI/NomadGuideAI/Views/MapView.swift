//
//  MapView.swift
//  NomadGuideAI
//
//  MapKit map with all landmarks that have coordinates.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var store = POIStore.shared
    @State private var selected: Landmark?
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.85, longitude: 52.0),
            span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
        )
    )

    var body: some View {
        NavigationStack {
            Map(position: $camera, selection: $selected) {
                ForEach(store.landmarksWithCoords) { lm in
                    if let c = lm.coords {
                        Marker(lm.name.ru,
                               systemImage: lm.category.icon,
                               coordinate: c.coordinate)
                            .tint(color(for: lm.category))
                            .tag(lm)
                    }
                }
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle("Map · Mangystau")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selected) { lm in
                LandmarkCardView(landmark: lm)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func color(for category: LandmarkCategory) -> Color {
        switch category {
        case .natural, .natural_phenomenon: return .green
        case .spiritual: return .orange
        case .city: return .blue
        case .historical: return .brown
        case .archeological: return .purple
        case .cuisine: return .red
        case .unknown: return .gray
        }
    }
}
