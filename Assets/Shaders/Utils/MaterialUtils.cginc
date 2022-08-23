#ifndef _MaterialUtils
#define _MaterialUtils

#include "Utils/MathUtils.cginc"

//Give a position
float3 SubdivideVoxel(float3 pos, float split)
{
    float3 fracPos = frac(pos);
    return floor(fracPos * split) / split;
}

float3 SubdivideVoxel(float3 pos, float3 normal, float split)
{
    float3 fracPos = frac(pos - normal * 0.001);
    return floor(fracPos * split) / split;
}

#endif