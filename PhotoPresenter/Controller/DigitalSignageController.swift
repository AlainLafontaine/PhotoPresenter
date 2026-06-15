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
/// Fait défiler chaque fenêtre présentateur (`photoPresenterWindows`) de la
/// droite vers la gauche, de façon fluide, synchronisée et **confinée à son
/// propre moniteur** : ce qui sort par la gauche réapparaît par la droite du
/// MÊME écran, sans jamais déborder sur les moniteurs voisins.
///
/// Implémentation : on ne déplace pas la fenêtre live (elle déborderait sur les
/// écrans adjacents — macOS ne découpe pas une fenêtre à la frontière des
/// moniteurs). On superpose, sur toute la largeur du moniteur, un calque
/// borderless (`overlay`) qui affiche un **snapshot live** de la fenêtre. Deux
/// tuiles (`tileMain` + `tileWrap`) reproduisent l'image, décalées d'une largeur
/// d'écran : la tuile qui sort par la gauche est relayée par la tuile qui entre
/// par la droite. Le calque masque (`masksToBounds`) tout ce qui dépasse, donc
/// rien ne sort de l'écran. La fenêtre originale reste à sa position et sert de
/// source au snapshot.
///
/// La vitesse vient de `intervalTimer` (`CommunityParameter`) : un cycle complet
/// = une largeur d'écran parcourue en `intervalTimer` secondes. Temps court →
/// rapide ; temps long → lent.
final class DigitalSignageController {

    static let shared = DigitalSignageController()

    /// Une fenêtre suivie + son calque de défilement.
    private final class Tracked {
        weak var window: NSWindow?
        let originX: CGFloat        // position d'origine (globale)
        let originY: CGFloat
        let size: NSSize            // taille de la fenêtre (W × H)
        let screenMinX: CGFloat     // bord gauche du moniteur (global)
        let screenWidth: CGFloat    // largeur du moniteur (S)

        var overlay: NSWindow?
        var tileMain: NSImageView?
        var tileWrap: NSImageView?

        init(window: NSWindow, screenMinX: CGFloat, screenWidth: CGFloat) {
            self.window = window
            self.originX = window.frame.origin.x
            self.originY = window.frame.origin.y
            self.size = window.frame.size
            self.screenMinX = screenMinX
            self.screenWidth = screenWidth
        }
    }

    private var tracked: [String: Tracked] = [:]
    private var timer: Timer?
    private var lastTick: CFTimeInterval = 0
    /// Progression du cycle (fraction d'une largeur d'écran), accumulée sans borne.
    private var progress: Double = 0
    private var intervalTimer: Double = 3.0
    private var frameCounter: Int = 0

    private static let frameRate: Double = 1.0 / 60.0
    /// Le snapshot (contenu) est rafraîchi tous les N frames ; la position des
    /// tuiles, elle, est mise à jour à chaque frame pour un défilement fluide.
    private static let snapshotEvery: Int = 6

    private init() {}

    var isRunning: Bool { timer != nil }

    // MARK: - Cycle de vie

    /// Active le mode : capture les fenêtres, crée les calques, démarre la boucle.
    func start(intervalTimer interval: Double) {
        self.intervalTimer = max(interval, 0.25)
        captureWindows()
        guard !tracked.isEmpty else { return }

        progress = 0
        frameCounter = 0
        lastTick = CACurrentMediaTime()

        for t in tracked.values { makeOverlay(for: t) }

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

    /// Désactive le mode : arrête la boucle, retire les calques. Les fenêtres
    /// originales n'ont jamais bougé : elles sont donc déjà à leur position
    /// d'origine, on les ramène simplement au premier plan.
    func stop() {
        timer?.invalidate()
        timer = nil
        for t in tracked.values {
            t.overlay?.orderOut(nil)
            t.overlay = nil
            t.tileMain = nil
            t.tileWrap = nil
            t.window?.orderFront(nil)
        }
        tracked.removeAll()
        progress = 0
    }

    // MARK: - Fenêtres

    private func captureWindows() {
        tracked.removeAll()
        for win in NSApp.windows {
            guard let id = win.identifier?.rawValue,
                  id.hasPrefix("photoPresenterWindows") else { continue }

            let screen = win.screen ?? NSScreen.main
            let screenFrame = screen?.frame ?? win.frame
            tracked[id] = Tracked(
                window: win,
                screenMinX: screenFrame.minX,
                screenWidth: screenFrame.width
            )
        }
    }

    // MARK: - Calque de défilement

    private func makeOverlay(for t: Tracked) {
        guard let source = t.window, t.size.width > 0, t.size.height > 0 else { return }

        let frame = NSRect(x: t.screenMinX, y: t.originY, width: t.screenWidth, height: t.size.height)
        let overlay = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        overlay.isOpaque = true
        overlay.backgroundColor = .black
        overlay.level = source.level
        overlay.ignoresMouseEvents = true
        overlay.collectionBehavior = [.transient, .ignoresCycle, .fullScreenAuxiliary]
        overlay.hasShadow = false

        let container = NSView(frame: NSRect(origin: .zero, size: frame.size))
        container.wantsLayer = true
        container.layer?.masksToBounds = true   // confine tout au moniteur

        let tileMain = NSImageView(frame: NSRect(origin: .zero, size: t.size))
        let tileWrap = NSImageView(frame: NSRect(x: t.screenWidth, y: 0, width: t.size.width, height: t.size.height))
        for tile in [tileMain, tileWrap] {
            tile.imageScaling = .scaleAxesIndependently
            tile.imageAlignment = .alignCenter
            tile.animates = false
            container.addSubview(tile)
        }
        overlay.contentView = container

        t.overlay = overlay
        t.tileMain = tileMain
        t.tileWrap = tileWrap

        refreshSnapshot(t)
        layoutTiles(t)
        overlay.order(.above, relativeTo: source.windowNumber)
    }

    // MARK: - Boucle d'animation

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = now - lastTick
        lastTick = now
        frameCounter += 1

        // Fraction d'une largeur d'écran parcourue par seconde = 1 / intervalTimer.
        progress += dt / intervalTimer

        let refresh = (frameCounter % Self.snapshotEvery == 0)
        for t in tracked.values {
            if refresh { refreshSnapshot(t) }
            layoutTiles(t)
        }
    }

    /// Positionne les deux tuiles : la principale au décalage courant, et sa
    /// copie une largeur d'écran à droite (qui prend le relais par la droite).
    private func layoutTiles(_ t: Tracked) {
        let wrapped = (progress.truncatingRemainder(dividingBy: 1.0)) * Double(t.screenWidth)
        // Position de la fenêtre dans le repère du calque (origine = bord gauche écran).
        let baseX = t.originX - t.screenMinX
        let mainX = baseX - CGFloat(wrapped)
        t.tileMain?.setFrameOrigin(NSPoint(x: mainX, y: 0))
        t.tileWrap?.setFrameOrigin(NSPoint(x: mainX + t.screenWidth, y: 0))
    }

    /// Rafraîchit l'image des tuiles à partir d'un snapshot live de la fenêtre
    /// source (via `cacheDisplay`, sans permission d'enregistrement d'écran).
    private func refreshSnapshot(_ t: Tracked) {
        guard let source = t.window?.contentView,
              source.bounds.width > 0, source.bounds.height > 0,
              let rep = source.bitmapImageRepForCachingDisplay(in: source.bounds) else { return }

        source.cacheDisplay(in: source.bounds, to: rep)
        let image = NSImage(size: source.bounds.size)
        image.addRepresentation(rep)
        t.tileMain?.image = image
        t.tileWrap?.image = image
    }
}
