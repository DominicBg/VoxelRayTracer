
#include "VoxelRayTracerDatas.cginc"
#include "Materials/VoxelRayTracerMaterial1.cginc"
#include "Materials/VoxelRayTracerMaterial2.cginc"
#include "Materials/VoxelRayTracerMaterial3.cginc"

Material GetColor(uint materialID, in SceneData sceneData, in RayHit hit)
{
    switch(materialID)
    {
        case 1: return GetColorMaterial1(sceneData, hit);
        case 2: return GetColorMaterial2(sceneData, hit);
        case 3: return GetColorMaterial3(sceneData, hit);
    }

    Material material;
    material.blur = 0;
    material.color = 0;
    material.reflection = 0;
    return material;
}