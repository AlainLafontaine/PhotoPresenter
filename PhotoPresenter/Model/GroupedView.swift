//
//  GroupedView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

class GroupedView: ObservableObject, Codable, Hashable {
    @Published var nbOfView: Int
    @Published var photoPresenterDataSources: [PhotoPresenterDataSource]

    var fastLoaddings: [FastLoading]?

    // MARK: - Coding Keys
    // Note Evo_012 : les ViewSetting sont désormais persistés dans le fichier
    // DisplaySpace (PresenterViewPosition.viewSettings). L'ancienne clé JSON
    // packInDisplaySpaces, si encore présente dans un fichier, est ignorée.
    enum CodingKeys: String, CodingKey {
        case nbOfView
        case photoPresenterDataSources
        case fastLoaddings
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nbOfView = try container.decode(Int.self, forKey: .nbOfView)
        photoPresenterDataSources = try container.decode([PhotoPresenterDataSource].self, forKey: .photoPresenterDataSources)
        fastLoaddings = try container.decodeIfPresent([FastLoading].self, forKey: .fastLoaddings)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nbOfView, forKey: .nbOfView)
        try container.encodeIfPresent(photoPresenterDataSources, forKey: .photoPresenterDataSources)
        try container.encodeIfPresent(fastLoaddings, forKey: .fastLoaddings)
    }

    // MARK: - Hashable
    static func == (lhs: GroupedView, rhs: GroupedView) -> Bool {
        lhs.nbOfView == rhs.nbOfView &&
        lhs.photoPresenterDataSources == rhs.photoPresenterDataSources &&
        lhs.fastLoaddings == rhs.fastLoaddings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nbOfView)
        hasher.combine(photoPresenterDataSources)
        hasher.combine(fastLoaddings)
    }

    // MARK: - Initializer
    init(nbOfView: Int,
         photoPresenterDataSources: [PhotoPresenterDataSource],
         fastLoaddings: [FastLoading]? = nil) {
        self.nbOfView = nbOfView
        self.photoPresenterDataSources = photoPresenterDataSources
        self.fastLoaddings = fastLoaddings
    }
}
