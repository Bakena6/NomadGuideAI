//
//  CameraView.swift
//  NomadGuideAI
//
//  Camera preview layer as SwiftUI view.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController

    func makeUIViewController(context: Context) -> CameraViewController {
        CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    private let cameraManager = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        let preview = AVCaptureVideoPreviewLayer(session: cameraManager.session)
        preview.frame = view.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)

        // Add tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    @objc func handleTap() {
        cameraManager.capturePhoto()
    }
}
