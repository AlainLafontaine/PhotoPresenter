//
//  DisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation

class DisplaySpace: ObservableObject, Codable, Hashable {
    // MARK: - Published Properties

    @Published var fileHeader: FileHeader
    @Published var displaySpaceHeader: DisplaySpaceHeader
    @Published var windowPosition: WindowPosition?
    @Published var viewPositions: [PresenterViewPosition]
    @Published var presenters: [PhotoPresenter]?
    @Published var emergencyDisplaySpace: EmergencyDisplaySpace?

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case fileHeader
        case displaySpaceHeader
        case windowPosition
        case viewPositions
        case presenters
        case emergencyDisplaySpace
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileHeader = try container.decode(FileHeader.self, forKey: .fileHeader)
        displaySpaceHeader = try container.decode(DisplaySpaceHeader.self, forKey: .displaySpaceHeader)
        windowPosition = try container.decodeIfPresent(WindowPosition.self, forKey: .windowPosition)
        viewPositions = try container.decode([PresenterViewPosition].self, forKey: .viewPositions)
        presenters = try container.decodeIfPresent([PhotoPresenter].self, forKey: .presenters)
        emergencyDisplaySpace = try container.decodeIfPresent(EmergencyDisplaySpace.self, forKey: .emergencyDisplaySpace)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileHeader, forKey: .fileHeader)
        try container.encode(displaySpaceHeader, forKey: .displaySpaceHeader)
        try container.encodeIfPresent(windowPosition, forKey: .windowPosition)
        try container.encode(viewPositions, forKey: .viewPositions)
        try container.encodeIfPresent(presenters, forKey: .presenters)
        try container.encodeIfPresent(emergencyDisplaySpace, forKey: .emergencyDisplaySpace)
    }

    // MARK: - Hashable

    static func == (lhs: DisplaySpace, rhs: DisplaySpace) -> Bool {
        lhs.fileHeader == rhs.fileHeader &&
        lhs.displaySpaceHeader == rhs.displaySpaceHeader &&
        lhs.windowPosition == rhs.windowPosition &&
        lhs.viewPositions == rhs.viewPositions &&
        lhs.presenters == rhs.presenters &&
        lhs.emergencyDisplaySpace == rhs.emergencyDisplaySpace
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileHeader)
        hasher.combine(displaySpaceHeader)
        hasher.combine(windowPosition)
        hasher.combine(viewPositions)
        hasher.combine(presenters)
        hasher.combine(emergencyDisplaySpace)
    }

    // MARK: - Initializer

    init(
        fileHeader: FileHeader,
        displaySpaceHeader: DisplaySpaceHeader,
        windowPosition: WindowPosition? = nil,
        viewPositions: [PresenterViewPosition],
        presenters: [PhotoPresenter]? = nil,
        emergencyDisplaySpace: EmergencyDisplaySpace? = nil
    ) {
        self.fileHeader = fileHeader
        self.displaySpaceHeader = displaySpaceHeader
        self.windowPosition = windowPosition
        self.viewPositions = viewPositions
        self.presenters = presenters
        self.emergencyDisplaySpace = emergencyDisplaySpace
    }
}
