using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VoxelRayTracerTester : MonoBehaviour
{
    public ComputeShader computeShader;
    public VoxelGenerator voxelGenerator;
    public Cubemap cubemap;
    public Camera mainCamera;
    public float t;
    public Material material;
    public bool isAuto;

    public VoxelRayTracerSettings settings;

    VoxelRayTracerAPI api;
    private void Start()
    {
        api = new VoxelRayTracerAPI(computeShader);
        api.SetSettings(settings);
    }

    private void Update()
    {
        if (isAuto) t += Time.deltaTime;

        api.SetCameraTransform(mainCamera.transform.position, mainCamera.transform.rotation);
        api.SetCameraFOV(mainCamera.fieldOfView);

        var voxel = voxelGenerator.Generate(new Vector3Int(100, 100, 100), t);
        api.SetOpaqueVoxelGeometry(voxel);
        
        if(cubemap != null)
            api.SetCubeMap(cubemap);

        var texture = api.RenderToTexture(t);

        //Render texture to a .mp4

        material.SetTexture("_MainTex", texture);
    }

    private void OnValidate()
    {
        if(Application.isPlaying)
        {
            api.SetSettings(settings);
        }
    }



}