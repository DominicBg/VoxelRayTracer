using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProgressiveVoxelRayTracerAPI : VoxelRayTracerAPI
{
    ComputeShader cameraRayCalculator;
    ComputeShader singleRayCaster;

    RenderTexture rayOrigin;
    RenderTexture rayDirection;

    RenderTexture hitPositionDistance;
    RenderTexture hitNormal;

    int kernelHandle1;
    int kernelHandle2;

    public ProgressiveVoxelRayTracerAPI(ComputeShader cameraRayCalculator, ComputeShader singleRayCaster) : base()
    {
        this.cameraRayCalculator = cameraRayCalculator;
        this.singleRayCaster = singleRayCaster;

        kernelHandle1 = cameraRayCalculator.FindKernel("CSMain");
        kernelHandle2 = singleRayCaster.FindKernel("CSMain");
    }


    void EnsureTextures()
    {
        EnsureTexture(ref rayOrigin, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte
        EnsureTexture(ref rayDirection, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte

        EnsureTexture(ref hitPositionDistance, settings.resolution, RenderTextureFormat.ARGBFloat);
        EnsureTexture(ref hitNormal, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte
    }

    void EnsureTexture(ref RenderTexture renderTexture, Vector2Int resolution, RenderTextureFormat textureFormat)
    {
        if (renderTexture == null || renderTexture.width != resolution.x || renderTexture.height != resolution.y)
        {
            renderTexture = new RenderTexture(resolution.x, resolution.y, 0, textureFormat);
            renderTexture.enableRandomWrite = true;
            renderTexture.Create();
        }
    }

    void PrepareFirstRays()
    {
        SetCameraParametersInShader(cameraRayCalculator);
        SetResolutionParameterInShader(cameraRayCalculator);

        cameraRayCalculator.SetTexture(kernelHandle1, "OutputRayOrigin", rayOrigin);
        cameraRayCalculator.SetTexture(kernelHandle1, "OutputRayDirection", rayDirection);

        int x = settings.resolution.x / 8;
        int y = settings.resolution.y / 8;
        cameraRayCalculator.Dispatch(kernelHandle1, x, y, 1);
    }

    void CastRays()
    {
        SetOpaqueVoxelInShader(singleRayCaster, 0);

        singleRayCaster.SetTexture(kernelHandle2, "InputRayOrigin", rayOrigin);
        singleRayCaster.SetTexture(kernelHandle2, "InputRayDirection", rayDirection);

        singleRayCaster.SetTexture(kernelHandle2, "OutputHitPositionDistance", hitPositionDistance);
        singleRayCaster.SetTexture(kernelHandle2, "OutputHitNormal", hitNormal);

        int x = settings.resolution.x / 8;
        int y = settings.resolution.y / 8;
        singleRayCaster.Dispatch(kernelHandle2, x, y, 1);
    }

    void CalculatePixelColors()
    {

    }

    void CalculateRayBounces()
    {

    }


    public override RenderTexture RenderToTexture(float t)
    {
        EnsureTextures();
        PrepareFirstRays();

        for (int i = 0; i < settings.reflectionCount; i++)
        {
            CastRays();
            CalculatePixelColors();

            if(i != settings.reflectionCount - 1)
            {
                CalculateRayBounces();
            }
        }

        //TODO changes to real pixels
        return hitNormal;
    }
}
