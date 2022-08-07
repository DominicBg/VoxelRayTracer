#include "VoxelRayTracerDatas.cginc"



Material GetColorMaterial3(in SceneData sceneData, in RayHit hit)
{
    Material material;
    material.reflection = 0.1;
    material.blur = 0;

    float3 col = float3(1,1,1);

    material.color = col * BasicLight(sceneData, hit);
    return material;
}