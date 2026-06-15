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
/// Wrap-around (spec 5→9) : dès qu'une fenêtre commence à sortir par la gauche,
/// un clone est créé une largeur d'écran plus à droite. Comme le clone est
/// maintenu exactement à `S` (largeur d'écran) à droite de l'original, toute
/// partie qui disparaît à gauche réapparaît à droite — sans trou. Le clone est
/// un miroir live (snapshot du contenu rafraîchi à chaque frame). Quand la
/// fenêtre revient à son origine (fin de cycle), le clone est détruit.
final class DigitalSignageController {

    static let shared = DigitalSignageController()

    /// Une fenêtre suivie : son point de départ, sa taille, l'écran, et son clone.
    private final class Tracked {
        weak var window: NSWindow?
        let originX: CGFloat
        let originY: CGFloat
        let size: NSSize
        let screenMinX: CGFloat
        let screenWidth: CGFloat
        var clone: NSWindow?

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

    /// Désactive le mode : arrête la boucle, détruit les clones et ramène chaque
    /// fenêtre à sa position d'origine.
    func stop() {
        timer?.invalidate()
        timer = nil
        for t in tracked.values {
            t.clone?.orderOut(nil)
            t.clone = nil
            t.window?.setFrameOrigin(NSPoint(x: t.originX, y: t.originY))
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

    // MARK: - Boucle d'animation

    private func tick() {
        let now = CACurrentMediaTime()
        let dt = now - lastTick
        lastTick = now

        // Fraction d'une largeur d'écran parcourue par seconde = 1 / intervalTimer.
        progress += dt / intervalTimer

        for t in tracked.values {
            guard let window = t.window else { continue }

            // Position de la fenêtre, wrappée sur une largeur d'écran.
            let wrapped = (progress.truncatingRemainder(dividingBy: 1.0)) * Double(t.screenWidth)
            let xMain = t.originX - CGFloat(wrapped)
            window.setFrameOrigin(NSPoint(x: xMain, y: t.originY))

            // Le bord gauche est sorti de l'écran → une partie a wrappé : on a
            // besoin du clone, maintenu exactement une largeur d'écran à droite.
            if xMain < t.screenMinX {
                if t.clone == nil { t.clone = makeClone(for: t) }
                refreshCloneImage(t)
                t.clone?.setFrameOrigin(NSPoint(x: xMain + t.screenWidth, y: t.originY))
            } else if let clone = t.clone {
                // La fenêtre est revenue à l'origine : on remplace le clone par
                // l'original (déjà en place) et on détruit le clone.
                clone.orderOut(nil)
                t.clone = nil
            }
        }
    }

    // MARK: - Clones miroir

    private func makeClone(for t: Tracked) -> NSWindow? {
        guard let source = t.window else { return nil }

        let frame = NSRect(
            x: t.originX + t.screenWidth,
            y: t.originY,
            width: t.size.width,
            height: t.size.height
        )
        let clone = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        clone.isOpaque = false
        clone.backgroundColor = .clear
        clone.level = source.level
        clone.alphaValue = source.alphaValue
        clone.ignoresMouseEvents = true
        clone.collectionBehavior = [.transient, .ignoresCycle, .fullScreenAuxiliary]
        clone.hasShadow = source.hasShadow

        let imageView = NSImageView(frame: NSRect(origin: .zero, size: frame.size))
        imageView.imageScaling = .scaleAxesIndependently
        imageView.imageAlignment = .alignCenter
        clone.contentView = imageView

        refreshCloneImage(t, into: clone)
        clone.orderFront(nil)
        return clone
    }

    /// Met à jour le contenu du clone à partir d'un snapshot de la fenêtre source
    /// (miroir live, sans permission d'enregistrement d'écran).
    private func refreshCloneImage(_ t: Tracked, into clone: NSWindow? = nil) {
        guard let target = clone ?? t.clone,
              let imageView = target.contentView as? NSImageView,
              let source = t.window?.contentView,
              source.bounds.width > 0, source.bounds.height > 0,
              let rep = source.bitmapImageRepForCachingDisplay(in: source.bounds) else { return }

        source.cacheDisplay(in: source.bounds, to: rep)
        let image = NSImage(size: source.bounds.size)
        image.addRepresentation(rep)
        imageView.image = image
        target.alphaValue = t.window?.alphaValue ?? 1.0
    }
}
