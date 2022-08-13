#include "VoxelRayTracerDatas.cginc"



Material GetColorMaterial2(in SceneData sceneData, inout RayHit hit)
{
    Material material;
    material.reflection = 0.5;
    material.blur = 0.0;

    float3 col = float3(1,1,1);
    material.color = col * BasicLight(sceneData, hit);

    return material;
}