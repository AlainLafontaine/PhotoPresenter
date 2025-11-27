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
    @Published var paths2PresenterDirectory: [String]
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case screenNames2FriendlyNames
        case paths2PresenterDirectory
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screenNames2FriendlyNames = try container.decode([ScreenName2FriendlyName].self, forKey: .screenNames2FriendlyNames)
        paths2PresenterDirectory = try container.decode([String].self, forKey: .paths2PresenterDirectory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screenNames2FriendlyNames, forKey: .screenNames2FriendlyNames)
        try container.encode(paths2PresenterDirectory, forKey: .paths2PresenterDirectory)
    }

    // MARK: - Initializer
    init(screenNames2FriendlyNames: [ScreenName2FriendlyName] = [], paths2PresenterDirectory: [String] = []) {
        self.screenNames2FriendlyNames = screenNames2FriendlyNames
        self.paths2PresenterDirectory = paths2PresenterDirectory
    }

    // MARK: - Hashable
    static func == (lhs: SharedRessources, rhs: SharedRessources) -> Bool {
        lhs.screenNames2FriendlyNames == rhs.screenNames2FriendlyNames &&
        lhs.paths2PresenterDirectory == rhs.paths2PresenterDirectory
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(screenNames2FriendlyNames)
        hasher.combine(paths2PresenterDirectory)
    }
}
