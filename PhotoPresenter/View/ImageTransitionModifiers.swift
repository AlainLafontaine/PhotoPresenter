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
