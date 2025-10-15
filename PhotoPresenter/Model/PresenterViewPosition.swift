//
//  PresenterViewPosition.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation
import AppKit

class PresenterViewPosition: ObservableObject, Identifiable, Codable, Hashable {
    // MARK: - Identifiable
    let id: UUID

    // MARK: - Published properties
    @Published var pahtFile: String
    @Published var windowPosition: WindowPosition

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, pahtFile, windowPosition
    }

    // MARK: - Init
    init(id: UUID = UUID(), pahtFile: String, windowPosition: WindowPosition) {
        self.id = id
        self.pahtFile = pahtFile
        self.windowPosition = windowPosition
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pahtFile = try container.decode(String.self, forKey: .pahtFile)
        windowPosition = try container.decode(WindowPosition.self, forKey: .windowPosition)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pahtFile, forKey: .pahtFile)
        try container.encode(windowPosition, forKey: .windowPosition)
    }

    // MARK: - Hashable
    static func == (lhs: PresenterViewPosition, rhs: PresenterViewPosition) -> Bool {
        lhs.id == rhs.id &&
        lhs.pahtFile == rhs.pahtFile &&
        lhs.windowPosition == rhs.windowPosition
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pahtFile)
        hasher.combine(windowPosition)
    }
}
