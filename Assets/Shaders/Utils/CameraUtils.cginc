
#ifndef _CameraUtils
#define _CameraUtils

#include "MathUtils.cginc"


float CalculateAspectRatio(float2 resolution)
{
    return resolution.x / resolution.y;  //assuming width > height
}

void CreateCameraRay(float2 uv, float4x4 cameraToWorld, float4x4 cameraInverseProjection, out float3 ro, out float3 rd)
{
    //taken from http://three-eyed-games.com/2018/05/03/gpu-ray-tracing-in-unity-part-1/
    // Transform the camera origin to world space
    ro = mul(cameraToWorld, float4(0.0f, 0.0f, 0.0f, 1.0f)).xyz;

    // Invert the perspective projection of the view-space position
    rd = mul(cameraInverseProjection, float4(uv, 0.0f, 1.0f)).xyz;
    // Transform the direction from camera to world space and normalize
    rd = mul(cameraToWorld, float4(rd, 0.0f)).xyz;
    rd = normalize(rd);
}

void PerspectiveCam(float3 camPos, float4 camRot, float2 uv, float fov, float aspectRatio, out float3 ro, out float3 rd)
{
    //float imageAspectRatio = resolution.x / resolution.y;  //assuming width > height
    uv.x = uv.x * tan(fov / 2 * PI / 180) * aspectRatio;
    uv.y = uv.y * tan(fov / 2 * PI / 180);

    //Add FOV
    float3 forward = normalize(float3(uv.x, uv.y, 1.0));
    ro = camPos;
    rd = qmul(camRot, forward);
}
void OrthographicCam(float3 camPos, float4 camRot, float2 uv, float size, float aspectRatio, out float3 ro, out float3 rd)
{
    //float imageAspectRatio = resolution.x / resolution.y;  //assuming width > height
    uv.x = uv.x * aspectRatio;
    uv.y = uv.y;

    //Add FOV
    //float3 forward = normalize(float3(uv.x, uv.y, 1.0));
    ro = camPos + (uv.x * qmul(camRot, float3(1, 0, 0)) * size) + (uv.y * qmul(camRot, float3(0, 1, 0)) * size);
    rd = qmul(camRot, float3(0, 0, 1));
}


#endif