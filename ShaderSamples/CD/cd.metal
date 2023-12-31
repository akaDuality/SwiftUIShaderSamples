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
    float x=cos(a), y=sin(a);
    return float2x2(x, -y, y, x);
}

float3 streak(float2 uv, float angle, float3 color, float width, float maxBrightness) {
    float diameter = length(uv); // higher value on the edge
    
    float2 rotUV = uv * Rotate(angle);
    float uvY = rotUV.y; // 0 to 1 with rotation, no need for X
    
    // Create waves
    float streak = cos(uvY * width) // wake waves
    * diameter; // brighter on the edge
    
    // Get only center waves
    float limit = 3/width;
    float mask = 0.0;
    if (uvY >= -limit && uvY <= limit) { // [-0.125; +0.125]
        mask = 1.0; // show only single wave near 0
    }
    float centralStreak = clamp(streak * mask, 0., maxBrightness); // limit higher value by 0.6
    // for addition to default 0.4
    
    // Use value as brightness
    return float3(color.x,          // H
                  color.y,          // S
                  centralStreak);   // V
}

float2 centeredRelativeUV(float2 position, float2 viewSize) {
    float2 uv = position / viewSize; // Relative texture coordinates with values from 0 to 1
    uv -= .5; // Move origin to center
    return uv;
}

[[ stitchable ]] half4 cdSingleStreak(float2 position, half4 color, float2 viewSize, float accel) {
    float2 uv = centeredRelativeUV(position, viewSize); // Move coordinates to circle center
    
    float minBrightness = 0.4;
    float3 streakHSV = streak(uv,
                              sin(accel), // angle
                              0.6, // color
                              20., // width
                              1 - minBrightness
                              );
    
    float4 resultColor = float4(float3(minBrightness), 1.0); // Default brightness and alpha
    resultColor += HSVtoRGB(streakHSV);
    
    return half4(resultColor);
}

[[ stitchable ]] half4 cd(float2 position, half4 color, float2 viewSize, float accel) {
    float2 uv = centeredRelativeUV(position, viewSize); // Move coordinates to circle center
    
    float minBrightness = 0.4;
    float4 resultColor = float4(float3(minBrightness), 1.0); // Default brightness and alpha
    
    for (float i = 0; i < 25; i++) {
        float width = clamp((sin(i+1)+1) * 100, 10., 180.); // [10, 180]
        
        float hue = sin(i*8.11)+1.0; // 220 is max radian, hue in [0, 2]
        float3 streakColor = saturate(float3(hue,
                                             0.7,  // saturation
                                             0.5)); // brightness
        
        float angle = (9*i+sin(accel*i*3));
        float3 streakHSV = streak(uv, angle, streakColor, width, 1 - minBrightness);
        
        float o = saturate(1 - (width / 180.0)) * 0.9; // [0, 0.9]
        resultColor += HSVtoRGB(streakHSV) * o;
    }
    
    return half4(resultColor);
}
