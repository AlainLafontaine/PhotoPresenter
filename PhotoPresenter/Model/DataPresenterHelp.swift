//
//  DataPresenterHelp.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-26.
//

import Foundation

typealias DataPresenterMap = [String: DataPresenterHelp]

class DataPresenterHelp: ObservableObject, Identifiable, Codable, Hashable {

    @Published var displayView: PhotoPresenterViewType
    @Published var presenter: PhotoPresenter

    let filename: String
    let name: String
    var displaySpaceId: UUID
    var windowPos: WindowPosition?
    var windowId: String?
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case windowId, filename, name, windowPos, displayView, presenter, displaySpaceId
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        windowId = try container.decodeIfPresent(String.self, forKey: .windowId)
        filename = try container.decode(String.self, forKey: .filename)
        name = try container.decode(String.self, forKey: .name)
        windowPos = try container.decodeIfPresent(WindowPosition.self, forKey: .windowPos)
        displayView = try container.decode(PhotoPresenterViewType.self, forKey: .displayView)
        presenter = try container.decode(PhotoPresenter.self, forKey: .presenter)
        displaySpaceId = try container.decodeIfPresent(UUID.self, forKey: .displaySpaceId) ?? UUID()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(windowId, forKey: .windowId)
        try container.encode(filename, forKey: .filename)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(windowPos, forKey: .windowPos)
        try container.encode(displayView, forKey: .displayView)
        try container.encode(presenter, forKey: .presenter)
        try container.encode(displaySpaceId, forKey: .displaySpaceId)
    }

    // MARK: - Hashable
    static func == (lhs: DataPresenterHelp, rhs: DataPresenterHelp) -> Bool {
        return lhs.windowId == rhs.windowId &&
               lhs.filename == rhs.filename &&
               lhs.name == rhs.name &&
               lhs.windowPos == rhs.windowPos &&
               lhs.displayView == rhs.displayView &&
               lhs.presenter == rhs.presenter &&
               lhs.displaySpaceId == rhs.displaySpaceId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(windowId)
        hasher.combine(filename)
        hasher.combine(name)
        hasher.combine(windowPos)
        hasher.combine(displayView)
        hasher.combine(presenter)
        hasher.combine(displaySpaceId)
    }

    // MARK: - Initializer
    init(
        windowId: String? = nil,
        filename: String,
        name: String,
        windowPos: WindowPosition? = nil,
        displayView: PhotoPresenterViewType = .multiImageView,
        presenter: PhotoPresenter,
        displaySpaceId: UUID
    )
    {
        self.windowId = windowId
        self.filename = filename
        self.name = name
        self.windowPos = windowPos
        self.displayView = displayView
        self.presenter = presenter
        self.displaySpaceId = displaySpaceId
    }
}
