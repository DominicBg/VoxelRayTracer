
#include "VoxelRayTracerDatas.cginc"
#include "Materials/VoxelRayTracerMaterial_Water.cginc"
#include "Materials/VoxelRayTracerMaterial_Grass.cginc"
#include "Materials/VoxelRayTracerMaterial2.cginc"
#include "Materials/VoxelRayTracerMaterial3.cginc"

Material GetColor(uint materialID, in SceneData sceneData, inout RayHit hit)
{
    switch(materialID)
    {
        case 1: return GetColorMaterial_Water(sceneData, hit);
        case 2: return GetColorMaterial_Grass(sceneData, hit);
        case 3: return GetColorMaterial3(sceneData, hit);
        default:break;
    }

    Material material;
    material.blur = 0;
    material.color = 0;
    material.reflection = 0;
    return material;
}