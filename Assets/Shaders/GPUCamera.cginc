#ifndef GPUCAMERA_INCLUDED
#define GPUCAMERA_INCLUDED

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

#endif