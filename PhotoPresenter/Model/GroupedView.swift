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
    @Published var packInDisplaySpaces: [PackInDisplaySpace]?
    @Published var viewSettings: [ViewSetting]?
               var fastLoaddings: [FastLoading]?

    // MARK: - Initializer

    init(
        nbOfView: Int, 
        packInDisplaySpaces: [PackInDisplaySpace]? = nil,
        viewSettings: [ViewSetting]? = nil, 
        fastLoaddings: [FastLoading]? = nil
    ) {
        self.nbOfView = nbOfView
        self.packInDisplaySpaces = packInDisplaySpaces
        self.viewSettings = viewSettings
        self.fastLoaddings = fastLoaddings
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case nbOfView
        case packInDisplaySpaces
        case viewSettings
        case fastLoaddings
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nbOfView = try container.decode(Int.self, forKey: .nbOfView)
        let packInDisplaySpaces = try container.decodeIfPresent([PackInDisplaySpace].self, forKey: .packInDisplaySpaces)
        let viewSettings = try container.decodeIfPresent([ViewSetting].self, forKey: .viewSettings)
        let fastLoaddings = try container.decodeIfPresent([FastLoading].self, forKey: .fastLoaddings)
        self.init(
            nbOfView: nbOfView, 
            packInDisplaySpaces: packInDisplaySpaces,
            viewSettings: viewSettings, 
            fastLoaddings: fastLoaddings
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nbOfView, forKey: .nbOfView)
        try container.encodeIfPresent(packInDisplaySpaces, forKey: .packInDisplaySpaces)
        try container.encodeIfPresent(viewSettings, forKey: .viewSettings)
        try container.encodeIfPresent(fastLoaddings, forKey: .fastLoaddings)
    }

    // MARK: - Hashable

    static func == (lhs: GroupedView, rhs: GroupedView) -> Bool {
        lhs.nbOfView == rhs.nbOfView &&
        lhs.packInDisplaySpaces == rhs.packInDisplaySpaces &&
        lhs.viewSettings == rhs.viewSettings &&
        lhs.fastLoaddings == rhs.fastLoaddings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nbOfView)
        hasher.combine(packInDisplaySpaces)
        hasher.combine(viewSettings)
        hasher.combine(fastLoaddings)
    }
}
