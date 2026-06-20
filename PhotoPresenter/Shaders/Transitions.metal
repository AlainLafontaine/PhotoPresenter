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

/// Damier : la couche (nouvelle image) recouvre l'ancienne (texture) case par case,
/// en deux vagues selon la parité de la case. `cell` = taille de case (points),
/// `size` = taille de la vue pour normaliser l'échantillonnage de l'ancienne image.
[[ stitchable ]] half4 checkerboard(float2 position, SwiftUI::Layer layer,
                                    float2 size, float progress, float cell,
                                    texture2d<half> oldImage) {
    constexpr sampler smp(coord::normalized, address::clamp_to_edge, filter::linear);
    half4 newColor = layer.sample(position);
    half4 oldColor = oldImage.sample(smp, position / size);

    float2 idx = floor(position / cell);
    float parity = fmod(idx.x + idx.y, 2.0);
    float threshold = parity < 0.5 ? progress * 2.0 : progress * 2.0 - 1.0;
    return threshold > 0.0 ? newColor : oldColor;
}

/// Dissolution granuleuse : chaque petit bloc bascule vers la nouvelle image quand
/// un bruit déterministe passe sous `progress`.
[[ stitchable ]] half4 dissolve(float2 position, SwiftUI::Layer layer,
                                float2 size, float progress,
                                texture2d<half> oldImage) {
    constexpr sampler smp(coord::normalized, address::clamp_to_edge, filter::linear);
    half4 newColor = layer.sample(position);
    half4 oldColor = oldImage.sample(smp, position / size);

    float n = hash21(floor(position / 3.0));
    return n < progress ? newColor : oldColor;
}
