#ifndef _LightUtils
#define _LightUtils

#include "MathUtils.cginc"
#include "../VoxelRayCaster.cginc"

#define LIGHT_TYPE_DIRECTIONAL 0
#define LIGHT_TYPE_POINT 1
#define LIGHT_TYPE_AMBIENT 2

float DiffuseLight(float3 lightDir, float3 normal)
{
    float diffuse = dot(normal, lightDir);
    return max(0.0, diffuse);
}

float3 DiffuseLight(in LightData lightData, in RayHit hit)
{
    float3 lightDir = normalize(lightData.position - hit.pos);
    return lightData.intensity * lightData.color * DiffuseLight(lightDir, hit.normal);
}

float SpecularLight(float3 lightPos, float specularStrength, float power, float3 position, float3 viewDir, float3 normal)
{
    float3 ldir = normalize(lightPos - position);
    float3 reflectDir = reflect(ldir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), power);
    return specularStrength * spec;
}

float3 SpecularLight(in LightData lightData, in RayHit hit)
{
    return lightData.intensity * lightData.color * SpecularLight(lightData.position, 0.25, 4, hit.pos, hit.rd, hit.normal);
}

float3 SpecularLight(in LightData lightData, in RayHit hit, float specularStrength, float power)
{
    return lightData.intensity * lightData.color * SpecularLight(lightData.position, specularStrength, power, hit.pos, hit.rd, hit.normal);
}


float HardShadow(float3 lightPos, float lightRadius, float3 position, float3 normal, in SceneData sceneData)
{
    float3 diff = (lightPos - position);
    float lightDistsq = dot(diff, diff);

    if (lightDistsq > lightRadius * lightRadius)
        return 1;

    float lightDist = sqrt(lightDistsq);
    float3 ldir = diff / lightDist;
    
    RayHit shadowRay = RayCast(position + normal * 0.001, ldir, sceneData);
    if (shadowRay.hasHit && shadowRay.dist < lightDist)
        return 0;

    return 1;
}

float HardShadow(in LightData lightData, in RayHit hit, in SceneData sceneData)
{
    return HardShadow(lightData.position, lightData.radius, hit.pos, hit.normal, sceneData);
}

float SoftShadow(float3 lightPos, float lightRadius, float penumbraRadius, float3 position, float3 normal, in SceneData sceneData)
{
    int shadowIterations = sceneData.settings.shadowIterations;

    float3 diff = (lightPos - position);
    float lightDistsq = dot(diff, diff);
    if (lightDistsq > lightRadius * lightRadius)
        return 0;

    float lightDist = sqrt(lightDistsq);
    float3 ldir = diff / lightDist;

    float shadowIntensity = 1.;

    int shadowHits = 0;

    shadowIterations = max(shadowIterations, 1);

    uint rngState = WangHash(uint(sceneData.seed * 1.627) + 1627);
    
    [loop]
    for (int i = 0; i < shadowIterations; i++)
    {
        //TODO implement a better random
        //float3 tempLightPos = lightPos + penumbraRadius * ShittyRandom(float(i) + sceneData.seed * 3.12777);
        float3 tempLightPos = lightPos + penumbraRadius * RandomInSphere(rngState);
        float3 templdir = normalize(tempLightPos - position);
        
        RayHit shadowRay = RayCast(position + normal * 0.001, templdir, sceneData);
        if (shadowRay.hasHit && shadowRay.dist < lightDist - penumbraRadius)
        {
            shadowHits++;
        }
    }
    float shadowRatio = (float(shadowHits) / float(shadowIterations));
    return 1 - shadowIntensity * (shadowRatio * shadowRatio * shadowRatio);
}

float SoftShadow(in LightData lightData, in RayHit hit, in SceneData sceneData)
{
    return SoftShadow(lightData.position, lightData.radius, lightData.penumbraRadius, hit.pos, hit.normal, sceneData);
}

float FadeOffIntensity(in LightData lightData, float3 position)
{
    float3 diff = position - lightData.position;
    float lightDistsq = dot(diff, diff);

    if (lightDistsq > lightData.radius * lightData.radius)
    {
        return 0;
    }

    float lightDist = sqrt(lightDistsq);

    //linear fadeoff, todo find something better
    return 1 - (lightDist / lightData.radius);
}

float FadeOffIntensity(in LightData lightData, in RayHit hit)
{
    return FadeOffIntensity(lightData, hit.pos);
}

