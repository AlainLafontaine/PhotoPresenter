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
    @Published var ratio: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case orientation
        case ratio
    }

    init(
        name: String,
        description: String?,
        orientation: Orientation,
        ratio: Double? = nil
    ) {
        self.name = name
        self.description = description
        self.orientation = orientation
        self.ratio = ratio
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        orientation = try container.decode(Orientation.self, forKey: .orientation)
        ratio = try container.decodeIfPresent(Double.self, forKey: .ratio)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(orientation, forKey: .orientation)
        try container.encodeIfPresent(ratio, forKey: .ratio)
    }

    static func == (lhs: PhotoPresenterHeader, rhs: PhotoPresenterHeader) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.orientation == rhs.orientation &&
        lhs.ratio == rhs.ratio
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(orientation)
        hasher.combine(ratio)
    }
}
