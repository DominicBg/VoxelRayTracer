#include "VoxelRayTracerDatas.cginc"

#include "Utils/MathUtils.cginc"
#include "Utils/LightUtils.cginc"
#include "Utils/MaterialUtils.cginc"


Material GetColorMaterial_Grass(in SceneData sceneData, inout RayHit hit)
{
    Material material;
    material.reflection = 0.0;
    material.blur = 0.0;

    //bool isGrass = sceneData.voxel[hit.cell + int3(0, 1, 0)] == 0;

    float3 subdivision = SubdivideVoxel(hit.pos, hit.normal, 4);

    float3 col = 0;
    //if (isGrass)
    {
        uint rngState = GenerateRngState(subdivision + hit.cell, 25);
        float randomValue = NextFloat(0, 1, rngState);
        if (randomValue > 0.7)
        {
            col = GetColor(31, 209, 80);
        }
        else if (randomValue > 0.3)
        {
            col = GetColor(81, 232, 154);
        }
        else
        {
            col = GetColor(50, 168, 82);
        }
    }
    // else //is ground
    // {
    //     col = GetColor(79, 37, 9);
    // }
    material.color = col * BasicLight(sceneData, hit);

    return material;
}