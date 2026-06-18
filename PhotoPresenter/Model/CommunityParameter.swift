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

    // Durée d'un tour complet de moniteur en Digital Signage (secondes) : 30…600, pas 5.
    @Published var loopDuration: Double = 60.0
    // Nombre de tours avant de passer à l'image suivante en Digital Signage : 1…10.
    @Published var loopsPerImage: Int = 1

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
        loopDuration = other.loopDuration
        loopsPerImage = other.loopsPerImage
    }

    // MARK: - CodingKeys

    // Seuls les réglages durables figurent ici : l'état runtime est volontairement
    // exclu de la persistance.
    enum CodingKeys: String, CodingKey {
        case intervalTimer
        case fullPresenterMode
        case digitalSignageMode
        case loopDuration
        case loopsPerImage
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        intervalTimer = try container.decodeIfPresent(Double.self, forKey: .intervalTimer) ?? 3.0
        fullPresenterMode = try container.decodeIfPresent(Bool.self, forKey: .fullPresenterMode) ?? false
        digitalSignageMode = try container.decodeIfPresent(Bool.self, forKey: .digitalSignageMode) ?? false
        loopDuration = try container.decodeIfPresent(Double.self, forKey: .loopDuration) ?? 60.0
        loopsPerImage = try container.decodeIfPresent(Int.self, forKey: .loopsPerImage) ?? 1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(intervalTimer, forKey: .intervalTimer)
        try container.encode(fullPresenterMode, forKey: .fullPresenterMode)
        try container.encode(digitalSignageMode, forKey: .digitalSignageMode)
        try container.encode(loopDuration, forKey: .loopDuration)
        try container.encode(loopsPerImage, forKey: .loopsPerImage)
    }

    // MARK: - Hashable

    static func == (lhs: CommunityParameter, rhs: CommunityParameter) -> Bool {
        lhs.intervalTimer == rhs.intervalTimer &&
        lhs.fullPresenterMode == rhs.fullPresenterMode &&
        lhs.digitalSignageMode == rhs.digitalSignageMode &&
        lhs.loopDuration == rhs.loopDuration &&
        lhs.loopsPerImage == rhs.loopsPerImage
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(intervalTimer)
        hasher.combine(fullPresenterMode)
        hasher.combine(digitalSignageMode)
        hasher.combine(loopDuration)
        hasher.combine(loopsPerImage)
    }
}
