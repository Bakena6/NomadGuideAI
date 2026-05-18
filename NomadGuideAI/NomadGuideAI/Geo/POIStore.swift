//
//  POIStore.swift
//  NomadGuideAI
//
//  Loads the bundled landmarks JSON and answers GPS queries.
//

import CoreLocation
import Foundation
import Combine

@MainActor
final class POIStore: ObservableObject {
    static let shared = POIStore()

    @Published private(set) var region: LandmarkRegion?
    @Published private(set) var landmarks: [Landmark] = []

    var landmarksWithCoords: [Landmark] {
        landmarks.filter { $0.coords != nil }
    }

    private init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") else {
            print("⚠️ landmarks.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let region = try JSONDecoder().decode(LandmarkRegion.self, from: data)
            self.region = region
            self.landmarks = region.landmarks
            print("✓ POIStore loaded \(region.landmarks.count) landmarks for \(region.region)")
        } catch {
            print("⚠️ POIStore decode failed: \(error)")
        }
    }

    /// Nearest landmark to a coordinate, within `maxKm`. Skips landmarks without coords.
    func nearest(to location: CLLocation, maxKm: Double = 30) -> (landmark: Landmark, distanceKm: Double)? {
        var best: Landmark?
        var bestKm: Double = .greatestFiniteMagnitude
        for lm in landmarks {
            guard let c = lm.coords else { continue }
            let km = location.distance(from: c.clLocation) / 1000
            if km < bestKm {
                bestKm = km
                best = lm
            }
        }
        if let best, bestKm <= maxKm { return (best, bestKm) }
        return nil
    }

    /// Up to `limit` landmarks within `radiusKm`, sorted ascending by distance.
    func nearby(to location: CLLocation, radiusKm: Double = 50, limit: Int = 8) -> [(Landmark, Double)] {
        landmarks.compactMap { lm -> (Landmark, Double)? in
            guard let c = lm.coords else { return nil }
            let km = location.distance(from: c.clLocation) / 1000
            return km <= radiusKm ? (lm, km) : nil
        }
        .sorted { $0.1 < $1.1 }
        .prefix(limit)
        .map { $0 }
    }
}
