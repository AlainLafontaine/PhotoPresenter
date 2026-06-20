//
//  FeatureFlags.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//

import Foundation

/// Drapeaux d'activation de fonctionnalités en cours de stabilisation.
enum FeatureFlags {

    /// Transitions « premium » (Evo_006 : Ondulation, Tourne-page, Pixellisation),
    /// rendues par le chemin progression (Core Image / Metal). Masquées tant que les
    /// performances (N fenêtres, Digital Signage) ne sont pas validées.
    /// Passer à `true` pour exposer la section « Premium » dans `CommunityParamView`.
    static let premiumTransitions = true
}
