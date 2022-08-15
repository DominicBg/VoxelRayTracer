#include "VoxelRayTracerDatas.cginc"
#include "Utils/LightUtils.cginc"
#include "Utils/MathUtils.cginc"



float GetDist(float3 p, float t)
{
    float2 center = 50;
    float d = distance(p.xz, center);
    float height = (sin(-t * 5 + d * 0.75) * 0.5 + 0.5);
    return height;
}

/*
float3 calcNormal(float3 p, float t ) // for function f(p)
{
    const float h = 0.001; // replace by an appropriate value
    const float2 k = float2(1,-1);
    return normalize( k.xyy*GetWavePoint( p + k.xyy*h, t) + 
                      k.yyx*GetWavePoint( p + k.yyx*h, t) + 
                      k.yxy*GetWavePoint( p + k.yxy*h, t) + 
                      k.xxx*GetWavePoint( p + k.xxx*h, t) );
}*/

float3 GetNormal(float3 p, float t)
{
	float d = GetDist(p, t);
    float2 e = float2(.01, 0);
    
    float3 n = d - float3(
        GetDist(p-e.xyy, t),
        GetDist(p-e.yxy, t),
        GetDist(p-e.yyx, t));
    
    return normalize(n);
}

/*
float3 GetNormal(float3 p, float t)
{
    float h = 0.001;
    float3 dx = (GetWavePoint(p + float3(h, 0, 0), t) - GetWavePoint(p - float3(h, 0, 0), t)) / (2*h);
    float3 dy = (GetWavePoint(p + float3(0, h, 0), t) - GetWavePoint(p - float3(0, h, 0), t)) / (2*h);
    float3 dz = (GetWavePoint(p + float3(0, 0, h), t) - GetWavePoint(p - float3(0, 0, h), t)) / (2*h);
    return normalize(float3(dx.x, dy.y, dz.z));
}
*/
Material GetColorMaterial_Water(in SceneData sceneData, inout RayHit hit)
{
    Material material;
    material.reflection = 0.9;
    material.blur = 0.1;

    float3 col = float3(1,1,1);

    //material.color = CalcNormal(hit.pos, sceneData.time) * 0.5 + 0.5;

    //water reflection
    //float h = 0.001;
    //float xz = hit.pos.x + hit.pos.z;
    //float dx = sin(sceneData.time + xz + h ) - sin(sceneData.time + xz - h) / (2 * h);

    //float wave = 0.1 * sin(sceneData.time + hit.pos.x + hit.pos.z);
    float3 randomPos = hit.pos + hit.normal + ShittyRandom(hit.pos * 5.5 + sceneData.time) * 0.5;
    hit.normal = normalize(randomPos - hit.pos);
    //hit.normal = GetNormal(hit.pos, sceneData.time);
    //hit.reflDir = reflect(hit.rd, hit.normal);
    material.color = BasicLight(sceneData, hit);
    //material.color = BasicLight(sceneData, hit);

    
    return material;
}