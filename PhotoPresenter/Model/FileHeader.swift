//
//  FileHeader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

class FileHeader: ObservableObject, Codable, Hashable {
    @Published var name: String
    @Published var description: String?
    @Published var orientation: Orientation

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, description, orientation
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        orientation = try c.decode(Orientation.self, forKey: .orientation)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encode(orientation, forKey: .orientation)
    }

    // MARK: - Hashable
    static func == (lhs: FileHeader, rhs: FileHeader) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.orientation == rhs.orientation
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(orientation)
    }

    // MARK: - Initializer
    init(name: String, description: String?, orientation: Orientation) {
        self.name = name
        self.description = description
        self.orientation = orientation
    }
}
