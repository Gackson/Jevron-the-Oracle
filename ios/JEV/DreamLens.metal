#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Two dense separable Gaussian passes avoid the repeated contours of sparse taps.
[[ stitchable ]] half4 dreamLens(float2 position, SwiftUI::Layer layer, float2 size, float vertical) {
    float2 uv = position / max(size, float2(1.0));
    float2 centered = (uv - float2(0.5, 0.40)) * float2(2.0, 1.65);
    float edge = smoothstep(0.38, 1.06, length(centered));
    float2 origin = size * float2(0.5, 0.40);
    float2 sample = origin + (position - origin) * (1.0 - edge * 0.055 * vertical);
    float2 axis = vertical > 0.5 ? float2(0, 1) : float2(1, 0);
    if (edge < 0.001) return layer.sample(sample);
    half4 color = half4(0);
    float weightSum = 0;
    for (int i = -12; i <= 12; ++i) {
        float weight = exp(-float(i * i) / 50.0);
        color += layer.sample(sample + axis * float(i) * edge) * half(weight);
        weightSum += weight;
    }
    return color / half(weightSum);
}

// Small-baseline inverse reprojection of a single connected depth surface.
// Geometry is slope-limited offline. This fixed-point inverse stays continuous:
// all pixels of a contact edge, its support and shadow share the same transform.
[[ stitchable ]] half4 sceneDepth(float2 position, SwiftUI::Layer layer, float2 size,
                                 float2 pose, texture2d<half> depth) {
    constexpr sampler linearSampler(coord::normalized, address::clamp_to_edge, filter::linear);
    float2 baseline = clamp(pose, -1.0, 1.0) * min(float2(30.0, 20.0), size * float2(0.050, 0.020));
    // Every depth lies behind the glass; far pixels travel further than near pixels.
    float2 source = position;
    for (int i = 0; i < 12; ++i) {
        float d = float(depth.sample(linearSampler, source / size).r);
        source = position - baseline * (d - 1.3);
    }
    return layer.sample(source);
}
