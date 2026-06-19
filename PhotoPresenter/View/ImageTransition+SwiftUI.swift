//
//  ImageTransition+SwiftUI.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//

import SwiftUI

extension ImageTransition {
    /// Transition SwiftUI correspondante, appliquée au remplacement d'image dans
    /// `ImageView`. Les glissements sont asymétriques (la nouvelle image entre par
    /// un bord, l'ancienne sort par le bord opposé) ; le fondu est un simple
    /// `.opacity`. `none` n'anime rien.
    ///
    /// - Parameter forward: `true` si l'index de la nouvelle image est supérieur à
    ///   celui de l'ancienne. Détermine le sens du glissement :
    ///   - Horizontal, forward : nouvelle par la droite, ancienne vers la gauche.
    ///   - Horizontal, !forward : nouvelle par la gauche, ancienne vers la droite.
    ///   - Vertical, forward : nouvelle par le bas, ancienne vers le haut.
    ///   - Vertical, !forward : nouvelle par le haut, ancienne vers le bas.
    func anyTransition(forward: Bool) -> AnyTransition {
        switch self {
        case .none:
            return .identity
        case .fade:
            return .opacity
        case .horizontal:
            return forward
                ? .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                : .asymmetric(insertion: .move(edge: .leading),  removal: .move(edge: .trailing))
        case .vertical:
            return forward
                ? .asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))
                : .asymmetric(insertion: .move(edge: .top),    removal: .move(edge: .bottom))

        // Glissement + fondu : glissement adouci par une opacité.
        case .slideFade:
            return forward
                ? .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                              removal:   .move(edge: .leading).combined(with: .opacity))
                : .asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                              removal:   .move(edge: .trailing).combined(with: .opacity))

        // Recouvrement : la nouvelle image glisse PAR-DESSUS l'ancienne immobile.
        // (z-index géré dans ImageView : la nouvelle passe au-dessus.)
        case .cover:
            return forward
                ? .asymmetric(insertion: .move(edge: .trailing), removal: .identity)
                : .asymmetric(insertion: .move(edge: .leading),  removal: .identity)

        // Dévoilement : l'ancienne glisse et DÉVOILE la nouvelle immobile dessous.
        // (z-index géré dans ImageView : l'ancienne reste au-dessus.)
        case .reveal:
            return forward
                ? .asymmetric(insertion: .identity, removal: .move(edge: .leading))
                : .asymmetric(insertion: .identity, removal: .move(edge: .trailing))

        // Evo_005 — câblés dans les commits suivants. En attendant : aucun effet.
        case .zoom,
             .flip, .cube, .blinds, .wipe, .iris, .shape:
            return .identity

        // Transitions à deux phases : gérées hors AnyTransition (chemin overlay).
        case .dipToBlack, .dipToWhite:
            return .identity
        }
    }
}
