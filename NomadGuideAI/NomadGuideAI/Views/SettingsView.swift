//
//  SettingsView.swift
//  NomadGuideAI
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("app_language") private var language: AppLanguage = .en
    @StateObject private var store = POIStore.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Narration language") {
                    Picker("Language", selection: $language) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Content") {
                    LabeledContent("Region", value: store.region?.region_name.value(for: language) ?? "—")
                    LabeledContent("Landmarks", value: "\(store.landmarks.count)")
                    LabeledContent("With GPS", value: "\(store.landmarksWithCoords.count)")
                }

                Section("Backend") {
                    LabeledContent("Vision", value: "Qwen3-VL-4B (server) → on-device (v2)")
                    LabeledContent("TTS", value: "AVSpeech (offline)")
                }

                Section("About") {
                    if let note = store.region?.license_note {
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
