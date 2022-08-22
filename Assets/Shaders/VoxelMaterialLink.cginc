
#ifndef _VoxelMaterialLink
#define _VoxelMaterialLink

#include "VoxelRayTracerDatas.cginc"
#include "Materials/VoxelRayTracerMaterial_Water.cginc"
#include "Materials/VoxelRayTracerMaterial_Grass.cginc"
#include "Materials/VoxelRayTracerMaterial2.cginc"
#include "Materials/VoxelRayTracerMaterial_Blocks.cginc"

//#include "Skybox/SimpleSkybox.cginc"
#include "Skybox/FunkySkybox.cginc"


Material GetColor(uint materialID, in SceneData sceneData, inout RayHit hit)
{
    switch(materialID)
    {
        case 1: return GetColorMaterial_Water(sceneData, hit);
        case 2: return GetColorMaterial_Grass(sceneData, hit);
        case 3: return GetColorMaterial_Blocks(sceneData, hit);
        default: break;
    }

    Material material;
    material.blur = 0;
    material.color = 0;
    material.reflection = 0;
    material.skyboxLight = 0;
    return material;
}

float GetDiffuseCoef(in RayHit hit)
{
    switch(hit.materialID)
    {
        case 1: return 0.0;
        case 2: return 0.5; //1.0;
        case 3: return 0.0; //0.5;
        default: break;
    }
    return 0;
}

float3 SampleSkybox(in SceneData sceneData, in RayHit hit)
{
    return SampleFunkySkybox(hit.ro, hit.rd, sceneData.time);
}

#endif