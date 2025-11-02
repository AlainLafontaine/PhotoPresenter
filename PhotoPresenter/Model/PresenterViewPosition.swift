//
//  PresenterViewPosition.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation
import AppKit

final class PresenterViewPosition: ObservableObject, Identifiable, Codable, Hashable {
    // MARK: - Identifiable
    var id: UUID

    // MARK: - Published properties
    @Published var pathFile: String
    @Published var windowPosition: WindowPosition

    // MARK: - Init
    init(id: UUID = UUID(), pathFile: String, windowPosition: WindowPosition) {
        self.id = id
        self.pathFile = pathFile
        self.windowPosition = windowPosition
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, pathFile, windowPosition
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pathFile = try container.decode(String.self, forKey: .pathFile)
        windowPosition = try container.decode(WindowPosition.self, forKey: .windowPosition)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pathFile, forKey: .pathFile)
        try container.encode(windowPosition, forKey: .windowPosition)
    }

    // MARK: - Hashable
    static func == (lhs: PresenterViewPosition, rhs: PresenterViewPosition) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
