//
//  WindowAccessor.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-11-27.
//
// Helper pour accéder à la NSWindow

import SwiftUI
import AppKit   // 👈 nécessaire pour NSView et NSWindow

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                callback(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// Applique et maintient le niveau d'une NSWindow (floating / normal) de façon réactive.
/// updateNSView est rappelé à chaque re-render SwiftUI, donc à chaque changement de la valeur isOnTop.
struct WindowLevelController: NSViewRepresentable {
    var isOnTop: Bool

    func makeNSView(context: Context) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            window.level = isOnTop ? .floating : .normal
        }
    }
}
