//
//  CameraManager.swift
//  NomadGuideAI
//
//  Camera pipeline using AVFoundation.
//

import AVFoundation
import CoreImage
import UIKit

@MainActor
class CameraManager: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var capturedImage: UIImage?

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "camera.session.queue")

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        queue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(
                .builtInUltraWideCamera,
                for: .video,
                position: .back
            ) ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            else {
                print("⚠ No camera available")
                self.session.commitConfiguration()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(input) else { return }
                self.session.addInput(input)
            } catch {
                print("⚠ Camera input error: \(error)")
                self.session.commitConfiguration()
                return
            }

            guard self.session.canAddOutput(self.output) else { return }
            self.session.addOutput(self.output)
            self.session.commitConfiguration()
            self.session.startRunning()

            DispatchQueue.main.async {
                self.isSessionRunning = true
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        Task { @MainActor in
            capturedImage = image
        }
    }
}
