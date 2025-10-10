//
//  GroupedView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

import Foundation

class GroupedView: ObservableObject, Codable, Hashable {
    @Published var nbOfView: Int
    @Published var viewSettings: [ViewSetting]
    @Published var fastLoaddings: [FastLoading]?

    // MARK: - Initializer

    init(nbOfView: Int, viewSettings: [ViewSetting], fastLoaddings: [FastLoading]? = nil) {
        self.nbOfView = nbOfView
        self.viewSettings = viewSettings
        self.fastLoaddings = fastLoaddings
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case nbOfView
        case viewSettings
        case fastLoaddings
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nbOfView = try container.decode(Int.self, forKey: .nbOfView)
        let viewSettings = try container.decode([ViewSetting].self, forKey: .viewSettings)
        let fastLoaddings = try container.decodeIfPresent([FastLoading].self, forKey: .fastLoaddings)
        self.init(nbOfView: nbOfView, viewSettings: viewSettings, fastLoaddings: fastLoaddings)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nbOfView, forKey: .nbOfView)
        try container.encode(viewSettings, forKey: .viewSettings)
        try container.encodeIfPresent(fastLoaddings, forKey: .fastLoaddings)
    }

    // MARK: - Hashable

    static func == (lhs: GroupedView, rhs: GroupedView) -> Bool {
        lhs.nbOfView == rhs.nbOfView &&
        lhs.viewSettings == rhs.viewSettings &&
        lhs.fastLoaddings == rhs.fastLoaddings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nbOfView)
        hasher.combine(viewSettings)
        hasher.combine(fastLoaddings)
    }
}
