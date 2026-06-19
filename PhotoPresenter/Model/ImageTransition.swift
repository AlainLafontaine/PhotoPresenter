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
/// Calqué sur `TransparencyGradientDirection` (même structure `String, Codable,
/// CaseIterable` + `label` français), avec en plus le cas `fade`.
enum ImageTransition: String, Codable, CaseIterable {
    case none        = "none"
    case leftToRight = "leftToRight"
    case rightToLeft = "rightToLeft"
    case topToBottom = "topToBottom"
    case bottomToTop = "bottomToTop"
    case fade        = "fade"

    /// Libellé lisible affiché dans le combobox de `CommunityParamView`.
    var label: String {
        switch self {
        case .none:        return "Aucune"
        case .leftToRight: return "Gauche vers droite"
        case .rightToLeft: return "Droite vers gauche"
        case .topToBottom: return "Haut vers bas"
        case .bottomToTop: return "Bas vers haut"
        case .fade:        return "Fondu"
        }
    }
}
