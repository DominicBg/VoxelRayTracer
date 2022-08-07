
#include "VoxelRayTracerDatas.cginc"
#include "Materials/VoxelRayTracerMaterial1.cginc"
#include "Materials/VoxelRayTracerMaterial2.cginc"
#include "Materials/VoxelRayTracerMaterial3.cginc"

Material GetColor(uint materialID, in LightData lightData, in RayHit hit, in Settings settings, in Texture3D<uint> voxel)
{
    switch(materialID)
    {
        case 1: return GetColorMaterial1(lightData, hit, settings, voxel);
        case 2: return GetColorMaterial2(lightData, hit, settings, voxel);
        case 3: return GetColorMaterial3(lightData, hit, settings, voxel);
    }

    Material material;
    material.blur = 0;
    material.color = 0;
    material.reflection = 0;
    return material;
}