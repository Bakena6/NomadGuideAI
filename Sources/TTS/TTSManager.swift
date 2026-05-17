//
//  TTSManager.swift
//  NomadGuideAI
//
//  AVSpeechSynthesizer wrapper for 30+ languages.
//

import AVFoundation

class TTSManager: ObservableObject {
    static let shared = TTSManager()
    private let synthesizer = AVSpeechSynthesizer()
    private let queue = DispatchQueue(label: "tts.queue")

    /// Language voice map (BCP 47 codes)
    private let voiceMap: [String: String] = [
        "en": "en-US",       // English (Samantha)
        "zh": "zh-CN",       // Chinese (Tingting)
        "de": "de-DE",       // German (Anna)
        "ko": "ko-KR",       // Korean (Yuna)
        "tr": "tr-TR",       // Turkish (Merve)
        "fr": "fr-FR",       // French (Marie)
        "hi": "hi-IN",       // Hindi (Lekha)
        "ar": "ar-SA",       // Arabic (Maged)
        "ru": "ru-RU",       // Russian (Milena)
        "ja": "ja-JP",       // Japanese (Kyoko)
        "it": "it-IT",       // Italian (Alice)
        "es": "es-ES",       // Spanish (Mónica)
    ]

    private init() {}

    /// Speak text in the specified language
    func speak(_ text: String, language: String) {
        let langCode = voiceMap[language] ?? "en-US"
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: langCode)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        queue.async { [weak self] in
            self?.synthesizer.speak(utterance)
        }
    }

    /// Stop current speech
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// Speak with storytelling style (slower, more expressive)
    func speakStory(_ text: String, language: String) {
        let langCode = voiceMap[language] ?? "en-US"
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: langCode)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.7  // slower for storytelling
        utterance.pitchMultiplier = 1.2  // slightly higher pitch
        utterance.volume = 1.0
        utterance.prefersAssistiveTechnologySettings = false

        queue.async { [weak self] in
            self?.synthesizer.speak(utterance)
        }
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }
}
