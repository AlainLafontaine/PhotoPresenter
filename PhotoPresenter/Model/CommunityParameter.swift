//
//  CommunityParameter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-02-20.
//

import Foundation

class CommunityParameter: ObservableObject, Codable, Hashable {
    // MARK: - Published Properties

    // --- Réglages durables (persistés) ---
    @Published var intervalTimer: Double = 3.0
    @Published var fullPresenterMode: Bool = false
    @Published var digitalSignageMode: Bool = false

    // --- État runtime (NON persisté : piloté au clavier en cours de session) ---
    @Published var isCommunityModeActived: Bool = false
    @Published var isTransparent: Bool = false
    @Published var transparentFactor: Double = 1.0

    // MARK: - Initializer

    init() {}

    // MARK: - Synchronisation

    /// Recopie uniquement les réglages durables depuis `other`. Sert à synchroniser
    /// l'instance live partagée et le snapshot persisté dans le DisplaySpace, sans
    /// toucher à l'état runtime ni changer l'identité de l'objet.
    func applyPersistedValues(from other: CommunityParameter) {
        intervalTimer = other.intervalTimer
        fullPresenterMode = other.fullPresenterMode
        digitalSignageMode = other.digitalSignageMode
    }

    // MARK: - CodingKeys

    // Seuls les réglages durables figurent ici : l'état runtime est volontairement
    // exclu de la persistance.
    enum CodingKeys: String, CodingKey {
        case intervalTimer
        case fullPresenterMode
        case digitalSignageMode
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        intervalTimer = try container.decodeIfPresent(Double.self, forKey: .intervalTimer) ?? 3.0
        fullPresenterMode = try container.decodeIfPresent(Bool.self, forKey: .fullPresenterMode) ?? false
        digitalSignageMode = try container.decodeIfPresent(Bool.self, forKey: .digitalSignageMode) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(intervalTimer, forKey: .intervalTimer)
        try container.encode(fullPresenterMode, forKey: .fullPresenterMode)
        try container.encode(digitalSignageMode, forKey: .digitalSignageMode)
    }

    // MARK: - Hashable

    static func == (lhs: CommunityParameter, rhs: CommunityParameter) -> Bool {
        lhs.intervalTimer == rhs.intervalTimer &&
        lhs.fullPresenterMode == rhs.fullPresenterMode &&
        lhs.digitalSignageMode == rhs.digitalSignageMode
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(intervalTimer)
        hasher.combine(fullPresenterMode)
        hasher.combine(digitalSignageMode)
    }
}
