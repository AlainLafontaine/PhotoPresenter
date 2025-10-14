//
//  DSPresenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation
import AppKit

class DSPresenter: ObservableObject, Identifiable, Codable, Hashable {
    // MARK: - Identifiable
    let id: UUID

    // MARK: - Published properties
    @Published var name: String
    @Published var pahtFile: String
    @Published var windowPosition: WindowPosition

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, name, pahtFile, windowPosition
    }

    // MARK: - Init
    init(id: UUID = UUID(), name: String, pahtFile: String, windowPosition: WindowPosition) {
        self.id = id
        self.name = name
        self.pahtFile = pahtFile
        self.windowPosition = windowPosition
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        pahtFile = try container.decode(String.self, forKey: .pahtFile)
        windowPosition = try container.decode(WindowPosition.self, forKey: .windowPosition)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(pahtFile, forKey: .pahtFile)
        try container.encode(windowPosition, forKey: .windowPosition)
    }

    // MARK: - Hashable
    static func == (lhs: DSPresenter, rhs: DSPresenter) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.pahtFile == rhs.pahtFile &&
        lhs.windowPosition == rhs.windowPosition
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(pahtFile)
        hasher.combine(windowPosition)
    }
}
