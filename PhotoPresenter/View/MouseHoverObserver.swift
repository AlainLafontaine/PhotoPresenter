//
//  MouseHoverObserver.swift
//  PhotoPresenter
//
//  Détecte l'entrée/sortie du curseur dans la zone occupée par la vue, via une
//  NSTrackingArea. Pensé pour être posé en `.background(...)` : il ne consomme
//  aucun clic (`hitTest` renvoie nil), donc le menu contextuel et les gestes de
//  la vue sous-jacente restent intacts. Utilisé pour la zone des pictogrammes
//  d'ImageView (§6).
//

import SwiftUI
import AppKit

struct MouseHoverObserver: NSViewRepresentable {
    var onHover: (Bool) -> Void

    func makeNSView(context: Context) -> HoverTrackingNSView {
        let view = HoverTrackingNSView()
        view.onHover = onHover
        return view
    }

    func updateNSView(_ nsView: HoverTrackingNSView, context: Context) {
        nsView.onHover = onHover
    }

    final class HoverTrackingNSView: NSView {
        var onHover: ((Bool) -> Void)?
        private var trackingArea: NSTrackingArea?

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if let trackingArea { removeTrackingArea(trackingArea) }
            let area = NSTrackingArea(
                rect: bounds,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self
            )
            addTrackingArea(area)
            trackingArea = area
        }

        override func mouseEntered(with event: NSEvent) { onHover?(true) }
        override func mouseExited(with event: NSEvent) { onHover?(false) }

        // Transparent aux clics : ne perturbe pas le menu contextuel / les gestes.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }
    }
}
