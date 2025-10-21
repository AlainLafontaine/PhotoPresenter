//
//  DisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation

class DisplaySpace: ObservableObject, Codable, Hashable {
    @Published var fileHeader: FileHeader
    @Published var displaySpaceHeader: DisplaySpaceHeader
    @Published var viewPositions: [PresenterViewPosition]
    @Published var presenters: [PhotoPresenter]?

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case fileHeader
        case displaySpaceHeader
        case viewPositions
        case presenters
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileHeader = try container.decode(FileHeader.self, forKey: .fileHeader)
        displaySpaceHeader = try container.decode(DisplaySpaceHeader.self, forKey: .displaySpaceHeader)
        viewPositions = try container.decode([PresenterViewPosition].self, forKey: .viewPositions)
        presenters = try container.decodeIfPresent([PhotoPresenter].self, forKey: .presenters)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(displaySpaceHeader, forKey: .displaySpaceHeader)
        try container.encode(viewPositions, forKey: .viewPositions)
        try container.encodeIfPresent(presenters, forKey: .presenters)
    }

    // MARK: - Hashable
    static func == (lhs: DisplaySpace, rhs: DisplaySpace) -> Bool {
        lhs.fileHeader == rhs.fileHeader &&
        lhs.displaySpaceHeader == rhs.displaySpaceHeader &&
        lhs.viewPositions == rhs.viewPositions &&
        lhs.presenters == rhs.presenters
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileHeader)
        hasher.combine(displaySpaceHeader)
        hasher.combine(viewPositions)
        hasher.combine(presenters)
    }

    // MARK: - Initializer
    init(fileHeader: FileHeader,
         displaySpaceHeader: DisplaySpaceHeader,
         viewPositions: [PresenterViewPosition],
         presenters: [PhotoPresenter]? = nil) {
        self.fileHeader = fileHeader
        self.displaySpaceHeader = displaySpaceHeader
        self.viewPositions = viewPositions
        self.presenters = presenters
    }
}
