#include "VoxelRayTracerDatas.cginc"

#include "Utils/MathUtils.cginc"
#include "Utils/NoiseUtils.cginc"
#include "Utils/LightUtils.cginc"
#include "Utils/MaterialUtils.cginc"


float2 DxDy(float x1, float x2, float y1, float y2, float d)
{
    return float2(x2 - x1, y2 - y1) / d;
}

float3 DxDyDz(float x1, float x2, float y1, float y2, float z1, float z2, float d)
{
    return float3(x2 - x1, y2 - y1, z2 - z1) / d;
}

float3 GetNormal(float3 normal, float3 dxdydz)
{
    float3 ortho = normalize(cross(normal, dxdydz));
    return cross(dxdydz, ortho);
}

float3 GetColorMaterial_Crystal(in SceneData sceneData, inout RayHit hit)
{
    return 1;

    float2 pos2D = ProjectOnPlaneTo2D(hit.pos, hit.normal);

    // // sample the height map:
    // float fx0 = f(x-1,y), fx1 = f(x+1,y);
    // float fy0 = f(x,y-1), fy1 = f(x,y+1);

    // // the spacing of the grid in same units as the height map
    // float eps = ... ;

    // // plug into the formulae above:
    // vec3 n = normalize(vec3((fx0 - fx1)/(2*eps), (fy0 - fy1)/(2*eps), 1));




    float e = 0.001;
    float size = 0.05;
    int fbmCount = 5;
    float cell = cellfbm(pos2D * size, fbmCount).x;
    float cellx = cellfbm(pos2D * size + float2(e, 0), fbmCount).x;
    float celly = cellfbm(pos2D * size + float2(0, e), fbmCount).x;
    
    float extrude = 2.5;
    cell *= extrude;
    cellx *= extrude;
    celly *= extrude;

    //cell = clamp(cell, 0.2, 1);
    //cellx = clamp(cellx, 0.2, 1);
    //celly = clamp(celly, 0.2, 1);

    float dx = (cellx - cell)/e;
    float dy = (celly - cell)/e;
    float dz = 50;

    float quantize = 1;
    dx = Quantize(dx, quantize);
    dy = Quantize(dy, quantize);

    float3 localNormal = normalize(float3(dx, dy, dz));


    float3x3 tbn = GetTBN(hit.normal);
    hit.normal = mul(tbn, localNormal);

    //hit.normal = GetNormal(hit.normal, float3((cellx - cell), celly - cell, 0)/e);

    return 1;// saturate(0.5 + float3((dx), (dy), (dz)) * 0.5);//normalize(float3(dx, dy, 1));
}