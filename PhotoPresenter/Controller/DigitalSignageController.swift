//
//  DigitalSignageController.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-15.
//

import AppKit
import QuartzCore

/// Contrôleur global du mode Digital Signage.
///
/// Déplace les fenêtres présentateurs (`photoPresenterWindows`) de la droite
/// vers la gauche, de façon fluide et synchronisée. La fenêtre elle-même est
/// déplacée (son `frame`), pas le contenu de la vue.
///
/// La vitesse est calculée à partir de `intervalTimer` (`CommunityParameter`) :
/// un cycle complet = la largeur de l'écran parcourue en `intervalTimer` secondes.
/// Temps court → vitesse élevée ; temps long → vitesse lente.
///
/// Commit 2 : déplacement + boucle d'animation (sans clone, le wrap se fait par
/// un simple modulo, ce qui provoque un saut visuel — corrigé au commit 3 par
/// les clones miroir).
final class DigitalSignageController {

    static let shared = DigitalSignageController()

    /// Une fenêtre suivie + son point de départ (position d'origine).
    private struct Tracked {
        weak var window: NSWindow?
        let originX: CGFloat
        let originY: CGFloat
        let screenWidth: CGFloat
    }

    private var tracked: [String: Tracked] = [:]
    private var timer: Timer?
    private var lastTick: CFTimeInterval = 0
    /// Progression du cycle, fraction dans [0, 1) d'une largeur d'écran parcourue.
    private var progress: Double = 0
    private var intervalTimer: Double = 3.0

    private static let frameRate: Double = 1.0 / 60.0

    private init() {}

    var isRunning: Bool { timer != nil }

    // MARK: - Cycle de vie

    /// Active le mode : capture les fenêtres + leur origine, puis démarre la boucle.
    func start(intervalTimer interval: Double) {
        self.intervalTimer = max(interval, 0.25)
        captureWindows()
        guard !tracked.isEmpty else { return }

        progress = 0
        lastTick = CACurrentMediaTime()

        timer?.invalidate()
        let t = Timer(timeInterval: Self.frameRate, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    /// Met à jour la vitesse sans repartir de zéro (changement d'`intervalTimer`).
    func updateInterval(_ interval: Double) {
        intervalTimer = max(interval, 0.25)
    }

    /// Désactive le mode : arrête la boucle et ramène chaque fenêtre à son origine.
    func stop() {
        timer?.invalidate()
        timer = nil
        restoreOrigins()
        tracked.removeAll()
        progress = 0
    }

    // MARK: - Fenêtres

    private func captureWindows() {
        tracked.removeAll()
        for win in NSApp.windows {
            guard let id = win.identifier?.rawValue,
                  id.hasPrefix("photoPresenterWindows") else { continue }

            let screenWidth = (win.screen ?? NSScreen.main)?.frame.width ?? win.frame.width
            tracked[id] = Tracked(
                window: win,
                originX: win.frame.origin.x,
                originY: win.frame.origin.y,
                screenWidth: screenWidth
            )
        }
    }

    private func restoreOrigins() {
        for (_, t) in tracked {
            t.window?.setFrameOrigin(NSPoint(x: t.originX, y: t.originY))
        }
    }

    // MARK: - Boucle d'animation

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = now - lastTick
        lastTick = now

        // Fraction d'une largeur d'écran à parcourir par seconde = 1 / intervalTimer.
        progress += dt / intervalTimer
        // On garde la progression dans [0, 1) — modulo simple en attendant les clones.
        if progress >= 1.0 { progress -= floor(progress) }

        for (_, t) in tracked {
            guard let window = t.window else { continue }
            let deltaX = CGFloat(progress) * t.screenWidth
            window.setFrameOrigin(NSPoint(x: t.originX - deltaX, y: t.originY))
        }
    }
}
