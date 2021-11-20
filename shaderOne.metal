//
//  shaderOne.metal
//  shaderOne
//
//  Created by Andrew Sawyer on 9/18/21.
//

#include <metal_stdlib>
using namespace metal;

struct FilterAttributes {
    float pixelSize [[attribute(0)]];;
};

kernel void shaderOne (
    constant FilterAttributes *params [[buffer(0)]],
    texture2d<float, access::write> outTexture [[texture(1)]],
    texture2d<float, access::read> inTexture [[texture(2)]],
    uint2 id [[thread_position_in_grid]])
{
    
    //const float pixelSize = 8;
    float pixelSize = params->pixelSize;
    
    float firstInGroupX = id.x/pixelSize;
    float firstInGroupY = id.y/pixelSize;
    const float center = pixelSize/2;
    
    int referencePosX = floor(firstInGroupX) * pixelSize + floor(center);
    int referencePosy = floor(firstInGroupY) * pixelSize + floor(center);
//    
    uint2 pixelateReferencePos = uint2(referencePosX,referencePosy);
//    
    float3 original = inTexture.read(pixelateReferencePos).rgb;
//
    //vertical
    float stateCalc1 = id.x/(pixelSize/4);
    float stateCalc2 = int(floor(stateCalc1)) % 4;
    int state = floor(stateCalc2);

    
    float3 mask;
    if (state == 0) {
        mask = float3(1, 0, 0);

    } else if (state == 1) {
        mask = float3(0, 1, 0);

    } else if (state == 2) {
        mask = float3(0, 0, 1);

    } else { //if (state == 3)
        mask = float3(0, 0, 0);
    }
    
    //combine
    float3 combined = original * mask;

    
    //out
    float4 withAlpha = float4(combined.r, combined.g, combined.b, 1.0);
    outTexture.write(withAlpha, id);
    
//    float4 original4 = float4(original.r, original.g, original.b, 1.0);
//    outTexture.write(original4, id);
    
}
