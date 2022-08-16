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
    public bool useFreeCamera;
    public bool useOrthoCamera;

    public VoxelRayTracerSettings settings;

    public LightDataComponent[] lightDataComponents;
    List<LightData> tempLightData = new List<LightData>();

    VoxelRayTracerAPI api;

    [Header("Exporter")]
    public string exportFolder = "Renders";
    public float exporterStartTime = 0;
    public float exporterEndTime = 1;
    public int exporterFPS = 30;

    private void Start()
    {
        Init();
    }

    public void Init()
    {
        api = new VoxelRayTracerAPI(computeShader);
        api.SetSettings(settings);

        lightDataComponents = FindObjectsOfType<LightDataComponent>();
    }

    private void Update()
    {
        if (isAuto) t += Time.deltaTime;

        var texture = RenderImage(t);
        material.SetTexture("_MainTex", texture);
    }

    

    RenderTexture RenderImage(float t)
    {
        api.SetRenderDebugMode(renderDebugMode);

        //Set Camera pos
        if (useFreeCamera)
        {
            api.SetCameraTransform(mainCamera.transform.position, mainCamera.transform.rotation);
        }
        else
        {
            api.SetCamera(mainCamera);
        }

        if (useOrthoCamera)
        {
            api.SetCameraOrtho();
            api.SetCameraFOV(mainCamera.orthographicSize);
        }
        else
        {
            api.SetCameraPerspective();
            api.SetCameraFOV(mainCamera.fieldOfView);
        }


        //Create geometry
        var voxel = voxelGenerator.Generate(t);
        api.SetOpaqueVoxelGeometry(voxel);

        if (voxelGenerator.voxelGeneratorShaderTransparent != null)
        {
            var voxelTr = voxelGenerator.GenerateTransparent(t);
            api.SetTransparentVoxelGeometry(voxelTr);
        }

        //Add cubemap
        if (cubemap != null)
            api.SetCubeMap(cubemap);

        //Add lights
        tempLightData.Clear();
        for (int i = 0; i < lightDataComponents.Length; i++)
        {
            tempLightData.Add(lightDataComponents[i].GetLightData());
        }
        api.SetLights(tempLightData);

        //Render image!
        return api.RenderToTexture(t);
    }

    void OnDestroy()
    {
        api.Dispose();
    }

    private void OnValidate()
    {
        if (Application.isPlaying && api != null)
        {
            api.SetSettings(settings);
        }
    }

#if UNITY_EDITOR

    [ContextMenu("Save image")]
    public void SavePicture()
    {
        Init();

        SaveTexture(RenderImage(0), settings.resolution, "0");

        api.Dispose();
    }

    [ContextMenu("Export images")]
    public void ExportImages()
    {
        Init();

        float frameDuration = 1f / exporterFPS;
        int frameCount = (int)((exporterEndTime - exporterStartTime) * exporterFPS);
        int frameNameMaxDigit = (int)Mathf.Log10(frameCount) + 1;

        //Debug.Log("number digit " + frameNameMaxDigit);

        System.Text.StringBuilder strBuilder = new System.Text.StringBuilder();

        for (int i = 0; i < frameCount; i++)
        {
            strBuilder.Clear();

            int frameNameDigit = (int)Mathf.Max(Mathf.Log10(i), 0) + 1;
            int missingZeroes = frameNameMaxDigit - frameNameDigit;

            //Debug.Log($"index {i} have {missingZeroes} missing zeroes");
            for (int j = 0; j < missingZeroes; j++)
            {
                strBuilder.Append('0');
            }
            strBuilder.Append(i);

            //Debug.Log($"index {i} name is {strBuilder}");


            float t = exporterStartTime + i * frameDuration;
            SaveTexture(RenderImage(t), settings.resolution, strBuilder.ToString());
        }
       
        api.Dispose();
    }

    Texture2D ToTexture2D(RenderTexture renderTexture, Vector2Int resolution)
    {
        Texture2D tex = new Texture2D(resolution.x, resolution.y, TextureFormat.RGB24, false);
        RenderTexture.active = renderTexture;
        tex.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0);
        tex.Apply();
        return tex;
    }
    public void SaveTexture(RenderTexture renderTexture, Vector2Int resolution, string i)
    {
        byte[] bytes = ToTexture2D(renderTexture, resolution).EncodeToPNG();
        string path = Application.dataPath + "/" + exportFolder;

        if(!System.IO.Directory.Exists(path))
        {
            System.IO.Directory.CreateDirectory(path);
        }
        string filePath = path + "/SavedScreen_ " + i + ".png";
        System.IO.File.WriteAllBytes(filePath, bytes);
        Debug.Log("Saved file at " + filePath);
        //AssetDatabase.
    }
#endif
}