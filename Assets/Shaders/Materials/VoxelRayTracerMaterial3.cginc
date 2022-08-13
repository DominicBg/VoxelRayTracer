#include "VoxelRayTracerDatas.cginc"



Material GetColorMaterial3(in SceneData sceneData, inout RayHit hit)
{
    Material material;
    material.reflection = 0.0;
    material.blur = 0;

    uint state = WangHash(hit.cell.x * 11 + hit.cell.y * 13 + hit.cell.z * 17);
    float hue = NextFloat(0, 1, state);
    hue = frac(hue);

    float3 col = hsv2rgb(float3(hue, 0.1, 1.0));
    if(hit.uv.x > 0.9 || hit.uv.y > 0.9)
    {
        col *= 0.8;
    }

    material.color = col * BasicLight(sceneData, hit);
    return material;
}