//
//  VisionService.swift
//  NomadGuideAI
//
//  Hybrid online/offline vision pipeline.
//
//  - ServerVisionService: calls our Qwen3-VL backend on vast.ai (fast, accurate, requires network)
//  - OnDeviceVisionService: MLXVLM placeholder (v2 — fully offline, slower)
//  - HybridVisionService: prefers server when reachable, falls back on-device.
//

import CoreLocation
import Foundation
import UIKit

struct VisionResult {
    let text: String
    let matchedLandmarkId: String?
    let matchedLandmarkName: String?
    let distanceKm: Double?
    let latencyMs: Int
    let source: String
}

enum VisionError: Error, LocalizedError {
    case network(String)
    case backend(Int, String)
    case decoding(String)
    case offline

    var errorDescription: String? {
        switch self {
        case .network(let m): return "Network error: \(m)"
        case .backend(let code, let m): return "Backend \(code): \(m)"
        case .decoding(let m): return "Decoding error: \(m)"
        case .offline: return "Offline (server unreachable)"
        }
    }
}

protocol VisionService {
    func analyze(image: UIImage, location: CLLocation?, language: AppLanguage) async throws -> VisionResult
}

// MARK: - Server backend

final class ServerVisionService: VisionService {
    let baseURL: URL

    init(baseURL: URL = URL(string: "http://ssh7.vast.ai:37555")!) {
        self.baseURL = baseURL
    }

    func analyze(image: UIImage, location: CLLocation?, language: AppLanguage) async throws -> VisionResult {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw VisionError.network("could not encode image as JPEG")
        }

        let boundary = "boundary-\(UUID().uuidString)"
        var req = URLRequest(url: baseURL.appendingPathComponent("analyze"))
        req.httpMethod = "POST"
        req.timeoutInterval = 30
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        field("lang", language.rawValue)
        if let loc = location {
            field("gps_lat", String(loc.coordinate.latitude))
            field("gps_lon", String(loc.coordinate.longitude))
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        let (respData, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw VisionError.network("no HTTP response")
        }
        guard http.statusCode == 200 else {
            let msg = String(data: respData, encoding: .utf8) ?? "?"
            throw VisionError.backend(http.statusCode, msg)
        }

        struct Payload: Decodable {
            let text: String
            let matched_landmark: String?
            let matched_landmark_name: String?
            let distance_km: Double?
            let latency_ms: Int
            let lang: String?
        }

        do {
            let p = try JSONDecoder().decode(Payload.self, from: respData)
            return VisionResult(
                text: p.text,
                matchedLandmarkId: p.matched_landmark,
                matchedLandmarkName: p.matched_landmark_name,
                distanceKm: p.distance_km,
                latencyMs: p.latency_ms,
                source: "server"
            )
        } catch {
            throw VisionError.decoding(error.localizedDescription)
        }
    }
}

// MARK: - On-device (v2 — placeholder)

final class OnDeviceVisionService: VisionService {
    func analyze(image: UIImage, location: CLLocation?, language: AppLanguage) async throws -> VisionResult {
        // TODO v2: MLXVLM with Qwen3-VL-4B-Instruct (4-bit) loaded from app bundle / ODR.
        // For now we return a friendly placeholder so the hybrid path compiles and
        // we can test the offline UX flow before the model is wired up.
        try await Task.sleep(nanoseconds: 600_000_000)
        return VisionResult(
            text: "Offline mode is not yet available. Please connect to the internet — the on-device AI model will be added in the next update.",
            matchedLandmarkId: nil,
            matchedLandmarkName: nil,
            distanceKm: nil,
            latencyMs: 0,
            source: "on-device-stub"
        )
    }
}

// MARK: - Hybrid: server-first, on-device fallback

final class HybridVisionService: VisionService {
    let server: VisionService
    let onDevice: VisionService

    init(server: VisionService = ServerVisionService(),
         onDevice: VisionService = OnDeviceVisionService()) {
        self.server = server
        self.onDevice = onDevice
    }

    func analyze(image: UIImage, location: CLLocation?, language: AppLanguage) async throws -> VisionResult {
        do {
            return try await server.analyze(image: image, location: location, language: language)
        } catch {
            print("⚠️ Server vision failed (\(error)) — falling back on-device")
            return try await onDevice.analyze(image: image, location: location, language: language)
        }
    }
}
