//
//  DisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation

class DisplaySpace: ObservableObject, Codable, Hashable {
    @Published var displaySpaceHeader: DisplaySpaceHeader
    @Published var presenters: [DSPresenter]

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case displaySpaceHeader
        case presenters
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displaySpaceHeader = try container.decode(DisplaySpaceHeader.self, forKey: .displaySpaceHeader)
        presenters = try container.decode([DSPresenter].self, forKey: .presenters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displaySpaceHeader, forKey: .displaySpaceHeader)
        try container.encode(presenters, forKey: .presenters)
    }

    // MARK: - Hashable

    static func == (lhs: DisplaySpace, rhs: DisplaySpace) -> Bool {
        lhs.displaySpaceHeader == rhs.displaySpaceHeader &&
        lhs.presenters == rhs.presenters
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(displaySpaceHeader)
        hasher.combine(presenters)
    }

    // MARK: - Initializer

    init(displaySpaceHeader: DisplaySpaceHeader, presenters: [DSPresenter]) {
        self.displaySpaceHeader = displaySpaceHeader
        self.presenters = presenters
    }
}
