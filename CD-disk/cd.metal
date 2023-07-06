//
//  cd.metal
//  CD
//
//  Created by Daniel Kuntz on 7/3/23.
//

#include <metal_stdlib>
using namespace metal;

// Standard convert from RGB to HUE
float3 Hue(float H) {
    half R = abs(H * 6 - 3) - 1;
    half G = 2 - abs(H * 6 - 2);
    half B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B)); // [0, 1]
}

float4 HSVtoRGB(float3 HSV) {
    return float4(((Hue(HSV.x) - 1) * HSV.y + 1) * HSV.z,1);
}

float2x2 Rotate(float a) {
    float x=sin(a), y=cos(a);
    return float2x2(y, -x, x, y);
}

float3 streak(float2 uv, float angle, float3 color, float w) {
    float2 rotUV = uv * Rotate(angle);
    float diameter = length(uv);
    float mask = 0.0;
    if (rotUV.y >= -1/(w/3.) && rotUV.y <= 1/(w/3.)) {
        mask = 1.0;
    }
    float streak = cos(abs(rotUV.y*w)) * mask * diameter;
    return float3(color.x,                  // H
                  color.y,                  // S
                  clamp(streak, 0., 0.3));  // V
    return clamp(color * streak, 0, 1);
}

[[ stitchable ]] half4 cd(float2 position, half4 color, float2 viewSize, float accel) {
    float2 uv = position / viewSize; // Texture coordinates
    uv -= .5; // Move origin to center
    uv.x *= viewSize.x / viewSize.y;
    float4 resultColor = float4(float3(0.4), 1.0); // Default brightness and alpha
    
    for (float i = 0; i < 25; i++) {
        float angle = (9*i+sin(accel*i*3)); // Mirrored angle
        float w = clamp((sin(i+1)+1) * 100.29, 10., 1000.);
        float saturation = 0.7-(w/1000.0);
        float3 streakColor = clamp(float3(sin(i*8.11)+1.0,  // Hue
                                          saturation,       // Saturation
                                          0.5),             // Value aka Brightness
                                   0, 1);                   // Alpha
        float o = clamp(1 - (w / 180.0), 0., 1.) * 0.9;
        float3 streakHSV = streak(uv, angle, streakColor, w);
        resultColor += HSVtoRGB(streakHSV) * o;
    }

    return half4(resultColor);
}
