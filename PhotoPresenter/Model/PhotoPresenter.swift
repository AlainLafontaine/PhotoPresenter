//
//  PhotoPresenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import Foundation

class PhotoPresenter: ObservableObject, Codable, Hashable {
    @Published var fileHeader: FileHeader
    @Published var photoPresenterHeader: PhotoPresenterHeader
    @Published var groupedViews: [GroupedView]

    // MARK: - Initialiseur
    init(fileHeader: FileHeader,
         photoPresenterHeader: PhotoPresenterHeader,
         groupedViews: [GroupedView]
    ) {
        self.fileHeader = fileHeader
        self.photoPresenterHeader = photoPresenterHeader
        self.groupedViews = groupedViews
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case fileHeader
        case photoPresenterHeader
        case groupedViews
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileHeader = try container.decode(FileHeader.self, forKey: .fileHeader)
        photoPresenterHeader = try container.decode(PhotoPresenterHeader.self, forKey: .photoPresenterHeader)
        groupedViews = try container.decode([GroupedView].self, forKey: .groupedViews)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(photoPresenterHeader, forKey: .photoPresenterHeader)
        try container.encode(groupedViews, forKey: .groupedViews)
    }

    // MARK: - Hashable
    static func == (lhs: PhotoPresenter, rhs: PhotoPresenter) -> Bool {
        lhs.fileHeader == rhs.fileHeader &&
        lhs.photoPresenterHeader == rhs.photoPresenterHeader &&
        lhs.groupedViews == rhs.groupedViews
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileHeader)
        hasher.combine(photoPresenterHeader)
        hasher.combine(groupedViews)
    }
}
