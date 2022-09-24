using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ProgressiveVoxelRayTracerAPI : VoxelRayTracerAPI
{
    ComputeShader cameraRayCalculator;
    ComputeShader rayCaster;
    ComputeShader calculatePixelColor;
    ComputeShader bounceRay;
    ComputeShader rollingAverage;
    ComputeShader denoiser;

    RenderTexture rayOrigin;
    RenderTexture rayDirection;

    RenderTexture hitPositionDistance;
    RenderTexture hitMaterialID;
    RenderTexture hitNormalHasHit;

    RenderTexture firstHitMaterialID;
    RenderTexture firstHitNormalHasHit;
    RenderTexture firstHitPositionDistance;

    RenderTexture frameSurfaceColor;
    RenderTexture frameColor;

    RenderTexture outputTextureDenoised;

    int frameCount;
    float previousT;
    Vector3 previousCamPos;
    Quaternion previousCamRot;

    public int rayPerFrame = 1;
    public bool denoise = true;

    public ProgressiveVoxelRayTracerAPI(ComputeShader cameraRayCalculator, ComputeShader rayCaster, ComputeShader calculatePixelColor, ComputeShader bounceRay, ComputeShader rollingAverage, ComputeShader denoiser) : base()
    {
        this.cameraRayCalculator = cameraRayCalculator;
        this.rayCaster = rayCaster;
        this.calculatePixelColor = calculatePixelColor;
        this.bounceRay = bounceRay;
        this.rollingAverage = rollingAverage;
        this.denoiser = denoiser;
    }

    public override void OnParameterChanged()
    {
        base.OnParameterChanged();
        frameCount = 0;
    }

    void EnsureTextures()
    {
        EnsureTexture(ref rayOrigin, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte
        EnsureTexture(ref rayDirection, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte

        EnsureTexture(ref hitPositionDistance, settings.resolution, RenderTextureFormat.ARGBFloat);
        EnsureTexture(ref hitNormalHasHit, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte

        EnsureTexture(ref hitMaterialID, settings.resolution, RenderTextureFormat.RInt); 

        //First hits
        EnsureTexture(ref firstHitPositionDistance, settings.resolution, RenderTextureFormat.ARGBFloat); 
        EnsureTexture(ref firstHitNormalHasHit, settings.resolution, RenderTextureFormat.ARGBFloat); //one useless byte
        EnsureTexture(ref firstHitMaterialID, settings.resolution, RenderTextureFormat.RInt); 

        EnsureTexture(ref frameSurfaceColor, settings.resolution, RenderTextureFormat.ARGBFloat);
        EnsureTexture(ref frameColor, settings.resolution, RenderTextureFormat.ARGBFloat);

        EnsureTexture(ref outputTexture, settings.resolution, RenderTextureFormat.ARGBFloat);
        EnsureTexture(ref outputTextureDenoised, settings.resolution, RenderTextureFormat.ARGBFloat);
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

        cameraRayCalculator.SetTexture(0, "OutRayOrigin", rayOrigin);
        cameraRayCalculator.SetTexture(0, "OutRayDirection", rayDirection);

        cameraRayCalculator.SetInt("frameCount", frameCount); //used for seed

        cameraRayCalculator.SetFloat("dofFocalLength", depthOfFieldFocalLength);
        cameraRayCalculator.SetFloat("dofBlurAmount", depthOfFieldBlurAmount);


        Dispatch(cameraRayCalculator);
    }

    void CastRays(int reflectionCount)
    {
        SetOpaqueVoxelInShader(rayCaster);

        rayCaster.SetTexture(0, "InRayOrigin", rayOrigin);
        rayCaster.SetTexture(0, "InRayDirection", rayDirection);

        rayCaster.SetTexture(0, "OutHitPositionDistance", hitPositionDistance);

        rayCaster.SetTexture(0, "OutHitNormalHasHit", hitNormalHasHit);
        rayCaster.SetTexture(0, "OutHitMaterialID", hitMaterialID);

        rayCaster.SetInt("reflectionCount", reflectionCount);

        Dispatch(rayCaster);
    }

    void CalculateFrameColors(float t, int reflectionCount)
    {
        SetOpaqueVoxelInShader(calculatePixelColor);
        SetResolutionParameterInShader(calculatePixelColor);
        SetVolumetricNoise(calculatePixelColor);

        lightBuffer.UpdateData(0, calculatePixelColor);

        calculatePixelColor.SetTexture(0, "InRayOrigin", rayOrigin);
        calculatePixelColor.SetTexture(0, "InRayDirection", rayDirection);

        calculatePixelColor.SetTexture(0, "InHitPositionDistance", hitPositionDistance);

        calculatePixelColor.SetTexture(0, "InOutHitNormalHasHit", hitNormalHasHit);
        calculatePixelColor.SetTexture(0, "InHitMaterialID", hitMaterialID);

        calculatePixelColor.SetTexture(0, "OutSurfaceColor", frameSurfaceColor);
        calculatePixelColor.SetTexture(0, "OutFrameColor", frameColor);

        calculatePixelColor.SetInt("frameCount", frameCount); //used for seed
        calculatePixelColor.SetInt("reflectionCount", reflectionCount);
        calculatePixelColor.SetFloat("time", t);

        Dispatch(calculatePixelColor);
    }

    void CalculateRayBounces()
    {
        SetOpaqueVoxelInShader(bounceRay);

        bounceRay.SetTexture(0, "InHitPositionDistance", hitPositionDistance);

        bounceRay.SetTexture(0, "InHitNormal", hitNormalHasHit);
        bounceRay.SetTexture(0, "InHitMaterialID", hitMaterialID);

        bounceRay.SetTexture(0, "InOutRayOrigin", rayOrigin);
        bounceRay.SetTexture(0, "InOutRayDirection", rayDirection);

        bounceRay.SetInt("frameCount", frameCount); //used for seed

        Dispatch(bounceRay);
    }

    void ComputeRollingAverage()
    {
        rollingAverage.SetInt("frameCount", frameCount);
        rollingAverage.SetTexture(0, "InFrameColor", frameColor);
        rollingAverage.SetTexture(0, "InOutColorAverage", outputTexture);
        Dispatch(rollingAverage);
    }

    void Denoise()
    {
        SetResolutionParameterInShader(denoiser);
        denoiser.SetFloat("threshold", 0.1f);

        denoiser.SetTexture(0, "InHitPositionDistance", firstHitPositionDistance);
        denoiser.SetTexture(0, "InHitNormalHasHit", firstHitNormalHasHit);
        denoiser.SetTexture(0, "InHitMaterialID", firstHitMaterialID);

        denoiser.SetTexture(0, "InColor", outputTexture);
        denoiser.SetTexture(0, "OutColorDenoised", outputTextureDenoised);
        Dispatch(denoiser);
    }

    void Dispatch(ComputeShader computeShader)
    {
        int x = settings.resolution.x / 8;
        int y = settings.resolution.y / 8;
        computeShader.Dispatch(0, x + 1, y + 1, 1);
    }


    public override RenderTexture RenderToTexture(float t)
    {
        if(previousCamPos != cameraPos || previousCamRot != cameraRot || t != previousT || Input.GetKey(KeyCode.Space))
        {
            frameCount = 0;
            previousCamPos = cameraPos;
            previousCamRot = cameraRot;
            previousT = t;
        }

        EnsureTextures();

        for (int i = 0; i < rayPerFrame; i++)
        {
            PrepareFirstRays();

            for (int reflection = 0; reflection < settings.reflectionCount; reflection++)
            {
                CastRays(reflection);

                if (reflection == 0 && frameCount == 0)
                {
                    Graphics.Blit(hitPositionDistance, firstHitPositionDistance);
                    Graphics.Blit(hitNormalHasHit, firstHitNormalHasHit);
                    Graphics.Blit(hitMaterialID, firstHitMaterialID);
                }

                CalculateFrameColors(t, reflection);

                if (reflection != settings.reflectionCount - 1)
                {
                    CalculateRayBounces();
                }
            }

            ComputeRollingAverage();
            frameCount++;
        }

        if(denoise)
        {
            Denoise();
            return outputTextureDenoised;
        }

        return outputTexture;
    }
}
