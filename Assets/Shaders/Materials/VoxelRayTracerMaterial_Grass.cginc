#include "VoxelRayTracerDatas.cginc"

#include "Utils/MathUtils.cginc"
#include "Utils/LightUtils.cginc"
#include "Utils/MaterialUtils.cginc"


float3 GetColorMaterial_Grass(in SceneData sceneData, inout RayHit hit)
{
    float3 subdivision = SubdivideVoxel(hit.pos, hit.normal, 4);

    float3 col = 0;
    
    uint rngState = GenerateRngState(hit.cell + subdivision * 4, 55);
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
    
    
    return col;
}