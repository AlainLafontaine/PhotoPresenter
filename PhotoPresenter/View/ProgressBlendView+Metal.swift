//
//  ProgressBlendView+Metal.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//
//  Back-end Metal du chemin « progression » (Evo_007) : Glitch RGB, Damier,
//  Dissolution granuleuse, via SwiftUI .layerEffect et les fonctions de
//  Shaders/Transitions.metal.
//

import SwiftUI

extension ProgressBlendView {

    /// Rend la frame de transition (modes Metal) pour la progression donnée.
    @ViewBuilder
    func metalTransition(progress: Double) -> some View {
        switch mode {
        case .glitch:
            // Appliqué au composite fondu (une seule couche).
            crossfade(progress)
                .layerEffect(
                    ShaderLibrary.glitch(.float(Float(progress)), .float(30)),
                    maxSampleOffset: CGSize(width: 30, height: 0)
                )

        default:
            // Damier / Dissolution câblés au commit suivant : fondu provisoire.
            crossfade(progress)
        }
    }
}
