//
//  SettingsView.swift
//  NomadGuideAI
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("app_language") private var language: AppLanguage = .en
    @StateObject private var store = POIStore.shared

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }

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
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
