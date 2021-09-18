//
//  shaderOne.metal
//  shaderOne
//
//  Created by Andrew Sawyer on 9/18/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void shaderOne (
    texture2d<float, access::write> outTexture [[texture(0)]],
    texture2d<float, access::read> inTexture [[texture(1)]],
    uint2 id [[thread_position_in_grid]])
{
    
    float3 val = inTexture.read(id).rgb;
    float gray = (val.r + val.g + val.b)/3.0;
    float4 out = float4(val.g, val.b, val.r, 1.0);
    outTexture.write(out.rgba, id);
    
}
