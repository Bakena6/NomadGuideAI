//
//  NomadGuideAI App.swift
//  NomadGuideAI
//
//  Offline AI audio guide for Kazakhstan.
//

import SwiftUI

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
