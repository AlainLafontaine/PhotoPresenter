//
//  PhotoPresenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import Foundation

class PhotoPresenter: ObservableObject, Codable, Hashable {
               var fileType: FileType = .PhotoPresenter
    @Published var fileHeader: PhotoPresenterHeader
    @Published var groupedViews: [GroupedView]

    enum CodingKeys: String, CodingKey {
        case fileType
        case fileHeader
        case groupedViews
    }

    init(fileHeader: PhotoPresenterHeader, groupedViews: [GroupedView]) {
        self.fileHeader = fileHeader
        self.groupedViews = groupedViews
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileType = try container.decode(FileType.self, forKey: .fileType)
        fileHeader = try container.decode(PhotoPresenterHeader.self, forKey: .fileHeader)
        groupedViews = try container.decode([GroupedView].self, forKey: .groupedViews)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileType, forKey: .fileType)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(groupedViews, forKey: .groupedViews)
    }

    static func == (lhs: PhotoPresenter, rhs: PhotoPresenter) -> Bool {
        lhs.fileType == rhs.fileType &&
        lhs.fileHeader == rhs.fileHeader &&
        lhs.groupedViews == rhs.groupedViews
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileType)
        hasher.combine(fileHeader)
        hasher.combine(groupedViews)
    }
}
