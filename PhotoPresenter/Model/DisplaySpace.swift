//
//  DisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation

class DisplaySpace: ObservableObject, Codable, Hashable {
               var fileType: FileType = .DisplaySpace
    @Published var fileHeader: DisplaySpaceHeader
    @Published var viewPositions: [PresenterViewPosition]
    @Published var presenters: [PhotoPresenter]?

    enum CodingKeys: String, CodingKey {
        case fileType
        case fileHeader
        case viewPositions
        case presenters
    }

    init(fileHeader: DisplaySpaceHeader, viewPositions: [PresenterViewPosition], presenters: [PhotoPresenter]? = nil) {
        self.fileHeader = fileHeader
        self.viewPositions = viewPositions
        self.presenters = presenters
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileType = try container.decode(FileType.self, forKey: .fileType)
        fileHeader = try container.decode(DisplaySpaceHeader.self, forKey: .fileHeader)
        viewPositions = try container.decode([PresenterViewPosition].self, forKey: .viewPositions)
        presenters = try container.decodeIfPresent([PhotoPresenter].self, forKey: .presenters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileType, forKey: .fileType)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(viewPositions, forKey: .viewPositions)
        try container.encodeIfPresent(presenters, forKey: .presenters)
    }

    static func == (lhs: DisplaySpace, rhs: DisplaySpace) -> Bool {
        lhs.fileType == rhs.fileType &&
        lhs.fileHeader == rhs.fileHeader &&
        lhs.viewPositions == rhs.viewPositions &&
        lhs.presenters == rhs.presenters
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileType)
        hasher.combine(fileHeader)
        hasher.combine(viewPositions)
        hasher.combine(presenters)
    }
}
