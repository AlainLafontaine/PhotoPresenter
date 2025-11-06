//
//  SharedRessource.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-11-05.
//

import Foundation

class SharedRessources: ObservableObject, Codable, Hashable {
    // MARK: - Published Properties
    @Published var screenNames2FriendlyNames: [ScreenName2FriendlyName]

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case screenNames2FriendlyNames
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screenNames2FriendlyNames = try container.decode([ScreenName2FriendlyName].self, forKey: .screenNames2FriendlyNames)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screenNames2FriendlyNames, forKey: .screenNames2FriendlyNames)
    }

    // MARK: - Initializer
    init(screenNames2FriendlyNames: [ScreenName2FriendlyName] = []) {
        self.screenNames2FriendlyNames = screenNames2FriendlyNames
    }

    // MARK: - Hashable
    static func == (lhs: SharedRessources, rhs: SharedRessources) -> Bool {
        lhs.screenNames2FriendlyNames == rhs.screenNames2FriendlyNames
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(screenNames2FriendlyNames)
    }
}
