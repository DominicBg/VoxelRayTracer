#include "VoxelRayTracerDatas.cginc"
#include "Utils/LightUtils.cginc"
#include "Utils/MathUtils.cginc"



float GetDist(float3 p, float t)
{
    float2 center = 50;
    float d = distance(p.xz, center);
    float fadeoff = 1 - saturate(d/50);
    return p.y + 0.05 * (sin(-t * 5 + d * 0.75) * 0.5 + 0.5) * fadeoff;
}

float3 GetNormal(float3 p, float t)
{
	float d = GetDist(p, t);
    float2 e = float2(.001, 0);
    
    float3 n = d - float3(
        GetDist(p-e.xyy, t),
        GetDist(p-e.yxy, t),
        GetDist(p-e.yyx, t));
    
    return normalize(n);
}

Material GetColorMaterial_Water(in SceneData sceneData, inout RayHit hit)
{
    Material material;
    material.reflection = 0.9;
    material.blur = 0.01;

    float3 col = float3(1,1,1);

    hit.normal = GetNormal(hit.pos, sceneData.time);
    hit.reflDir = reflect(hit.rd, hit.normal);
    material.color = BasicLight(sceneData, hit);

    return material;
}