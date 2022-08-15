using System.Collections.Generic;
using UnityEngine;

public class VoxelRayTracerAPI
{
    public enum RenderDebugMode { None, Normal, ReflectedDirection, UV, LightOnly }

    VoxelRayTracerSettings settings;
    ComputeShader shader;
    ListBuffer<LightData> lightBuffer;
    RenderTexture outputTexture;

    RenderTexture voxelTexture3D;
    RenderTexture voxelTextureTransparent3D;

    Cubemap cubemap;
    Vector3Int voxel3DSizes;
    Vector3Int voxelTransparent3DSizes;

    int kernelHandle;


    bool useFreeCamera;
    bool isCameraOrtho;

    //Free camera Mode
    Vector3 cameraPos;
    Quaternion cameraRot;
    float fov = 60;

    //Unity camera Mode
    Camera mainCamera;

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
        if (outputTexture == null || (outputTexture.width != settings.resolution.x && outputTexture.height != settings.resolution.y))
        {
            outputTexture = new RenderTexture(settings.resolution.x, settings.resolution.y, 0);
            outputTexture.enableRandomWrite = true;
            outputTexture.Create();
        }

        shader.SetVector("iResolution", new Vector4(settings.resolution.x, settings.resolution.y, 1, 1));

        //shader.SetInt("iMaxSteps", settings.maxRaySteps);
        shader.SetInt("iReflectionCount", settings.reflectionCount);
        shader.SetInt("iBlurIteration", settings.blurIteration);
        shader.SetInt("iShadowIteration", settings.shadowIteration);
        shader.SetInt("iVolumetricLightSteps", settings.volumetricLightSteps);

        shader.SetTexture(kernelHandle, "Result", outputTexture);
    }


    public void SetCamera(Camera camera)
    {
        this.mainCamera = camera;
        this.useFreeCamera = false;
    }

    public void SetCameraTransform(Vector3 cameraPos, Quaternion cameraRot)
    {
        this.cameraPos = cameraPos;
        this.cameraRot = cameraRot;
        this.useFreeCamera = true;

    }
    public void SetCameraFOV(float fov)
    {
        this.fov = fov;
    }

    public void SetCameraOrtho()
    {
        isCameraOrtho = true;
    }

    public void SetCameraPerspective()
    {
        isCameraOrtho = false;
    }

    public void SetOpaqueVoxelGeometry(RenderTexture voxelTexture3D)
    {
        this.voxelTexture3D = voxelTexture3D;
        voxel3DSizes = new Vector3Int(voxelTexture3D.width, voxelTexture3D.height, voxelTexture3D.volumeDepth);
    }

    public void SetTransparentVoxelGeometry(RenderTexture voxelTextureTransparent3D)
    {
        this.voxelTextureTransparent3D = voxelTextureTransparent3D;
        voxelTransparent3DSizes = new Vector3Int(voxelTextureTransparent3D.width, voxelTextureTransparent3D.height, voxelTextureTransparent3D.volumeDepth);
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
        shader.SetFloat("iTime", t);

        //If I want to port this outside of unity lol
        shader.SetBool("iUseFreeCamera", useFreeCamera);
        shader.SetBool("iCameraIsOrtho", isCameraOrtho);

        //Free Cam
        if (useFreeCamera)
        {
            shader.SetVector("iCameraPos", cameraPos);
            shader.SetVector("iCameraRot", new Vector4(cameraRot.x, cameraRot.y, cameraRot.z, cameraRot.w));
            shader.SetFloat("iCameraFOV", fov);
        }
        else
        {
            //Unity Cam
            shader.SetMatrix("iCameraToWorld", mainCamera.cameraToWorldMatrix);
            shader.SetMatrix("iCameraInverseProjection", mainCamera.projectionMatrix.inverse);
        }



        shader.SetTexture(kernelHandle, "voxel", voxelTexture3D);
        shader.SetVector("iVoxelSizes", new Vector4(voxel3DSizes.x, voxel3DSizes.y, voxel3DSizes.z, 0));

        if(voxelTextureTransparent3D != null)
        {
            shader.SetTexture(kernelHandle, "voxelTransparent", voxelTextureTransparent3D);
            shader.SetVector("iVoxelTransparentSizes", new Vector4(voxelTransparent3DSizes.x, voxelTransparent3DSizes.y, voxelTransparent3DSizes.z, 0));
        }

        //We multiply by two because we have a buffer if some ray hits does perfeclty 2 steps by diagonals 
        //https://medium.com/geekculture/dda-line-drawing-algorithm-be9f069921cf
        shader.SetInt("iMaxSteps", (int)voxelTransparent3DSizes.magnitude * 2);

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
    //public int maxRaySteps;
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
