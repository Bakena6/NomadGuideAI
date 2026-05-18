//
//  Landmark.swift
//  NomadGuideAI
//
//  Codable model matching data/landmarks/<region>.json.
//

import CoreLocation
import Foundation

struct LocalisedString: Codable, Hashable {
    let ru: String
    let en: String
    let kz: String?

    func value(for lang: AppLanguage) -> String {
        switch lang {
        case .ru: return ru
        case .en: return en
        case .kz: return kz ?? ru
        }
    }
}

struct LandmarkCoords: Codable, Hashable {
    let lat: Double
    let lon: Double

    var clLocation: CLLocation { CLLocation(latitude: lat, longitude: lon) }
    var coordinate: CLLocationCoordinate2D { .init(latitude: lat, longitude: lon) }
}

enum LandmarkCategory: String, Codable, CaseIterable {
    case natural
    case spiritual
    case city
    case historical
    case archeological
    case natural_phenomenon
    case cuisine
    case unknown

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = LandmarkCategory(rawValue: raw) ?? .unknown
    }

    var icon: String {
        switch self {
        case .natural, .natural_phenomenon: return "mountain.2.fill"
        case .spiritual: return "building.columns.fill"
        case .city: return "building.2.fill"
        case .historical: return "scroll.fill"
        case .archeological: return "shield.lefthalf.filled"
        case .cuisine: return "fork.knife"
        case .unknown: return "mappin"
        }
    }
}

struct Landmark: Codable, Identifiable, Hashable {
    let id: String
    let name: LocalisedString
    let coords: LandmarkCoords?
    let category: LandmarkCategory
    let keywords: [String]
    let content_ru: String
    let content_en: String?
    let audio: [String: String]?
    let source: String?

    func content(for lang: AppLanguage) -> String {
        switch lang {
        case .en:
            return content_en ?? content_ru
        case .ru, .kz:
            return content_ru
        }
    }
}

struct LandmarkRegion: Codable {
    let schema_version: String
    let region: String
    let region_name: LocalisedString
    let license_note: String?
    let landmarks: [Landmark]
}

enum AppLanguage: String, Codable, CaseIterable {
    case en
    case ru
    case kz

    var displayName: String {
        switch self {
        case .en: return "English"
        case .ru: return "Русский"
        case .kz: return "Қазақша"
        }
    }
}
