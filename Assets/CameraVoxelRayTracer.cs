using UnityEngine;

public class CameraVoxelRayTracer : MonoBehaviour
{
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        var texture = VoxelRayTracerTester.Instance.RenderImage(Time.time);
        Graphics.Blit(texture, dest);
    }
}
