//
//  RootView.swift
//  NomadGuideAI
//

import SwiftUI

struct RootView: View {
    @AppStorage("selected_tab") private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem { Label("Camera", systemImage: "camera.fill") }
                .tag(0)
            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
                .tag(1)
            RoutesView()
                .tabItem { Label("Routes", systemImage: "list.bullet.rectangle.portrait") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
    }
}
