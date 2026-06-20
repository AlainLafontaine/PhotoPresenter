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

        case .checkerboard:
            // Deux textures : couche = nouvelle image, ancienne passée en argument.
            GeometryReader { geo in
                image(newImage)
                    .layerEffect(
                        ShaderLibrary.checkerboard(
                            .float2(geo.size),
                            .float(Float(progress)),
                            .float(40),
                            .image(Image(nsImage: oldImage))
                        ),
                        maxSampleOffset: .zero
                    )
            }

        case .dissolve:
            GeometryReader { geo in
                image(newImage)
                    .layerEffect(
                        ShaderLibrary.dissolve(
                            .float2(geo.size),
                            .float(Float(progress)),
                            .image(Image(nsImage: oldImage))
                        ),
                        maxSampleOffset: .zero
                    )
            }

        default:
            crossfade(progress)
        }
    }
}
