//
//  DataPresenterHelp.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-26.
//

import Foundation

class DataPresenterHelp: ObservableObject, Identifiable, Codable, Hashable {
    let mainViewId = UUID()
    let filename: String
    let windowPos: WindowPosition?

    @Published var displayView: PhotoPresenterViewType
    @Published var presenter: PhotoPresenter

    enum CodingKeys: String, CodingKey {
        case mainViewId
        case filename
        case windowPos
        case displayView
        case presenter
    }

    init(
        filename: String,
        presenter: PhotoPresenter,
        windowPos: WindowPosition? = nil,
        displayView: PhotoPresenterViewType = .multiImageView
    ) {
        self.filename = filename
        self.windowPos = windowPos
        self.displayView = displayView
        self.presenter = presenter
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // mainViewId is regenerated, not decoded
        filename = try container.decode(String.self, forKey: .filename)
        windowPos = try container.decodeIfPresent(WindowPosition.self, forKey: .windowPos)
        displayView = try container.decode(PhotoPresenterViewType.self, forKey: .displayView)
        presenter = try container.decode(PhotoPresenter.self, forKey: .presenter)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filename, forKey: .filename)
        try container.encodeIfPresent(windowPos, forKey: .windowPos)
        try container.encode(displayView, forKey: .displayView)
        try container.encode(presenter, forKey: .presenter)
    }

    static func == (lhs: DataPresenterHelp, rhs: DataPresenterHelp) -> Bool {
        lhs.filename == rhs.filename &&
        lhs.windowPos == rhs.windowPos &&
        lhs.displayView == rhs.displayView &&
        lhs.presenter == rhs.presenter
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
        hasher.combine(windowPos)
        hasher.combine(displayView)
        hasher.combine(presenter)
    }
}
