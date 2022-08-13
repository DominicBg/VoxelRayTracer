using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine;

public class VoxelRayTracerEditorView : MonoBehaviour
{
    public VoxelGenerator generator;
    public Vector3Int resolutions = new Vector3Int(3, 3, 3);

    private unsafe void OnDrawGizmosSelected()
    {
        if (generator == null)
            return;

        var texture = generator.Generate(resolutions, 1);
        //texture.ptr
        //var colors = texture.colorBuffer;
        texture.Create();
        IntPtr ptr = texture.GetNativeTexturePtr();
       // texture.GetNativeTexturePtr
        for (int z = 0; z < resolutions.z; z++)
        {
            for (int y = 0; y < resolutions.y; y++)
            {
                for (int x = 0; x < resolutions.x; x++)
                {
                    int index = z * resolutions.x * resolutions.y + y * resolutions.x + x;
                    //int index = y * resolutions.x * resolutions.z + z * resolutions.x + x;
                    int value = UnsafeUtility.ReadArrayElement<int>(ptr.ToPointer(), index);

                    if (value == 0)
                        continue;

                    Gizmos.color = new Color((float)x / resolutions.x, (float)y / resolutions.y, (float)z / resolutions.z);
                    Gizmos.DrawCube(new Vector3(x, y, z), Vector3.one * 0.95f);
                    // if (colors[x, y, z];
                }
            }
        }
    }
}