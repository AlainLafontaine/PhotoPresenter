//
//  FileHeader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

import Foundation

class FileHeader: ObservableObject, Codable, Hashable {
    @Published var name: String
    @Published var description: String?
    @Published var orientation: Orientation
    @Published var windowPosition: WindowPosition?

    // MARK: - Initializer
    init(name: String, description: String?, orientation: Orientation, windowPosition: WindowPosition? = nil) {
        self.name = name
        self.description = description
        self.orientation = orientation
        self.windowPosition = windowPosition
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case name, description, orientation, windowPosition
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        orientation = try c.decode(Orientation.self, forKey: .orientation)
        windowPosition = try c.decodeIfPresent(WindowPosition.self, forKey: .windowPosition)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encode(orientation, forKey: .orientation)
        try c.encodeIfPresent(windowPosition, forKey: .windowPosition)
    }

    // MARK: - Hashable
    static func == (lhs: FileHeader, rhs: FileHeader) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.orientation == rhs.orientation &&
        lhs.windowPosition == rhs.windowPosition
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(orientation)
        hasher.combine(windowPosition)
    }
}
