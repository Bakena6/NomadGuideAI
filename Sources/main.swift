//
//  main.swift
//  NomadGuideAI
//

import SwiftUI

@main
struct NomadGuideAIApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

class AppState: ObservableObject {
    @Published var isModelLoaded = false
    @Published var currentLanguage: String = "en"
    @Published var isLoading = true

    init() {
        loadModel()
    }

    func loadModel() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // LLM, RAG, TTS initialization
            DispatchQueue.main.async {
                self?.isModelLoaded = true
                self?.isLoading = false
            }
        }
    }
}
