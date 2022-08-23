#include "VoxelRayTracerDatas.cginc"


float3 GetColorMaterial_Blocks(in SceneData sceneData, inout RayHit hit)
{
    uint state = WangHash(hit.cell.x * 11 + hit.cell.y * 13 + hit.cell.z * 17);
    float hue = NextFloat(0, 1, state);
    hue = frac(hue);

    float3 col = hsv2rgb(float3(hue, 0.1, 1.0));
    if(hit.uv.x > 0.9 || hit.uv.y > 0.9)
    {
        col *= 0.8;
    }
    return col;
}