//
//  PhotoPresenterHeader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

class PhotoPresenterHeader: ObservableObject, Codable, Hashable {
    @Published var name: String
    @Published var description: String?
    @Published var orientation: Orientation

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case orientation
    }

    init(name: String, description: String?, orientation: Orientation) {
        self.name = name
        self.description = description
        self.orientation = orientation
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        orientation = try container.decode(Orientation.self, forKey: .orientation)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(orientation, forKey: .orientation)
    }

    static func == (lhs: PhotoPresenterHeader, rhs: PhotoPresenterHeader) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.orientation == rhs.orientation
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(orientation)
    }
}
