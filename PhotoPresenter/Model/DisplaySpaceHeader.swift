//
//  DisplaySpaceHeader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation

class DisplaySpaceHeader: ObservableObject, Codable, Hashable {
    @Published var name: String
    @Published var description: String?

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case name
        case description
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
    }

    // MARK: - Hashable

    static func == (lhs: DisplaySpaceHeader, rhs: DisplaySpaceHeader) -> Bool {
        lhs.name == rhs.name && lhs.description == rhs.description
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
    }

    // MARK: - Initializer

    init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}
