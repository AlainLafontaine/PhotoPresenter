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
    @Published var windowPositions: [DSPresenter]
    @Published var presenters: [PhotoPresenter]?

    enum CodingKeys: String, CodingKey {
        case fileType
        case fileHeader
        case windowPositions
        case presenters
    }

    init(fileHeader: DisplaySpaceHeader, windowPositions: [DSPresenter], presenters: [PhotoPresenter]? = nil) {
        self.fileHeader = fileHeader
        self.windowPositions = windowPositions
        self.presenters = presenters
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileType = try container.decode(FileType.self, forKey: .fileType)
        fileHeader = try container.decode(DisplaySpaceHeader.self, forKey: .fileHeader)
        windowPositions = try container.decode([DSPresenter].self, forKey: .windowPositions)
        presenters = try container.decodeIfPresent([PhotoPresenter].self, forKey: .presenters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileType, forKey: .fileType)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(windowPositions, forKey: .windowPositions)
        try container.encodeIfPresent(presenters, forKey: .presenters)
    }

    static func == (lhs: DisplaySpace, rhs: DisplaySpace) -> Bool {
        lhs.fileType == rhs.fileType &&
        lhs.fileHeader == rhs.fileHeader &&
        lhs.windowPositions == rhs.windowPositions &&
        lhs.presenters == rhs.presenters
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileType)
        hasher.combine(fileHeader)
        hasher.combine(windowPositions)
        hasher.combine(presenters)
    }
}
