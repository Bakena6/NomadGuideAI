//
//  LanguagePickerView.swift
//  NomadGuideAI
//
//  Language selection for the tourist.
//

import SwiftUI

struct Language: Identifiable {
    let id: String
    let name: String
    let nativeName: String
    let flag: String

    static let all: [Language] = [
        Language(id: "en", name: "English", nativeName: "English", flag: "🇬🇧"),
        Language(id: "zh", name: "Chinese", nativeName: "中文", flag: "🇨🇳"),
        Language(id: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪"),
        Language(id: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷"),
        Language(id: "tr", name: "Turkish", nativeName: "Türkçe", flag: "🇹🇷"),
        Language(id: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        Language(id: "hi", name: "Hindi", nativeName: "हिन्दी", flag: "🇮🇳"),
        Language(id: "ar", name: "Arabic", nativeName: "العربية", flag: "🇸🇦"),
        Language(id: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        Language(id: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵"),
        Language(id: "it", name: "Italian", nativeName: "Italiano", flag: "🇮🇹"),
        Language(id: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
    ]
}

struct LanguagePickerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(Language.all) { lang in
                Button {
                    appState.currentLanguage = lang.id
                    dismiss()
                } label: {
                    HStack {
                        Text(lang.flag)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(lang.name)
                                .fontWeight(.medium)
                            Text(lang.nativeName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if appState.currentLanguage == lang.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
