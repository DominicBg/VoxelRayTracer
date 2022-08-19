using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FixedVoxelRayTracerAPI : VoxelRayTracerAPI
{
    ComputeShader shader;
    int kernelHandle;

    public unsafe FixedVoxelRayTracerAPI(ComputeShader computeShader) : base()
    {
        shader = computeShader;
        kernelHandle = shader.FindKernel("CSMain");
    }

    public override RenderTexture RenderToTexture(float t)
    {
        shader.SetFloat("iTime", t);

        ////If I want to port this outside of unity lol
        //shader.SetBool("iUseFreeCamera", useFreeCamera);
        //shader.SetBool("iCameraIsOrtho", isCameraOrtho);

        //Vector3 alignedCameraPos = centerAtZero ? CenterAtZero(cameraPos) : cameraPos;

        ////Free Cam
        //if (useFreeCamera)
        //{
        //    shader.SetVector("iCameraPos", alignedCameraPos);
        //    shader.SetVector("iCameraRot", new Vector4(cameraRot.x, cameraRot.y, cameraRot.z, cameraRot.w));
        //    shader.SetFloat("iCameraFOV", fov);
        //}
        //else
        //{
        //    //Unity Cam
        //    shader.SetMatrix("iCameraToWorld", mainCamera.cameraToWorldMatrix);
        //    shader.SetMatrix("iCameraInverseProjection", mainCamera.projectionMatrix.inverse);
        //}

        SetCameraParametersInShader(shader);
        SetResolutionParameterInShader(shader);

        //shader.SetVector("iResolution", new Vector4(settings.resolution.x, settings.resolution.y, 1, 1));
        shader.SetInt("iReflectionCount", settings.reflectionCount);
        shader.SetInt("iBlurIteration", settings.blurIteration);
        shader.SetInt("iShadowIteration", settings.shadowIteration);
        shader.SetInt("iVolumetricLightSteps", settings.volumetricLightSteps);

        ////Voxel opaque geometry
        //shader.SetTexture(kernelHandle, "voxel", voxelTexture3D);
        //shader.SetVector("iVoxelSizes", new Vector4(voxel3DSizes.x, voxel3DSizes.y, voxel3DSizes.z, 0));
        SetOpaqueVoxelInShader(shader, kernelHandle);

        //Voxel transparent geometry
        if (voxelTextureTransparent3D != null)
        {
            shader.SetTexture(kernelHandle, "voxelTransparent", voxelTextureTransparent3D);
            shader.SetVector("iVoxelTransparentSizes", new Vector4(voxelTransparent3DSizes.x, voxelTransparent3DSizes.y, voxelTransparent3DSizes.z, 0));
        }

        //Volumetric Noise
        shader.SetTexture(kernelHandle, "volumetricNoise", volumetricNoise);
        shader.SetBool("iUseVolumetricNoise", useVolumetricNoise);


        //We multiply by two because we have a buffer if some ray hits does perfeclty 2 steps by diagonals 
        //https://medium.com/geekculture/dda-line-drawing-algorithm-be9f069921cf
        shader.SetInt("iMaxSteps", (int)voxelTransparent3DSizes.magnitude * 2);

        //Skyboxes
        shader.SetTexture(kernelHandle, "cubemap", cubemap);
        shader.SetBool("iUseProceduralSkyBox", useProceduralSkybox);


        //Debugs
        shader.SetBool("iNormalDebugView", debugMode == RenderDebugMode.Normal);
        shader.SetBool("iReflectedDirDebugView", debugMode == RenderDebugMode.ReflectedDirection);
        shader.SetBool("iUVDebugView", debugMode == RenderDebugMode.UV);
        shader.SetBool("iLightOnlyDebugView", debugMode == RenderDebugMode.Light);
        shader.SetBool("iBlurDebugView", debugMode == RenderDebugMode.Blur);

        shader.SetTexture(kernelHandle, "Result", outputTexture);

        lightBuffer.UpdateData(kernelHandle, shader);

        int x = settings.resolution.x / 8;
        int y = settings.resolution.y / 8;
        shader.Dispatch(kernelHandle, x, y, 1);

        return outputTexture;
    }

}