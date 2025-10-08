//
//  GroupedView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

class GroupedView: ObservableObject, Codable, Hashable {
    @Published var nbOfView: Int
    @Published var viewSettings: [ViewSetting]

    enum CodingKeys: String, CodingKey {
        case nbOfView, viewSettings
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        nbOfView = try c.decode(Int.self, forKey: .nbOfView)
        viewSettings = try c.decode([ViewSetting].self, forKey: .viewSettings)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(nbOfView, forKey: .nbOfView)
        try c.encode(viewSettings, forKey: .viewSettings)
    }

    static func == (lhs: GroupedView, rhs: GroupedView) -> Bool {
        lhs.nbOfView == rhs.nbOfView && lhs.viewSettings == rhs.viewSettings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nbOfView)
        hasher.combine(viewSettings)
    }

    init(nbOfView: Int, viewSettings: [ViewSetting]) {
        self.nbOfView = nbOfView
        self.viewSettings = viewSettings
    }
}
