//
//  Transitions.metal
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-19.
//
//  Shaders des transitions premium « Metal » (Evo_007), pilotés par SwiftUI
//  (.layerEffect). progress va de 0 (ancienne image) à 1 (nouvelle image).
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

/// Bruit pseudo-aléatoire déterministe dans [0, 1].
static float hash21(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

/// Glitch RGB : appliqué au composite fondu (une seule couche). Décale les canaux
/// rouge et bleu horizontalement par bandes (scanlines), avec une intensité qui
/// culmine au milieu de la transition.
[[ stitchable ]] half4 glitch(float2 position, SwiftUI::Layer layer,
                              float progress, float maxOffset) {
    float intensity = sin(progress * M_PI_F);
    float line = hash21(float2(floor(position.y / 6.0), floor(progress * 20.0)));
    float off = (line - 0.5) * 2.0 * maxOffset * intensity;

    half4 c;
    c.r = layer.sample(position + float2(off, 0.0)).r;
    c.g = layer.sample(position).g;
    c.b = layer.sample(position - float2(off, 0.0)).b;
    c.a = layer.sample(position).a;
    return c;
}
