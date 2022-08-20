using System.Collections.Generic;
using UnityEngine;

public abstract class VoxelRayTracerAPI
{
    public enum RenderDebugMode { None, Normal, ReflectedDirection, UV, Light, Blur }

    protected RenderTexture outputTexture;

    protected VoxelRayTracerSettings settings;
    //protected ComputeShader shader;
    protected ListBuffer<LightData> lightBuffer;

    protected RenderTexture voxelTexture3D;
    protected RenderTexture voxelTextureTransparent3D;
    protected RenderTexture volumetricNoise;

    protected Cubemap cubemap;
    protected Cubemap fakeCubemap;
    protected Vector3Int voxel3DSizes;
    protected Vector3Int voxelTransparent3DSizes;

    protected bool centerAtZero = true;
    protected bool useFreeCamera;
    protected bool isCameraOrtho;
    protected bool useProceduralSkybox = true;
    protected bool useVolumetricNoise;

    //Free camera Mode
    protected Vector3 cameraPos;
    protected Quaternion cameraRot;
    protected float fov = 60;

    //Unity camera Mode
    protected Camera mainCamera;

    protected RenderDebugMode debugMode;

    public unsafe VoxelRayTracerAPI()
    {
       // shader = computeShader;
        //kernelHandle = shader.FindKernel("CSMain");


        lightBuffer = new ListBuffer<LightData>("lightDatas", sizeof(LightData));
        fakeCubemap = new Cubemap(1, TextureFormat.Alpha8, false);
 
        //volumetricNoise = new RenderTexture(1, 1, 0);
        //volumetricNoise.Create();

        cubemap = fakeCubemap;
        SetMediumettings();
    }


    void EnsureComputeBuffer()
    {
        if (outputTexture == null || (outputTexture.width != settings.resolution.x || outputTexture.height != settings.resolution.y))
        {
            outputTexture = new RenderTexture(settings.resolution.x, settings.resolution.y, 0);
            outputTexture.enableRandomWrite = true;
            outputTexture.Create();
        }
    
        //shader.SetTexture(kernelHandle, "Result", outputTexture);
    }


    public void SetCamera(Camera camera)
    {
        this.mainCamera = camera;
        this.useFreeCamera = false;
        centerAtZero = false;
    }

    public void SetCameraTransform(Vector3 cameraPos, Quaternion cameraRot)
    {
        this.cameraPos = cameraPos;
        this.cameraRot = cameraRot;
        this.useFreeCamera = true;
        centerAtZero = true;
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

    public void SetVolumetricNoise(RenderTexture volumetricNoise)
    {
        this.volumetricNoise = volumetricNoise;
        useVolumetricNoise = true;
       //voxel3DSizes = new Vector3Int(voxelTexture3D.width, voxelTexture3D.height, voxelTexture3D.volumeDepth);
    }

    public void SetCubeMap(Cubemap cubemap)
    {
        this.cubemap = cubemap;
        useProceduralSkybox = false;
    }
    public void SetProceduralSkybox()
    {
        cubemap = fakeCubemap;
        useProceduralSkybox = false;
    }

    public void SetLights(List<LightData> lights)
    {
        lightBuffer.Clear();
        for (int i = 0; i < lights.Count; i++)
        {
            var light = lights[i];
            light.position = centerAtZero ? CenterAtZero(light.position) : light.position;
            lightBuffer.Add(light);
        }
    }

    protected Vector3 CenterAtZero(Vector3 pos)
    {
        pos += new Vector3(voxel3DSizes.x, 0.0f, voxel3DSizes.z) * 0.5f;
        return pos;
    }

    public abstract RenderTexture RenderToTexture(float t);


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

    protected void SetResolutionParameterInShader(ComputeShader shader)
    {
        shader.SetVector("iResolution", new Vector4(settings.resolution.x, settings.resolution.y, 1, 1));
    }

    protected void SetCameraParametersInShader(ComputeShader shader)
    {
        //If I want to port this outside of unity lol
        shader.SetBool("iUseFreeCamera", useFreeCamera);
        shader.SetBool("iCameraIsOrtho", isCameraOrtho);

        Vector3 alignedCameraPos = centerAtZero ? CenterAtZero(cameraPos) : cameraPos;

        //Free Cam
        if (useFreeCamera)
        {
            shader.SetVector("iCameraPos", alignedCameraPos);
            shader.SetVector("iCameraRot", new Vector4(cameraRot.x, cameraRot.y, cameraRot.z, cameraRot.w));
            shader.SetFloat("iCameraFOV", fov);
        }
        else
        {
            //Unity Cam
            shader.SetMatrix("iCameraToWorld", mainCamera.cameraToWorldMatrix);
            shader.SetMatrix("iCameraInverseProjection", mainCamera.projectionMatrix.inverse);
        }
    }

    protected void SetOpaqueVoxelInShader(ComputeShader shader, int kernelHandle = 0)
    {
        shader.SetTexture(kernelHandle, "voxel", voxelTexture3D);
        shader.SetVector("iVoxelSizes", new Vector4(voxel3DSizes.x, voxel3DSizes.y, voxel3DSizes.z, 0));
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
