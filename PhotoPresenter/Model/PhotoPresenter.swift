//
//  PhotoPresenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import Foundation
import Combine

class PhotoPresenter: ObservableObject, Codable, Hashable {
    @Published var fileHeader: FileHeader
    @Published var groupedViews: [GroupedView]

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case fileHeader
        case groupedViews
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileHeader = try container.decode(FileHeader.self, forKey: .fileHeader)
        groupedViews = try container.decode([GroupedView].self, forKey: .groupedViews)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(groupedViews, forKey: .groupedViews)
    }

    // MARK: - Hashable
    static func == (lhs: PhotoPresenter, rhs: PhotoPresenter) -> Bool {
        lhs.fileHeader == rhs.fileHeader && lhs.groupedViews == rhs.groupedViews
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileHeader)
        hasher.combine(groupedViews)
    }

    // MARK: - Initializer
    init(fileHeader: FileHeader, groupedViews: [GroupedView]) {
        self.fileHeader = fileHeader
        self.groupedViews = groupedViews
    }
}
/*
struct FileHeader: Codable, Hashable {
    let name: String
    let description: String?
    let orientation: Orientation
}
*/
