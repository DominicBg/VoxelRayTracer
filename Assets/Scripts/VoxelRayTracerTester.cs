using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static VoxelRayTracerAPI;

public class VoxelRayTracerTester : MonoBehaviour
{
    public ComputeShader computeShader;
    public VoxelGenerator voxelGenerator;
    public Cubemap cubemap;
    public Camera mainCamera;
    public float t;
    public Material material;
    public bool isAuto;
    public RenderDebugMode renderDebugMode;


    public VoxelRayTracerSettings settings;

    LightDataComponent[] lightDataComponents;
    List<LightData> tempLightData = new List<LightData>();

    VoxelRayTracerAPI api;
    private void Start()
    {
        api = new VoxelRayTracerAPI(computeShader);
        api.SetSettings(settings);

        lightDataComponents = FindObjectsOfType<LightDataComponent>();
    }

    private void Update()
    {
        if (isAuto) t += Time.deltaTime;

        api.SetRenderDebugMode(renderDebugMode);

        //Set Camera pos
        api.SetCamera(mainCamera);
        // api.SetCameraTransform(mainCamera.transform.position, mainCamera.transform.rotation);
        //api.SetCameraFOV(mainCamera.fieldOfView);

        //Create geometry
        var voxel = voxelGenerator.Generate(t);
        api.SetOpaqueVoxelGeometry(voxel);
        
        //Add cubemap
        if(cubemap != null)
            api.SetCubeMap(cubemap);

        //Add lights
        tempLightData.Clear();
        for (int i = 0; i < lightDataComponents.Length; i++)
        {
            tempLightData.Add(lightDataComponents[i].GetLightData());
        }
        api.SetLights(tempLightData);

        //Render image!
        var texture = api.RenderToTexture(t);

        //TODO Render texture to a .mp4

        material.SetTexture("_MainTex", texture);
    }

    //public void RenderInCamera(Camera camera, float t)
    //{
    //    api = new VoxelRayTracerAPI(computeShader);
    //    api.SetSettings(settings);

    //    lightDataComponents = FindObjectsOfType<LightDataComponent>();

    //    api.SetCameraTransform(camera.transform.position, camera.transform.rotation);
    //    api.SetCameraFOV(camera.fieldOfView);
    //    //Create geometry
    //    var voxel = voxelGenerator.Generate(t);
    //    api.SetOpaqueVoxelGeometry(voxel);

    //    //Add cubemap
    //    if (cubemap != null)
    //        api.SetCubeMap(cubemap);

    //    //Add lights
    //    tempLightData.Clear();
    //    for (int i = 0; i < lightDataComponents.Length; i++)
    //    {
    //        tempLightData.Add(lightDataComponents[i].GetLightData());
    //    }
    //    api.SetLights(tempLightData);

    //    //Render image!
    //    camera.targetTexture = api.RenderToTexture(t);
    //    api.Dispose();
    //}

    void OnDestroy()
    {
        api.Dispose();
    }

    private void OnValidate()
    {
        if(Application.isPlaying && api != null)
        {
            api.SetSettings(settings);
        }
    }
}