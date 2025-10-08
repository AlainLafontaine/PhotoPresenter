//
//  WindowEventObserver.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import AppKit
import Combine

class WindowEventObserver: NSObject, NSWindowDelegate, ObservableObject {
    @Published var lastFrame: NSRect = .zero

    func windowDidMove(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            lastFrame = window.frame
        }
    }

    func windowDidResize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            lastFrame = window.frame
        }
    }
}
