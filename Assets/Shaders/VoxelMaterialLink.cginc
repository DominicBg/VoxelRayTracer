
#ifndef _VoxelMaterialLink
#define _VoxelMaterialLink

#include "VoxelRayTracerDatas.cginc"
#include "Materials/VoxelRayTracerMaterial_Water.cginc"
#include "Materials/VoxelRayTracerMaterial_Grass.cginc"
#include "Materials/VoxelRayTracerMaterial2.cginc"
#include "Materials/VoxelRayTracerMaterial_Blocks.cginc"

#include "Skybox/SimpleSkybox.cginc"
//#include "Skybox/FunkySkybox.cginc"


float3 GetColor(in SceneData sceneData, inout RayHit hit)
{
    switch(hit.materialID)
    {
        case 1: return GetColorMaterial_Water(sceneData, hit);
        case 2: return GetColorMaterial_Grass(sceneData, hit);
        case 3: return GetColorMaterial_Blocks(sceneData, hit);
        case 4: return 1; //light test
        default: break;
    }
    return 0;
}

Material GetMaterial(in SceneData sceneData, inout RayHit hit)
{
    Material material;
    material.blur = 0;
    material.reflection = 0;
    material.skyboxLight = 0;

    switch(hit.materialID)
    {
        case 1:
            material.reflection = 0.9;
            material.skyboxLight = 0.2;
            material.blur = 0.01;
            break;

        case 2:
            material.reflection = 0.0;
            material.blur = 0.0;
            material.skyboxLight = 0.1;
            break;

        case 3:
            material.reflection = 0.0;
            material.blur = 0;
            material.skyboxLight = 0.1;
            break;

        default: break;
    }
    return material;
}

float GetDiffuseCoef(in RayHit hit)
{
    switch(hit.materialID)
    {
        case 1: return 0.0;
        case 2: return 1.0;
        case 3: return 0.1;
        default: break;
    }
    return 1;
}

float3 SampleSkybox(in SceneData sceneData, in RayHit hit)
{
    return SampleSimpleSkybox(hit.ro, hit.rd, sceneData.time);
}

#endif