//
//  ImageTransition.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//

import Foundation

/// Mode de transition appliqué lors du changement d'image dans `ImageView`.
///
/// Réglage global (porté par `CommunityParameter`, persisté dans le `DisplaySpace`).
/// `none` reproduit le comportement historique : aucune animation entre deux images.
///
/// `horizontal` et `vertical` sont des axes : le sens du glissement est déterminé
/// à l'exécution par la comparaison de l'index de la nouvelle image avec celui de
/// l'ancienne (voir `anyTransition(forward:)`).
enum ImageTransition: String, Codable, CaseIterable {
    case none       = "none"
    case horizontal = "horizontal"
    case vertical   = "vertical"
    case fade       = "fade"

    /// Libellé lisible affiché dans le combobox de `CommunityParamView`.
    var label: String {
        switch self {
        case .none:       return "Aucune"
        case .horizontal: return "Horizontal"
        case .vertical:   return "Vertical"
        case .fade:       return "Fondu"
        }
    }
}
