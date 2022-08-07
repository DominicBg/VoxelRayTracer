#include "VoxelRayTracerDatas.cginc"



Material GetColorMaterial2(in LightData lightData, in RayHit hit, in Settings settings, in Texture3D<uint> voxel)
{
    Material material;
    material.reflection = 0.5;
    material.blur = 0;

    float3 col = float3(1,1,1);
    material.color = col * BasicLight(lightData, hit, settings, voxel);

    return material;
}