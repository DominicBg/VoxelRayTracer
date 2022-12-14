using UnityEngine;

public class CameraVoxelRayTracer : MonoBehaviour
{
    public bool updateTime;
    public float t;

    public void Update()
    {  
        if(!VoxelRayTracerTester.Instance.useProgressiveRenderer)
            t += Time.deltaTime;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        var texture = VoxelRayTracerTester.Instance.RenderImage(t);
        Graphics.Blit(texture, dest);
    }
}
