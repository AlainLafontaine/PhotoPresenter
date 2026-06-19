//
//  ProgressBlendView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//
//  Chemin de rendu « progression » des transitions premium (Evo_006). Mélange
//  l'ancienne et la nouvelle image selon une progression 0→1 animée par une
//  horloge (TimelineView). Les back-ends Core Image (Ondulation, Tourne-page) et
//  Metal (Pixellisation) sont câblés aux commits suivants ; ce commit fournit un
//  back-end provisoire en fondu enchaîné.
//

import SwiftUI

struct ProgressBlendView: View {

    let oldImage: NSImage
    let newImage: NSImage
    let mode: ImageTransition
    let duration: Double
    let fill: Bool          // mode expansion (resizable) vs ajusté (scaledToFit)

    @State private var startDate = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)
            let progress = min(max(elapsed / max(duration, 0.0001), 0), 1)
            content(progress: progress)
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func content(progress: Double) -> some View {
        switch mode {
        case .ripple, .pageCurl:
            // Back-end Core Image (mélange réel des deux images selon progress).
            if let rendered = coreImageTransition(progress: progress) {
                image(rendered)
            } else {
                crossfade(progress)
            }
        default:
            // Autres modes premium (Pixellisation au commit 4) : fondu provisoire.
            crossfade(progress)
        }
    }

    /// Fondu enchaîné de repli.
    @ViewBuilder
    private func crossfade(_ progress: Double) -> some View {
        ZStack {
            image(oldImage).opacity(1 - progress)
            image(newImage).opacity(progress)
        }
    }

    @ViewBuilder
    private func image(_ ns: NSImage) -> some View {
        if fill {
            Image(nsImage: ns).resizable()
        } else {
            Image(nsImage: ns).resizable().scaledToFit()
        }
    }
}
