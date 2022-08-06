
#include "VoxelRayTracerDatas.cginc"
#include "Materials/VoxelRayTracerMaterial1.cginc"
#include "Materials/VoxelRayTracerMaterial2.cginc"
#include "Materials/VoxelRayTracerMaterial3.cginc"

float3 GetColor(uint materialID, RayHit hit)
{
    switch(materialID)
    {
        case 1: return GetColorMaterial1(hit);
        case 2: return GetColorMaterial2(hit);
        case 3: return GetColorMaterial3(hit);
    }

    return 0;
}