using System.Collections.Generic;
using UnityEngine;

public class VoxelRayTracerAPI
{
    public enum RenderDebugMode { None, Normal, ReflectedDirection, UV, LightOnly}

    VoxelRayTracerSettings settings;
    ComputeShader shader;
    ListBuffer<LightData> lightBuffer;
    RenderTexture outputTexture;
    RenderTexture voxel3DTexture;
    Cubemap cubemap;
    Vector3 voxel3DSizes;

    int kernelHandle;

    Vector3 cameraPos;
    Quaternion cameraRot;
    float fov = 60;
    RenderDebugMode debugMode;

    public unsafe VoxelRayTracerAPI(ComputeShader computeShader)
    {
        shader = computeShader;
        kernelHandle = shader.FindKernel("CSMain");

        lightBuffer = new ListBuffer<LightData>("lightDatas", sizeof(LightData));
        //cubemap = (Cubemap)RenderSettings.skybox.mainTexture;

        SetMediumettings();
    }


    void EnsureComputeBuffer()
    {
        if (outputTexture == null || (outputTexture.width != settings.resolution.x && outputTexture.height != settings.resolution.y))
        {
            outputTexture = new RenderTexture(settings.resolution.x, settings.resolution.y, 0);
            outputTexture.enableRandomWrite = true;
            outputTexture.Create();
        }


        shader.SetVector("iResolution", new Vector4(settings.resolution.x, settings.resolution.y, 1, 1));
        shader.SetInt("iMaxSteps", settings.maxRaySteps);
        shader.SetInt("iReflectionCount", settings.reflectionCount);
        shader.SetInt("iBlurIteration", settings.blurIteration);
        shader.SetInt("iShadowIteration", settings.shadowIteration);
        shader.SetInt("iVolumetricLightSteps", settings.volumetricLightSteps);

        shader.SetTexture(kernelHandle, "Result", outputTexture);
    }

    public void SetCameraTransform(Vector3 cameraPos, Quaternion cameraRot)
    {
        this.cameraPos = cameraPos;
        this.cameraRot = cameraRot;
    }
    public void SetCameraFOV(float fov)
    {
        this.fov = fov;
    }

    public void SetOpaqueVoxelGeometry(RenderTexture voxel3DTexture)
    {
        this.voxel3DTexture = voxel3DTexture;
        voxel3DSizes = new Vector3(voxel3DTexture.width, voxel3DTexture.height, voxel3DTexture.volumeDepth);
    }

    public void SetCubeMap(Cubemap cubemap)
    {
        this.cubemap = cubemap;
    }

    public void SetLights(List<LightData> lights)
    {
        lightBuffer.Clear();
        lightBuffer.AddRange(lights);
    }

    public RenderTexture RenderToTexture(float t)
    {
        shader.SetFloat("iFOV", fov);

        shader.SetFloat("iTime", t);

        shader.SetVector("iCameraPos", cameraPos);
        shader.SetVector("iCameraRot", new Vector4(cameraRot.x, cameraRot.y, cameraRot.z, cameraRot.w));
        shader.SetFloat("iCameraFOV", fov);
        shader.SetVector("iVoxelSizes", voxel3DSizes);

        shader.SetTexture(kernelHandle, "voxel", voxel3DTexture);
        shader.SetTexture(kernelHandle, "cubemap", cubemap);

        //Debugs
        shader.SetBool("iNormalDebugView", debugMode == RenderDebugMode.Normal);
        shader.SetBool("iReflectedDirDebugView", debugMode == RenderDebugMode.ReflectedDirection);
        shader.SetBool("iUVDebugView", debugMode == RenderDebugMode.UV);
        shader.SetBool("iLightOnlyDebugView", debugMode == RenderDebugMode.LightOnly);


        lightBuffer.UpdateData(kernelHandle, shader);

        int x = settings.resolution.x / 8;
        int y = settings.resolution.y / 8;
        shader.Dispatch(kernelHandle, x, y, 1);

        return outputTexture;
    }

    public void SetSettings(in VoxelRayTracerSettings settings)
    {
        this.settings = settings;
        EnsureComputeBuffer();
    }

    public void SetHighSettings()
    {
        settings = new VoxelRayTracerSettings()
        {
            reflectionCount = 5,
            blurIteration = 5,
            shadowIteration = 5,
            maxRaySteps = 120,
            volumetricLightSteps = 450,
            resolution = new Vector2Int(1050, 100)

        };
        EnsureComputeBuffer();
    }
    public void SetMediumettings()
    {
        settings = new VoxelRayTracerSettings()
        {
            reflectionCount = 2,
            blurIteration = 1,
            shadowIteration = 1,
            maxRaySteps = 120,
            volumetricLightSteps = 125,
            resolution = new Vector2Int(250, 250)
        };
        EnsureComputeBuffer();
    }

    public void Dispose()
    {
        lightBuffer.Dispose();
    }

    public void SetRenderDebugMode(RenderDebugMode debugMode)
    {
        this.debugMode = debugMode;
    }
}

[System.Serializable]
public struct VoxelRayTracerSettings
{
    public int reflectionCount;
    public int blurIteration;
    public int shadowIteration;
    public int maxRaySteps;
    public int volumetricLightSteps;

    public Vector2Int resolution;
}


public enum VoxelLightType : int { Directional, Point, Ambient }

[System.Serializable]
public struct LightData //Must reflect LightData in VoxelRayTracerDatas
{
    public VoxelLightType lightType;
    public Vector3 position;
    public Vector3 color;
    public Vector3 direction;
    public float intensity;
    public float volumetricIntensity;
    public float radius;

    //https://en.wikipedia.org/wiki/Umbra,_penumbra_and_antumbra
    public float penumbraRadius;
};
