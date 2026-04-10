#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// ---------------------------------------------------------------------------
// Small, cheap 2D value-noise helpers. We avoid proper simplex/Perlin because
// the ambient effect only needs smooth, flowing colour — not crisp detail.
// Every helper is inlined; the shader budget stays trivially cheap.
// ---------------------------------------------------------------------------

static float2 hash2(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)),
               dot(p, float2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453) * 2.0 - 1.0;
}

static float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash2(i + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
                   dot(hash2(i + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
               mix(dot(hash2(i + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
                   dot(hash2(i + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
}

static float fbm(float2 p) {
    float total = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        total += noise(p) * amplitude;
        p *= 2.02;
        amplitude *= 0.5;
    }
    return total;
}

// ---------------------------------------------------------------------------
// `aurora`: used with `.colorEffect`. Produces a slow, never-repeating wash
// that blends three aurora hues (indigo → purple → blue) based on coordinate
// and time. `position` is in pixel space, so we normalise by `size` so the
// pattern does not stretch with the view.
// ---------------------------------------------------------------------------

[[ stitchable ]] half4 aurora(float2 position,
                              half4 currentColor,
                              float2 size,
                              float time) {
    float2 uv = position / max(size, float2(1.0));
    float t = time * 0.12;

    float n = fbm(uv * 2.0 + float2(t, -t * 0.7));
    float n2 = fbm(uv * 3.5 - float2(t * 0.5, t));

    half3 indigo = half3(0.35, 0.27, 0.86);
    half3 purple = half3(0.64, 0.34, 0.95);
    half3 blue = half3(0.22, 0.58, 0.98);

    float mix1 = clamp(n * 0.5 + 0.5, 0.0, 1.0);
    float mix2 = clamp(n2 * 0.5 + 0.5, 0.0, 1.0);

    half3 color = mix(mix(indigo, purple, half(mix1)), blue, half(mix2));
    half alpha = currentColor.a;
    return half4(color * alpha, alpha);
}
