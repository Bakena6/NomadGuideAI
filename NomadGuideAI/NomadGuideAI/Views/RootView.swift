//
//  RootView.swift
//  NomadGuideAI
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem { Label("Camera", systemImage: "camera.fill") }

            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }

            RoutesView()
                .tabItem { Label("Routes", systemImage: "list.bullet.rectangle.portrait") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
