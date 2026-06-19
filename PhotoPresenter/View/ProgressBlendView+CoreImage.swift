//
//  ProgressBlendView+CoreImage.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//
//  Back-end Core Image du chemin « progression » (Evo_006) : Ondulation
//  (CIRippleTransition) et Tourne-page (CIPageCurlWithShadowTransition). Les filtres
//  de transition CI suivent exactement le modèle inputImage + targetImage + time(0→1).
//

import SwiftUI
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension ProgressBlendView {

    /// Contexte CI partagé (création coûteuse) ; GPU par défaut.
    static let ciContext = CIContext()

    /// Image d'ombrage par défaut pour l'Ondulation (réfraction). Générée une fois.
    static let rippleShading: CIImage = {
        let f = CIFilter.linearGradient()
        f.point0 = CGPoint(x: 0, y: 0)
        f.point1 = CGPoint(x: 300, y: 300)
        f.color0 = CIColor(red: 1, green: 1, blue: 1, alpha: 1)
        f.color1 = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
        return f.outputImage ?? CIImage(color: .gray)
    }()

    /// Rend la frame de transition (mode CI) pour la progression donnée.
    func coreImageTransition(progress: Double) -> NSImage? {
        guard
            let fromCG = oldImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let toCG = newImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return nil }

        let fromRaw = CIImage(cgImage: fromCG)
        let toRaw = CIImage(cgImage: toCG)

        // Extent commun, plafonné pour préserver la fluidité (rendu par frame).
        let cap: CGFloat = 1600
        let w = fromRaw.extent.width, h = fromRaw.extent.height
        guard w > 0, h > 0 else { return nil }
        let k = min(1, cap / max(w, h))
        let extent = CGRect(x: 0, y: 0, width: (w * k).rounded(), height: (h * k).rounded())

        let from = fit(fromRaw, to: extent)
        let to = fit(toRaw, to: extent)

        let output: CIImage?
        switch mode {
        case .ripple:
            let f = CIFilter.rippleTransition()
            f.inputImage = from
            f.targetImage = to
            f.shadingImage = Self.rippleShading
            f.center = CGPoint(x: extent.midX, y: extent.midY)
            f.extent = extent
            f.width = 100
            f.scale = 50
            f.time = Float(progress)
            output = f.outputImage

        case .pageCurl:
            let f = CIFilter.pageCurlWithShadowTransition()
            f.inputImage = from
            f.targetImage = to
            f.backsideImage = to
            f.extent = extent
            f.angle = Float(-Double.pi / 4)   // coin de courbure fixe
            f.radius = 70
            f.shadowSize = 0.5
            f.shadowAmount = 0.7
            f.shadowExtent = extent
            f.time = Float(progress)
            output = f.outputImage

        case .pixelate:
            // Fondu (dissolve) puis pixellisation, taille de bloc culminant au
            // milieu de la transition (effet mosaïque).
            let dissolve = CIFilter.dissolveTransition()
            dissolve.inputImage = from
            dissolve.targetImage = to
            dissolve.time = Float(progress)
            if let blended = dissolve.outputImage {
                let pix = CIFilter.pixellate()
                pix.inputImage = blended
                pix.center = CGPoint(x: extent.midX, y: extent.midY)
                pix.scale = max(1, 40 * Float(sin(progress * .pi)))
                output = pix.outputImage
            } else {
                output = nil
            }

        default:
            output = nil
        }

        guard
            let out = output?.cropped(to: extent),
            let cg = Self.ciContext.createCGImage(out, from: extent)
        else { return nil }

        return NSImage(cgImage: cg, size: NSSize(width: extent.width, height: extent.height))
    }

    /// Met une CIImage à l'échelle d'un extent cible.
    private func fit(_ image: CIImage, to extent: CGRect) -> CIImage {
        let sx = extent.width / image.extent.width
        let sy = extent.height / image.extent.height
        return image.transformed(by: CGAffineTransform(scaleX: sx, y: sy))
    }
}