float3 BasicLight(in LightData lightData, in RayHit hit, in SceneData sceneData)
{
    switch(lightData.type)
    {
        case LIGHT_TYPE_DIRECTIONAL:
            return lightData.intensity * lightData.color * DiffuseLight(lightData.dir, hit.normal);
        
        case LIGHT_TYPE_POINT:
            float3 diffuse = DiffuseLight(lightData, hit);
            float3 spec = SpecularLight(lightData, hit);
            //#ifdef HD
            //float shadow = (sceneData.settings.shadowIterations > 1) ? SoftShadow(lightData, hit, sceneData) : HardShadow(lightData, hit, sceneData);
            float shadow = SoftShadow(lightData, hit, sceneData);
            //#else
            //            float shadow = HardShadow(lightData, hit, sceneData);
            //#endif

            float fadeOff = FadeOffIntensity(lightData, hit);
            return (diffuse + spec) * shadow * fadeOff;

        case LIGHT_TYPE_AMBIENT:
            return lightData.intensity * lightData.color;
    }

    return 1;
}

float3 BasicLight(in SceneData sceneData, in RayHit hit)
{
    float3 colSum = 0;
    for (uint i = 0; i < sceneData.lightDatas.Length; i++)
    {
        colSum += BasicLight(sceneData.lightDatas[i], hit, sceneData);
    }
    return saturate(colSum);
}


SamplerState sampler_Trilinear_Repeat;
float SampleVolumetricNoise(float3 p, Texture3D<float> volumetricNoise)
{
    //Simple fbm sampling
    float f;
    f = 0.5000 * volumetricNoise.SampleLevel(sampler_Trilinear_Repeat, p, 0).x; p = p * 2.0;
    f += 0.2500 * volumetricNoise.SampleLevel(sampler_Trilinear_Repeat, p, 0).x; p = p * 2.0;
    f += 0.0800 * volumetricNoise.SampleLevel(sampler_Trilinear_Repeat, p, 0).x; p = p * 2.0;
    f += 0.0625 * volumetricNoise.SampleLevel(sampler_Trilinear_Repeat, p, 0).x; p = p * 2.0;
    f += 0.1250 * volumetricNoise.SampleLevel(sampler_Trilinear_Repeat, p, 0).x; p = p * 2.0;
    
    return f;
}

float4 CalculateVolumetricLight(float3 ro, float3 rd, in LightData lightData, float maxDist, in SceneData sceneData)
{
    float startDist, endDist;
    if (!RaySphereIntersection(ro, rd, lightData.position, lightData.radius, startDist, endDist))
    {
        //The ray doesn't intersect with the light radius, just skip
        return 0;
    }

    //Will be 0 if the ray starts inside
    startDist = max(startDist, 0);

    int steps = sceneData.settings.volumetricLightSteps;
    float dx = lightData.radius / float(steps);
    
    float vIntensity = lightData.volumetricIntensity;
    float4 lightSum = 0.;

    [loop]
    for (int i = 0; i < steps; i++)
    {
        float currentDist = startDist + float(i) * dx;
        
        if (currentDist > maxDist || currentDist > endDist) break;
        //if (currentDist > maxDist) break;
        
        float3 p = ro + rd * currentDist;
        p += lightData.penumbraRadius * ShittyRandom(float(i));

        float3 d = lightData.position - p;
        float lightToPosRadiusSq = dot(d, d);

        if (lightToPosRadiusSq > lightData.radius * lightData.radius)
        {
            continue;
        }
        float l = sqrt(lightToPosRadiusSq);

        //TODO do like soft shadow and raycast around the lightPos
        RayHit hit = RayCast(p, d / l, sceneData);
        if (!hit.hasHit || l < hit.dist)
        {
            float vNoise = SampleVolumetricNoise(p * 0.05 + sceneData.time * 0.05, sceneData.volumetricNoise);
            //float fadeOff = FadeOffIntensity(lightData, p);
            lightSum += float4(lightData.color, 1) * lightData.intensity * vIntensity * dx * vNoise;
            //todo try this shit *= exp(-cloud * dStep);

        }
    }
    return lightSum;
}

float4 CalculateVolumetricLight(float3 ro, float3 rd, float maxDist, in SceneData sceneData)
{
    float4 volumetricLightSum = 0;
    for (uint i = 0; i < sceneData.lightDatas.Length; i++)
    {
        if (sceneData.lightDatas[i].type == LIGHT_TYPE_POINT && sceneData.lightDatas[i].volumetricIntensity > 0 && sceneData.lightDatas[i].intensity > 0)
        {
            volumetricLightSum += CalculateVolumetricLight(ro, rd, sceneData.lightDatas[i], maxDist, sceneData);
        }
    }
    return saturate(volumetricLightSum);
}

float3 CalculateFogColor(float3 currentCol, float fogCol, float fogDensity)
{
    return lerp(currentCol, fogCol, saturate(fogDensity));
}

float CalculateFogDensity(RayHit hit, float intensity, float densityFallOff)
{
    float3 ro = hit.ro;
    float3 rd = hit.rd;
    float dist = hit.dist;
    float i = intensity;
    float d = densityFallOff;
    return (i / d) * exp(-ro.y * d) * (1.0 - exp(-dist * rd.y * d)) / rd.y;
}

#endif