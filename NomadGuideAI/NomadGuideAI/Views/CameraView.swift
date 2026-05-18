//
//  CameraView.swift
//  NomadGuideAI
//
//  Photo capture / picker via UIImagePickerController, plus the analysis sheet.
//

import CoreLocation
import Combine
import SwiftUI
import UIKit

struct CameraView: View {
    @AppStorage("app_language") private var language: AppLanguage = .en

    @State private var pickedImage: UIImage?
    @State private var showPicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera

    @State private var result: VisionResult?
    @State private var isAnalyzing = false
    @State private var error: String?

    @StateObject private var location = LocationManager()
    @StateObject private var speech = SpeechService.shared

    private let vision: VisionService = HybridVisionService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let image = pickedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .frame(maxHeight: 280)
                    } else {
                        placeholder
                    }

                    HStack {
                        Button {
                            pickerSource = .camera
                            showPicker = true
                        } label: {
                            Label("Camera", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))

                        Button {
                            pickerSource = .photoLibrary
                            showPicker = true
                        } label: {
                            Label("Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                    }

                    if isAnalyzing {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Analyzing…")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }

                    if let result {
                        resultCard(result)
                    }

                    if let error {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("NomadGuide")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(source: pickerSource) { image in
                pickedImage = image
                Task { await analyze(image) }
            }
        }
        .task {
            location.requestPermission()
        }
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Point at a landmark or send a photo from your library")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
    }

    private func resultCard(_ r: VisionResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let name = r.matchedLandmarkName {
                Text(name)
                    .font(.title3.bold())
                if let km = r.distanceKm {
                    Label(String(format: "%.1f km from you", km), systemImage: "location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(r.text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Button {
                    speech.isSpeaking ? speech.stop() : speech.speak(r.text, language: language)
                } label: {
                    Label(speech.isSpeaking ? "Stop" : "Listen",
                          systemImage: speech.isSpeaking ? "stop.circle.fill" : "speaker.wave.2.fill")
                }
                .buttonStyle(.borderedProminent)

                Spacer()

                Text("⏱ \(r.latencyMs / 1000)s · \(r.source)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
    }

    private func analyze(_ image: UIImage) async {
        error = nil
        result = nil
        isAnalyzing = true
        defer { isAnalyzing = false }
        do {
            let r = try await vision.analyze(image: image,
                                             location: location.current,
                                             language: language)
            self.result = r
            speech.speak(r.text, language: language)
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// MARK: - Image picker

struct ImagePicker: UIViewControllerRepresentable {
    let source: UIImagePickerController.SourceType
    let onImage: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.sourceType = source
        p.delegate = context.coordinator
        return p
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.onImage(img)
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Location manager

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var current: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in self.current = loc }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Location error: \(error)")
    }
}
