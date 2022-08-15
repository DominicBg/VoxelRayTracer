#ifndef _VoxelRayCaster
#define _VoxelRayCaster


struct BoxIntersectionResult
{
    bool hasHit;
    float dist1;
    float dist2;
};

BoxIntersectionResult BoxIntersection(float3 bmin, float3 bmax, float3 ro, float3 rd)
{
    float3 invRd = 1. / rd;
    float tx1 = (bmin.x - ro.x) * invRd.x;
    float tx2 = (bmax.x - ro.x) * invRd.x;

    float tmin = min(tx1, tx2);
    float tmax = max(tx1, tx2);

    float ty1 = (bmin.y - ro.y) * invRd.y;
    float ty2 = (bmax.y - ro.y) * invRd.y;

    tmin = max(tmin, min(ty1, ty2));
    tmax = min(tmax, max(ty1, ty2));

    float tz1 = (bmin.z - ro.z) * invRd.z;
    float tz2 = (bmax.z - ro.z) * invRd.z;

    tmin = max(tmin, min(tz1, tz2));
    tmax = min(tmax, max(tz1, tz2));

    BoxIntersectionResult intersection;
    intersection.hasHit = tmax >= tmin;
    intersection.dist1 = tmin;
    intersection.dist2 = tmax;
    return intersection;
}

float2 GetUV(RayHit hit)
{
    float3 n = abs(hit.normal);
    if (n.x > 0.5)
    {
        return hit.pos.zy;
    }
    if (n.y > 0.5)
    {
        return hit.pos.xz;
    }
    //if(n.z > 0.5)

    {
        return hit.pos.xy;
    }
}

RayHit CalculateRayHit(float3 ro, float3 rd, int3 mapPos, bool3 mask, float skippedDist, Texture3D<uint> voxel)
{
    BoxIntersectionResult intersection = BoxIntersection(float3(mapPos), float3(mapPos + 1), ro, rd);
    float3 normal = float3(mask);
    normal *= sign(-rd);
    
    //Optim to start the ray where there's a voxel
    intersection.dist1 += skippedDist;
    intersection.dist2 += skippedDist;

    RayHit hit;
    hit.ro = ro;
    hit.rd = rd;
    hit.hasHit = intersection.hasHit;
    hit.dist = intersection.dist1;
    hit.dist2 = intersection.dist2;
    hit.pos = ro + rd * intersection.dist1;
    hit.normal = normal;
    hit.reflDir = reflect(rd, normal);
    hit.cell = mapPos;
    hit.uv = frac(GetUV(hit)); //validate uv
    hit.materialID = voxel[mapPos];
    return hit;
}


bool3 lessThanEqual(float3 a, float3 b)
{
    return bool3(a <= b);
}

RayHit RayCast(float3 ro, float3 rd, in SceneData sceneData)
{
    //Optim to start the ray at the voxel structure
    //BoxIntersectionResult voxelMapIntersection = BoxIntersection(-sceneData.voxelSizes/2, sceneData.voxelSizes/2, ro, rd);
    float skippedDist = 0;
    if (any(ro <= 0) || any(ro >= sceneData.voxelSizes))
    {
        BoxIntersectionResult voxelMapIntersection = BoxIntersection(0, sceneData.voxelSizes, ro, rd);
        if (!voxelMapIntersection.hasHit)
        {
            RayHit hit;
            hit.ro = ro;
            hit.rd = rd;
            hit.hasHit = false;
            return hit;
        }

        float3 startPos = ro + rd * voxelMapIntersection.dist1 - rd * 0.1;
        float skippedDist = distance(startPos, ro);
        ro = startPos;
    }

    int maxStep = sceneData.settings.maxSteps;

    //TODO add dynamic steps based on intersection depth or length to edge
    //int maxStep = floor(distance(voxelMapIntersection.dist1, voxelMapIntersection.dist2) * 2) + 1;
    Texture3D<uint> voxel = sceneData.voxel;

    int3 mapPos = int3(floor(ro + 0.));

    //todo comprendre wtf que ça fait ça
    float lengthRayDir = length(rd);
    float3 deltaDist = abs(lengthRayDir / rd);
    int3 rayStep = int3(sign(rd));
    float3 sideDist = (sign(rd) * (float3(mapPos) - ro) + (sign(rd) * 0.5) + 0.5) * deltaDist;
    
    bool3 mask;
    
    int i;
    for (i = 0; i < maxStep; i++)
    {
        if (voxel[mapPos] != 0) break;

        mask = lessThanEqual(sideDist.xyz, min(sideDist.yzx, sideDist.zxy));

        sideDist += float3(mask) * deltaDist;
        mapPos += int3(float3(mask)) * rayStep;
    }
    
    if (i == maxStep)
    {
        RayHit hit;
        hit.ro = ro;
        hit.rd = rd;
        hit.hasHit = false;
        return hit;
    }

    return CalculateRayHit(ro, rd, mapPos, mask, skippedDist, voxel);
}

#endif