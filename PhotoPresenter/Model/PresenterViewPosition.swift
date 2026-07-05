//
//  PresenterViewPosition.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-09.
//

import Foundation
import AppKit

final class PresenterViewPosition: ObservableObject, Identifiable, Codable, Hashable {
    // MARK: - Identifiable
    var id: UUID

    // MARK: - Published properties
    @Published var pathFile: String
    @Published var screenName: String?
    @Published var windowPosition: WindowPosition
    @Published var viewSettings: [ViewSetting]

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case pathFile
        case screenName
        case windowPosition
        case viewSettings
    }

    // MARK: - Init
    init(id: UUID = UUID(), pathFile: String, screenName: String?, windowPosition: WindowPosition, viewSettings: [ViewSetting] = []) {
        self.id = id
        self.pathFile = pathFile
        self.screenName = screenName
        self.windowPosition = windowPosition
        self.viewSettings = viewSettings
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        pathFile = try container.decode(String.self, forKey: .pathFile)
        screenName = try container.decodeIfPresent(String.self, forKey: .screenName)
        windowPosition = try container.decode(WindowPosition.self, forKey: .windowPosition)
        viewSettings = try container.decodeIfPresent([ViewSetting].self, forKey: .viewSettings) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pathFile, forKey: .pathFile)
        try container.encode(screenName, forKey: .screenName)
        try container.encode(windowPosition, forKey: .windowPosition)
        try container.encode(viewSettings, forKey: .viewSettings)
    }

    // MARK: - Hashable
    static func == (lhs: PresenterViewPosition, rhs: PresenterViewPosition) -> Bool {
        lhs.id == rhs.id &&
        lhs.pathFile == rhs.pathFile &&
        lhs.screenName == rhs.screenName &&
        lhs.windowPosition == rhs.windowPosition &&
        lhs.viewSettings == rhs.viewSettings
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pathFile)
        hasher.combine(screenName)
        hasher.combine(windowPosition)
        hasher.combine(viewSettings)
    }

    // MARK: - Accès centralisé aux ViewSetting
    // `viewSettings` est un tableau plat pour tout le présentateur :
    // concaténation des réglages dans l'ordre des groupes (Evo_012).
    // Index global de la vue `view` du groupe `group` =
    // (somme des nbOfView des groupes 0..<group) + view.

    /// Nombre total de vues attendu pour ce présentateur (somme des nbOfView).
    private func expectedViewCount(for presenter: PhotoPresenter) -> Int {
        presenter.groupedViews.reduce(0) { $0 + $1.nbOfView }
    }

    /// Garde-fou : garantit un tableau `viewSettings` cohérent avec la structure
    /// du présentateur. Si la taille ne correspond pas (fichier incohérent,
    /// présentateur restructuré), on régénère des réglages par défaut.
    /// Idempotent : ne touche à rien si le tableau est déjà cohérent.
    func ensureViewSettings(for presenter: PhotoPresenter) {
        let expected = expectedViewCount(for: presenter)
        if viewSettings.count != expected {
            viewSettings = (0..<expected).map { _ in ViewSetting() }
        }
    }

    /// Accès unique au ViewSetting de la vue `view` du groupe `group`.
    func viewSetting(for presenter: PhotoPresenter, group: Int, view: Int) -> ViewSetting {
        ensureViewSettings(for: presenter)

        let offset = presenter.groupedViews[0..<group].reduce(0) { $0 + $1.nbOfView }
        return viewSettings[offset + view]
    }
}
