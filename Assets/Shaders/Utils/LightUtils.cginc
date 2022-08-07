#ifndef _LightUtils
#define _LightUtils

#include "MathUtils.cginc"
#include "../VoxelRayCaster.cginc"



float3 DiffuseLight(float3 lightPos, float3 lightColor, float3 position, float3 normal)
{
    float3 ldir = normalize(lightPos - position);
    float diffuse = dot(normal, ldir);
    return lightColor * max(0.0, diffuse);
}

float3 DiffuseLight(in LightData lightData, in RayHit hit)
{
    return DiffuseLight(lightData.position, lightData.color, hit.pos, hit.normal);
}


float3 SpecularLight(float3 lightPos, float3 lightColor, float3 position, float specularStrength, float power, float3 viewDir, float3 normal)
{
    //Specular
    //float specularStrength = 0.35;
    float3 ldir = normalize(lightPos - position);
    float3 reflectDir = reflect(ldir, normal);  
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), power);
    //float spec = pow(max(dot(viewDir, reflectDir), 0.0), 8.0);
    return specularStrength * spec;  
}

float3 SpecularLight(in LightData lightData, in RayHit hit)
{
    return SpecularLight(lightData.position, lightData.color,  0.25, 4, hit.pos, hit.rd, hit.normal);
}

float3 SpecularLight(in LightData lightData, in RayHit hit, float specularStrength, float power)
{
    return SpecularLight(lightData.position, lightData.color,  specularStrength, power, hit.pos, hit.rd, hit.normal);
}


float HardShadow(float3 lightPos, float3 position, float3 normal, in Texture3D<uint> voxel)
{
    float lightDist = distance(position, lightPos);
    //float3 ldir = normalize(lightPos - position);
    float3 ldir = (lightPos - position) / lightDist;

    float shadow = 1.0;
    float umbraStrength = 0.9;
    
    RayHit shadowRay = RayCastWithVoxel(position + normal * 0.001, ldir, 240, voxel);
    if(shadowRay.dist < lightDist)
    {
        shadow = 1. - umbraStrength;
    }
    return shadow;
}

float HardShadow(in LightData lightData, in RayHit hit, in Texture3D<uint> voxel)
{
    return HardShadow(lightData.position, hit.pos, hit.normal, voxel);
}


float SoftShadow(float3 lightPos, float penumbraRadius, float3 position, float3 normal, int shadowIterations, in Texture3D<uint> voxel)
{
    float lightDist = distance(position, lightPos);
    //float3 ldir = normalize(lightData.position - position);
    float3 ldir = (lightPos - position) / lightDist;

    float shadow = 1.0;

    float lightSoftShadow = 0.15;
    float umbraStrength = 0.9;

    int shadowHits = 0;
    for(int i = 0; i < shadowIterations; i++)
    {
        float3 tempLightPos = lightPos + penumbraRadius * ShittyRandom(float(i));
        float3 templdir = normalize(tempLightPos - position);
        
        RayHit shadowRay = RayCastWithVoxel(position + normal * 0.001, templdir, 240, voxel);
        if(shadowRay.dist < lightDist)
        {
            shadowHits++;
        }
    }
    float shadowRatio = (float(shadowHits) / float(shadowIterations));
    shadow = 1. - umbraStrength * (shadowRatio * shadowRatio * shadowRatio); 
    return shadow;
}

float SoftShadow(in LightData lightData, in RayHit hit, in Settings settings, in Texture3D<uint> voxel)
{
    return SoftShadow(lightData.position, lightData.penumbraRadius, hit.pos, hit.normal, settings.shadowIterations, voxel);
}

float3 BasicLight(in LightData lightData, in RayHit hit, in Settings settings, in Texture3D<uint> voxel)
{
    //return saturate(DiffuseLight(lightData, hit) + SpecularLight(lightData, hit)) * SoftShadow(lightData, hit, settings, voxel);
    return saturate(DiffuseLight(lightData, hit) + SpecularLight(lightData, hit));
    //return SoftShadow(lightData, hit, settings, voxel);
}

/*
float Light(RayHit hit)
{
    lightPos = 0. * float3(sin(iTime), 0.0, cos(iTime));
    lightPos = float3(50, 25, 50);

    float3 ldir = normalize(lightPos - hit.pos);
    float diffuse = dot(hit.normal, ldir);
    diffuse =  max(0.0, diffuse);
    
    float lightDist = distance(hit.pos, lightPos);
    float ambient = 0.5;
    

    //Specular
    float specularStrength = 0.35;
    float3 reflectDir = reflect(ldir, hit.normal);  
    float spec = pow(max(dot(hit.rd, reflectDir), 0.0), 8.0);
    float specular = specularStrength * spec;  
    

    //shadow
    float umbraStrength = 0.5;
    
    float shadow = 1.0;
#ifdef HD    
    float lightSoftShadow = 0.15;

    int shadowHits = 0;
    for(int i = 0; i < iShadowIteration; i++)
    {
        float3 tempLightPos = lightPos + lightSoftShadow * ShittyRandom(float(i));
        float3 templdir = normalize(tempLightPos - hit.pos);
        
        RayHit shadowRay = RayCast(hit.pos + hit.normal * 0.001, templdir);
        if(shadowRay.dist < lightDist)
        {
            shadowHits++;
        }
    }
    float shadowRatio = (float(shadowHits) / float(iShadowIteration));
    shadow = 1. - umbraStrength * shadowRatio * shadowRatio * shadowRatio; 
    
#else
    RayHit shadowRay = RayCast(hit.pos + hit.normal * 0.001, ldir);
    if(shadowRay.dist < lightDist)
    {
        shadow = 1. - umbraStrength;
    }
#endif
    float lightDistStrg = lightDist/50.;
    lightDistStrg = clamp(lightDistStrg * lightDistStrg * lightDistStrg, 0.0, 1.0) * 0.5;
    
    
    float finalLightIntensity = (diffuse + specular) * shadow + ambient - lightDistStrg;
    return saturate(finalLightIntensity);
}
*/

#endif