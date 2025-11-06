//
//  ScreenName2FriendlyName.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-11-05.
//

import Foundation

class ScreenName2FriendlyName: ObservableObject, Codable, Hashable {
    // MARK: - Properties
    var id: UUID = UUID()

    @Published var screenName: String
    @Published var friendlyName: String

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case screenName
        case friendlyName
    }

    // MARK: - Init
    init(screenName: String, friendlyName: String) {
        self.screenName = screenName
        self.friendlyName = friendlyName
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        screenName = try container.decode(String.self, forKey: .screenName)
        friendlyName = try container.decode(String.self, forKey: .friendlyName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(screenName, forKey: .screenName)
        try container.encode(friendlyName, forKey: .friendlyName)
    }

    // MARK: - Hashable
    static func == (lhs: ScreenName2FriendlyName, rhs: ScreenName2FriendlyName) -> Bool {
        lhs.id == rhs.id &&
        lhs.screenName == rhs.screenName &&
        lhs.friendlyName == rhs.friendlyName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(screenName)
        hasher.combine(friendlyName)
    }
}
