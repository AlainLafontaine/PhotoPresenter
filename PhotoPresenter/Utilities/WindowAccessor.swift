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
