#include "VoxelRayTracerDatas.cginc"
#include "Utils/LightUtils.cginc"
#include "Utils/MathUtils.cginc"



// float GetDist(float3 p, float3 n, float t)
// {
//     float2 center = 128/2;
//     float d = distance(p.xz, center);
//     float fadeoff = 1 - saturate(d/50);
//     float3 samplePoint = p + n * 0.05 * (sin(-t * 5 + d * 0.75) * 0.5 + 0.5) * fadeoff;
//     return distance(p, samplePoint);
// }

float GetDist(float3 p, float3 n, float t)
{
    float2 center = 128/2;
    float d = distance(p.xz, center);
    float fadeoff = 1 - saturate(d/75);
    float sin1 = 0.1 * (sin(-t * 5 + d * 1.5) * 0.5 + 0.5);
    float sin2 = 0.05 * (sin(-t * 2.5 + d * 2.5) * 0.5 + 0.5);
    float sin3 = 0.025 * (sin(-t * 1.5 + d * 7.5 + 0.25) * 0.5 + 0.5);
    return p.y + 1.5 * (sin1 + sin2) * fadeoff;
    //return distance(p, samplePoint);
}

float3 GetNormal(float3 p, float3 n, float t)
{
	float d = GetDist(p, n, t);
    float2 e = float2(.1, 0);
    
    float3 dir = d - float3(
        GetDist(p-e.xyy, n, t),
        GetDist(p-e.yxy, n, t),
        GetDist(p-e.yyx, n, t));
    
    return normalize(dir);
}

float3 GetColorMaterial_Water(in SceneData sceneData, inout RayHit hit)
{
    float3 col = GetColor(163, 195, 247);

    hit.normal = GetNormal(hit.pos, hit.normal, sceneData.time);
    hit.reflDir = reflect(hit.rd, hit.normal);
    return col;
}