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
    var anyTransition: AnyTransition {
        switch self {
        case .none:
            return .identity
        case .leftToRight:
            return .asymmetric(insertion: .move(edge: .leading),
                               removal:   .move(edge: .trailing))
        case .rightToLeft:
            return .asymmetric(insertion: .move(edge: .trailing),
                               removal:   .move(edge: .leading))
        case .topToBottom:
            return .asymmetric(insertion: .move(edge: .top),
                               removal:   .move(edge: .bottom))
        case .bottomToTop:
            return .asymmetric(insertion: .move(edge: .bottom),
                               removal:   .move(edge: .top))
        case .fade:
            return .opacity
        }
    }
}
