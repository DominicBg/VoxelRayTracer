using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections.LowLevel.Unsafe;
using UnityEditor;
using UnityEngine;

public class VoxelRayTracerEditorView : MonoBehaviour
{
    public VoxelGenerator generator;
    public VoxelRayTracerTester rayTracer;

    //private unsafe void OnDrawGizmosSelected()
    //{
    //    var texture = generator.Generate(1);

    //    rayTracer.RenderInCamera(SceneView.currentDrawingSceneView.camera, 0);
    //}

    //private unsafe void OnDrawGizmosSelected()
    //{
    //    if (generator == null)
    //        return;


    //    var texture = generator.Generate(1);
    //    Vector3Int resolutions = generator.resolution;

    ////exture.GetNativeTexturePtr

    //    Texture3D text3D = new Texture3D(resolutions.x, resolutions.y, resolutions.z, );
    //    //Texture3D text3D = Texture3D.CreateExternalTexture(resolutions.x, resolutions.y, resolutions.z, TextureFormat.R16, false, texture.GetNativeTexturePtr());

    //    Graphics.CopyTexture(texture, text3D);

    //    //texture.ptr
    //   // var colors = texture.colorBuffer;
    //    // texture.Create();

    //    //IntPtr ptr = texture.GetNativeTexturePtr();
    //    //IntPtr ptr = colors.GetNativeRenderBufferPtr();

    //    // texture.GetNativeTexturePtr

    //    for (int z = 0; z < resolutions.z; z++)
    //    {
    //        for (int y = 0; y < resolutions.y; y++)
    //        {
    //            for (int x = 0; x < resolutions.x; x++)
    //            {
    //                int index = z * resolutions.x * resolutions.y + y * resolutions.x + x;
    //                //int index = y * resolutions.x * resolutions.z + z * resolutions.x + x;
    //                // int value = UnsafeUtility.ReadArrayElement<int>(ptr.ToPointer(), index);

    //                //if (value == 0)
    //                //    continue;
    //                if (text3D.GetPixel(x, y, z).r == 0)
    //                    continue;

    //                Gizmos.color = new Color((float)x / resolutions.x, (float)y / resolutions.y, (float)z / resolutions.z);
    //                Gizmos.DrawCube(new Vector3(x, y, z), Vector3.one * 0.95f);
    //                // if (colors[x, y, z];
    //            }
    //        }
    //    }
    //}

    //RenderTexture Copy3DSliceToRenderTexture(RenderTexture source, int layer)
    //{
    //    RenderTexture render = new RenderTexture(voxelSize, voxelSize, 0, RenderTextureFormat.ARGB32);
    //    render.dimension = UnityEngine.Rendering.TextureDimension.Tex2D;
    //    render.enableRandomWrite = true;
    //    render.wrapMode = TextureWrapMode.Clamp;
    //    render.Create();


    //    return render;
    //}

    //Texture3D ConvertFromRenderTexture(Vector3Int resolutions, RenderTexture rt)
    //{
    //    Texture3D output = new Texture3D(resolutions.x, resolutions.y, resolutions.z);
    //    RenderTexture.active = rt;
    //    output.ReadPixels(new Rect(0, 0, voxelSize, voxelSize), 0, 0);
    //    output.Apply();
    //    return output;
    //}


    //Texture2D ConvertFromRenderTexture(RenderTexture rt)
    //{
    //    Texture2D output = new Texture2D(voxelSize, voxelSize);
    //    RenderTexture.active = rt;
    //    output.ReadPixels(new Rect(0, 0, voxelSize, voxelSize), 0, 0);
    //    output.Apply();
    //    return output;
    //}

    //void Save()
    //{
    //    Texture3D export = new Texture3D(voxelSize, voxelSize, voxelSize, TextureFormat.ARGB32, false);
    //    RenderTexture selectedRenderTexture;
    //    if (useA)
    //        selectedRenderTexture = renderA;


    //    RenderTexture[] layers = new RenderTexture[voxelSize];
    //    for (int i = 0; i < 64; i++)
    //        layers[i] = Copy3DSliceToRenderTexture(selectedRenderTexture, i);

    //    Texture2D[] finalSlices = new Texture2D[voxelSize];
    //    for (int i = 0; i < 64; i++)
    //        finalSlices[i] = ConvertFromRenderTexture(layers[i]);

    //    Texture3D output = new Texture3D(voxelSize, voxelSize, voxelSize, TextureFormat.ARGB32, true);
    //    output.filterMode = FilterMode.Trilinear;
    //    Color[] outputPixels = output.GetPixels();

    //    for (int k = 0; k < voxelSize; k++)
    //    {
    //        Color[] layerPixels = finalSlices[k].GetPixels();
    //        for (int i = 0; i < voxelSize; i++)
    //            for (int j = 0; j < voxelSize; j++)
    //            {
    //                outputPixels[i + j * voxelSize + k * voxelSize * voxelSize] = layerPixels[i + j * voxelSize];
    //            }
    //    }

    //    output.SetPixels(outputPixels);
    //    output.Apply();

    //    AssetDatabase.CreateAsset(output, "Assets/" + nameOfTheAsset + ".asset");
    //}
}