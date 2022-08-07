#include "VoxelRayTracerDatas.cginc"
#include "Utils/LightUtils.cginc"


Material GetColorMaterial1(in SceneData sceneData, in RayHit hit)
{
    Material material;
    material.reflection = 0.2;
    material.blur = 0;

    float3 col = float3(1,1,1);

    material.color = col * BasicLight(sceneData, hit);

    return material;
}