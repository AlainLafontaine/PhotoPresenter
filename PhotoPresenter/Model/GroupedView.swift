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
    @Published var photoPresenterDataSources: [PhotoPresenterDataSource]
    @Published var packInDisplaySpaces: [PackInDisplaySpace]?
    
    var fastLoaddings: [FastLoading]?

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case nbOfView
        case photoPresenterDataSources
        case packInDisplaySpaces
        case fastLoaddings
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nbOfView = try container.decode(Int.self, forKey: .nbOfView)
        photoPresenterDataSources = try container.decode([PhotoPresenterDataSource].self, forKey: .photoPresenterDataSources)
        packInDisplaySpaces = try container.decodeIfPresent([PackInDisplaySpace].self, forKey: .packInDisplaySpaces)
        fastLoaddings = try container.decodeIfPresent([FastLoading].self, forKey: .fastLoaddings)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nbOfView, forKey: .nbOfView)
        try container.encodeIfPresent(photoPresenterDataSources, forKey: .photoPresenterDataSources)
        try container.encodeIfPresent(packInDisplaySpaces, forKey: .packInDisplaySpaces)
        try container.encodeIfPresent(fastLoaddings, forKey: .fastLoaddings)
    }

    // MARK: - Hashable
    static func == (lhs: GroupedView, rhs: GroupedView) -> Bool {
        lhs.nbOfView == rhs.nbOfView &&
        lhs.photoPresenterDataSources == rhs.photoPresenterDataSources &&
        lhs.packInDisplaySpaces == rhs.packInDisplaySpaces &&
        lhs.fastLoaddings == rhs.fastLoaddings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nbOfView)
        hasher.combine(photoPresenterDataSources)
        hasher.combine(packInDisplaySpaces)
        hasher.combine(fastLoaddings)
    }

    // MARK: - Initializer
    init(nbOfView: Int,
         photoPresenterDataSources: [PhotoPresenterDataSource],
         packInDisplaySpaces: [PackInDisplaySpace]? = nil,
         fastLoaddings: [FastLoading]? = nil) {
        self.nbOfView = nbOfView
        self.photoPresenterDataSources = photoPresenterDataSources
        self.packInDisplaySpaces = packInDisplaySpaces
        self.fastLoaddings = fastLoaddings
    }
}
