//
//  ImageTransitionModifiers.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//
//  ViewModifiers et transitions custom (Evo_005) construites avec
//  AnyTransition.modifier(active:identity:). Regroupe les effets 3D (Retournement,
//  Cube). Les effets à masque (Volets, Balayage, Iris, Forme) viennent au commit 6.
//

import SwiftUI

/// Rotation 3D animatable (l'angle est interpolé pendant la transition).
/// `axis`, `anchor` et `perspective` sont constants entre les états active/identity.
struct Rotation3DTransitionModifier: ViewModifier, Animatable {
    var angleDegrees: Double
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    var anchor: UnitPoint
    var perspective: CGFloat

    var animatableData: Double {
        get { angleDegrees }
        set { angleDegrees = newValue }
    }

    func body(content: Content) -> some View {
        content.rotation3DEffect(
            .degrees(angleDegrees),
            axis: axis,
            anchor: anchor,
            perspective: perspective
        )
    }
}

extension AnyTransition {

    /// Retournement type carte autour de l'axe Y (pivot central). L'ancienne pivote
    /// jusqu'à la tranche, la nouvelle arrive depuis la tranche opposée.
    static func flip(forward: Bool) -> AnyTransition {
        let axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)
        let outAngle: Double = forward ? 90 : -90
        let inAngle: Double  = forward ? -90 : 90
        return .asymmetric(
            insertion: .modifier(
                active:   Rotation3DTransitionModifier(angleDegrees: inAngle, axis: axis, anchor: .center, perspective: 0.3),
                identity: Rotation3DTransitionModifier(angleDegrees: 0,       axis: axis, anchor: .center, perspective: 0.3)
            ),
            removal: .modifier(
                active:   Rotation3DTransitionModifier(angleDegrees: outAngle, axis: axis, anchor: .center, perspective: 0.3),
                identity: Rotation3DTransitionModifier(angleDegrees: 0,        axis: axis, anchor: .center, perspective: 0.3)
            )
        )
    }

    /// Rotation type cube autour de l'axe Y, charnières sur les bords : l'ancienne
    /// pivote vers l'intérieur sur un bord, la nouvelle entre sur le bord opposé.
    static func cube(forward: Bool) -> AnyTransition {
        let axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)
        let outAngle: Double = forward ? -90 : 90
        let inAngle: Double  = forward ? 90 : -90
        let outAnchor: UnitPoint = forward ? .trailing : .leading
        let inAnchor: UnitPoint  = forward ? .leading : .trailing
        return .asymmetric(
            insertion: .modifier(
                active:   Rotation3DTransitionModifier(angleDegrees: inAngle, axis: axis, anchor: inAnchor, perspective: 0.5),
                identity: Rotation3DTransitionModifier(angleDegrees: 0,       axis: axis, anchor: inAnchor, perspective: 0.5)
            ),
            removal: .modifier(
                active:   Rotation3DTransitionModifier(angleDegrees: outAngle, axis: axis, anchor: outAnchor, perspective: 0.5),
                identity: Rotation3DTransitionModifier(angleDegrees: 0,        axis: axis, anchor: outAnchor, perspective: 0.5)
            )
        )
    }
}

/// Révélation par masque animatable (`progress` 0 → 1). La forme du masque dépend
/// du `style`. Sert aux transitions Volets, Balayage, Iris et Forme : la nouvelle
/// image est dévoilée par-dessus l'ancienne immobile (z-index géré dans ImageView).
struct MaskRevealModifier: ViewModifier, Animatable {

    enum Style {
        case wipe(forward: Bool)    // balayage : front dur qui traverse
        case blinds(forward: Bool)  // volets : bandes verticales qui s'ouvrent
        case iris                   // cercle depuis le centre
        case cornerCircle           // cercle depuis un coin (Forme)
    }

    var progress: Double
    var style: Style

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.mask {
            GeometryReader { geo in
                maskView(size: geo.size)
            }
        }
    }

    @ViewBuilder
    private func maskView(size: CGSize) -> some View {
        let p = max(0, min(1, progress))
        let diagonal = (size.width * size.width + size.height * size.height).squareRoot()

        switch style {
        case .wipe(let forward):
            HStack(spacing: 0) {
                if !forward { Spacer(minLength: 0) }
                Rectangle().frame(width: size.width * p)
                if forward { Spacer(minLength: 0) }
            }

        case .blinds(let forward):
            let count = 8
            let barWidth = size.width / CGFloat(count)
            HStack(spacing: 0) {
                ForEach(0..<count, id: \.self) { _ in
                    ZStack(alignment: forward ? .leading : .trailing) {
                        Color.clear
                        Rectangle().frame(width: barWidth * p)
                    }
                    .frame(width: barWidth)
                }
            }

        case .iris:
            let d = diagonal * p
            Circle()
                .frame(width: d, height: d)
                .position(x: size.width / 2, y: size.height / 2)

        case .cornerCircle:
            let d = 2 * diagonal * p
            Circle()
                .frame(width: d, height: d)
                .position(x: 0, y: 0)
        }
    }
}

extension AnyTransition {
    /// Transition par masque : la nouvelle image est dévoilée (insertion) tandis que
    /// l'ancienne reste immobile dessous (removal `.identity`).
    static func maskReveal(_ style: MaskRevealModifier.Style) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active:   MaskRevealModifier(progress: 0, style: style),
                identity: MaskRevealModifier(progress: 1, style: style)
            ),
            removal: .identity
        )
    }
}
