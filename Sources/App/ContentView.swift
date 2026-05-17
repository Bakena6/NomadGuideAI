//
//  ContentView.swift
//  NomadGuideAI
//
//  Main camera-first interface.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLanguagePicker = false
    @State private var showGallery = false

    var body: some View {
        Group {
            if appState.isLoading {
                LoadingView()
            } else {
                NavigationStack {
                    CameraView()
                        .overlay(alignment: .topTrailing) {
                            HStack(spacing: 16) {
                                Button { showLanguagePicker.toggle() } label: {
                                    Image(systemName: "globe")
                                        .font(.title2)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }

                                Button { showGallery.toggle() } label: {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                        }
                        .overlay(alignment: .bottom) {
                            VStack(spacing: 8) {
                                Text("Point camera at a landmark")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())

                                Text("Tap to identify")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.bottom, 40)
                        }
                }
                .sheet(isPresented: $showLanguagePicker) {
                    LanguagePickerView()
                }
            }
        }
    }
}

struct LoadingView: View {
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "binoculars.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .scaleEffect(pulse ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: pulse)
                .onAppear { pulse = true }

            Text("Loading NomadGuide AI...")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Preparing your AI travel companion")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
