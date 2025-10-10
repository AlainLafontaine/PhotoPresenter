//
//  DSPresenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation

class DSPresenter: ObservableObject, Codable, Hashable {
    @Published var pahtFile: String
    @Published var windowPosition: WindowPosition

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case pahtFile
        case windowPosition
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pahtFile = try container.decode(String.self, forKey: .pahtFile)
        windowPosition = try container.decode(WindowPosition.self, forKey: .windowPosition)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pahtFile, forKey: .pahtFile)
        try container.encode(windowPosition, forKey: .windowPosition)
    }

    // MARK: - Hashable

    static func == (lhs: DSPresenter, rhs: DSPresenter) -> Bool {
        lhs.pahtFile == rhs.pahtFile &&
        lhs.windowPosition == rhs.windowPosition
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pahtFile)
        hasher.combine(windowPosition)
    }

    // MARK: - Initializer

    init(pahtFile: String, windowPosition: WindowPosition) {
        self.pahtFile = pahtFile
        self.windowPosition = windowPosition
    }
}
