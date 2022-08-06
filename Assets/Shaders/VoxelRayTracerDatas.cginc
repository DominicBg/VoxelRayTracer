#ifndef VoxelRayTracerDatas
#define VoxelRayTracerDatas

struct RayHit
{
    float3 ro;
    float3 rd;
    
    bool hasHit;
    float3 pos;
    float dist;
    float dist2; //calculate the second ray intersection

    float3 normal;
    float3 reflDir;
    float2 uv;
    int3 cell;
    uint materialID;
};

struct LightData
{
    float3 position;
    float3 color;
    float intensity;
    float radius;

    //https://en.wikipedia.org/wiki/Umbra,_penumbra_and_antumbra
    float penumbraRadius;
};

#endif
