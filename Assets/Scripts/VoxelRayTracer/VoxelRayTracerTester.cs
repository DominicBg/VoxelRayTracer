using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using static VoxelRayTracerAPI;

public class VoxelRayTracerTester : MonoBehaviour
{
    public static VoxelRayTracerTester Instance { get; private set; }

    public ComputeShader computeShader;

    public VoxelGenerator voxelGenerator;
    public Image image;
    public Canvas canvas;
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
    public VoxelRayTracerSettings exporterSettings;

    private void Start()
    {
        Instance = this;
        Init();
    }

    public void Init()
    {
        api = new VoxelRayTracerAPI(computeShader);
        api.SetSettings(settings);
        lightDataComponents = FindObjectsOfType<LightDataComponent>();
    }

    public RenderTexture RenderImage(float t)
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
        api.SetSettings(exporterSettings);

        SaveTexture(RenderImage(0), settings.resolution, "0");

        api.Dispose();
    }

    void GetExportData(out float frameDuration, out int frameCount, out int frameNameMaxDigit)
    {
        frameDuration = 1f / exporterFPS;
        frameCount = (int)((exporterEndTime - exporterStartTime) * exporterFPS);
        frameNameMaxDigit = (int)Mathf.Log10(frameCount) + 1;
    }

    [ContextMenu("Export images")]
    public void ExportImages()
    {
        Init();

        api.SetSettings(exporterSettings);

        GetExportData(out float frameDuration, out int frameCount, out int frameNameMaxDigit);

        System.Text.StringBuilder strBuilder = new System.Text.StringBuilder();

        for (int i = 0; i < frameCount; i++)
        {
            strBuilder.Clear();

            int frameNameDigit = (int)Mathf.Max(Mathf.Log10(i), 0) + 1;
            int missingZeroes = frameNameMaxDigit - frameNameDigit;

            for (int j = 0; j < missingZeroes; j++)
            {
                strBuilder.Append('0');
            }
            strBuilder.Append(i);

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


    string GetExportPath()
    {
        return Application.dataPath + "/" + exportFolder;
    }
    public void SaveTexture(RenderTexture renderTexture, Vector2Int resolution, string i)
    {
        byte[] bytes = ToTexture2D(renderTexture, resolution).EncodeToPNG();
        string path = GetExportPath() + "/Screenshots";

        if(!System.IO.Directory.Exists(path))
        {
            System.IO.Directory.CreateDirectory(path);
        }
        string filePath = path + "/img" + i + ".png";
        System.IO.File.WriteAllBytes(filePath, bytes);
        Debug.Log("Saved file at " + filePath);
    }


    [ContextMenu("Export images and Save video")]
    public void ExportAndSaveVideo()
    {
        string ffmpegPath = GetExportPath() + "/ffmpeg.exe";
        if (!System.IO.File.Exists(ffmpegPath))
        {
            Debug.LogError($"Unable to find ffmpeg at path {ffmpegPath}");
            return;
        }

        ExportImages();
        SaveVideo();
    }

    [ContextMenu("Save video")]
    public void SaveVideo()
    {
        string ffmpegPath = GetExportPath() + "/ffmpeg.exe";
        if (!System.IO.File.Exists(ffmpegPath))
        {
            Debug.LogError($"Unable to find ffmpeg at path {ffmpegPath}");
            return;
        }

        GetExportData(out float _, out int _, out int frameNameMaxDigit);
        string outputname = "Render";
        string outputPath = $"{GetExportPath()}/{outputname}.mp4";
        string args = $"-framerate  {exporterFPS} -i \"{GetExportPath()}/Screenshots/img%0{frameNameMaxDigit}d.png\" -q 1 \"{outputPath}\"";
        System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo(ffmpegPath, args);

        startInfo.CreateNoWindow = true;
        startInfo.UseShellExecute = false;
        startInfo.RedirectStandardOutput = true;
        startInfo.RedirectStandardError = true;

        try
        {
            using (System.Diagnostics.Process process = System.Diagnostics.Process.Start(startInfo))
            {
                Debug.Log("Starting the process");

                Debug.Log(process.StandardOutput.ReadToEnd());
                Debug.LogError(process.StandardError.ReadToEnd());
                process.WaitForExit();
            }
        }
        catch (System.Exception ex)
        {
            Debug.LogError(ex.Message);
        }
        Debug.Log($"Video rendered at {outputPath}");
    }
#endif
}