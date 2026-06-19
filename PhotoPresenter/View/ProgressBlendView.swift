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
        // Back-end provisoire (commit 2) : fondu enchaîné.
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
