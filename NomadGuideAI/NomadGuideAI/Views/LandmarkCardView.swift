//
//  LandmarkCardView.swift
//  NomadGuideAI
//
//  Detail sheet for a landmark — title, narration text, AVSpeech playback.
//

import SwiftUI

struct LandmarkCardView: View {
    let landmark: Landmark

    @AppStorage("app_language") private var language: AppLanguage = .en
    @StateObject private var speech = SpeechService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(landmark.name.value(for: language))
                            .font(.title2.bold())
                        Text(categoryLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(landmark.content(for: language))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Button {
                            speech.isSpeaking
                                ? speech.stop()
                                : speech.speak(landmark.content(for: language), language: language)
                        } label: {
                            Label(speech.isSpeaking ? "Stop" : "Listen",
                                  systemImage: speech.isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if let source = landmark.source {
                        Text("Source: \(source)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear { speech.stop() }
    }

    private var categoryLabel: String {
        switch landmark.category {
        case .natural, .natural_phenomenon: return "Natural"
        case .spiritual: return "Sacred site"
        case .city: return "City / Base"
        case .historical: return "Historical"
        case .archeological: return "Archeological"
        case .cuisine: return "Food / Tradition"
        case .unknown: return ""
        }
    }
}
