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

    // Référence runtime au PresenterViewPosition vivant du DisplaySpace courant
    // (porte les ViewSetting — Evo_012). Résolue par l'App à la construction de
    // la fenêtre ; exclue du Codable car openWindow(value:) sérialise le payload
    // et la copie décodée doit être rebranchée sur l'instance vivante.
    var viewPosition: PresenterViewPosition?

    
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
        self.windowPos = windowPos ?? WindowPosition(x: 0, y: 0, width: 400, height: 400)
        self.displayView = displayView
        self.presenter = presenter
        self.displaySpaceId = displaySpaceId
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case displayView, presenter, filename, name, displaySpaceId, windowPos, windowId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displayView = try container.decode(PhotoPresenterViewType.self, forKey: .displayView)
        presenter = try container.decode(PhotoPresenter.self, forKey: .presenter)
        filename = try container.decode(String.self, forKey: .filename)
        name = try container.decode(String.self, forKey: .name)
        displaySpaceId = try container.decode(UUID.self, forKey: .displaySpaceId)
        windowPos = try container.decodeIfPresent(WindowPosition.self, forKey: .windowPos)
        windowId = try container.decodeIfPresent(String.self, forKey: .windowId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayView, forKey: .displayView)
        try container.encode(presenter, forKey: .presenter)
        try container.encode(filename, forKey: .filename)
        try container.encode(name, forKey: .name)
        try container.encode(displaySpaceId, forKey: .displaySpaceId)
        try container.encode(windowPos, forKey: .windowPos)
        try container.encode(windowId, forKey: .windowId)
    }

    // MARK: - Hashable
    static func == (lhs: DataPresenterHelp, rhs: DataPresenterHelp) -> Bool {
        lhs.displayView == rhs.displayView &&
        lhs.presenter == rhs.presenter &&
        lhs.filename == rhs.filename &&
        lhs.name == rhs.name &&
        lhs.displaySpaceId == rhs.displaySpaceId &&
        lhs.windowPos == rhs.windowPos &&
        lhs.windowId == rhs.windowId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(displayView)
        hasher.combine(presenter)
        hasher.combine(filename)
        hasher.combine(name)
        hasher.combine(displaySpaceId)
        hasher.combine(windowPos)
        hasher.combine(windowId)
    }
}
