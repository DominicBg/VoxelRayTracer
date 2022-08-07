#include "VoxelRayTracerDatas.cginc"
#include "Utils/LightUtils.cginc"


Material GetColorMaterial1(in LightData lightData, in RayHit hit, in Settings settings, in Texture3D<uint> voxel)
{
    Material material;
    material.reflection = 0.2;
    material.blur = 0;

    float3 col = float3(1,1,1);

    material.color = col * BasicLight(lightData, hit, settings, voxel);

    return material;
}