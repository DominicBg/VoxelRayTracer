#ifndef _VoxelRayTracerDatas
#define _VoxelRayTracerDatas

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
    int type;
    float3 position;
    float3 color;
    float3 dir;
    float intensity;
    float volumetricIntensity;
    float radius;

    //https://en.wikipedia.org/wiki/Umbra,_penumbra_and_antumbra
    float penumbraRadius;
};

struct Material
{
    float3 color;
    float reflection;
    float blur;
    float skyboxLight;
    //todo add ior (index of refraction)
};

struct Settings
{
    int maxSteps;
    int volumetricLightSteps;
    int blurIterations;
    int shadowIterations;
};

struct SceneData
{
    Texture3D<uint> voxel;
    Texture3D<uint> voxelTransparent;
    Texture3D<float> volumetricNoise;
    StructuredBuffer<LightData> lightDatas;
    Settings settings;
    float time;
    int3 voxelSizes;
};

#endif
