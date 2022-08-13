using UnityEngine;

public class VoxelGenerator : MonoBehaviour
{
    public ComputeShader voxelGeneratorShader;
    int kernelHandle;
    RenderTexture voxelTexture3D;
    public Vector3Int resolution = Vector3Int.one * 100;

    private void Start()
    {
        kernelHandle = voxelGeneratorShader.FindKernel("CSMain");
    }


    public virtual RenderTexture Generate(float t)
    {
        if (voxelTexture3D == null || voxelTexture3D.width != resolution.x || voxelTexture3D.height != resolution.y || voxelTexture3D.volumeDepth != resolution.z)
        {
            voxelTexture3D = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.RInt);
            voxelTexture3D.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
            voxelTexture3D.volumeDepth = resolution.z;

            voxelTexture3D.enableRandomWrite = true;
            voxelTexture3D.Create();
        }

        voxelGeneratorShader.SetTexture(kernelHandle, "Result", voxelTexture3D);
        voxelGeneratorShader.SetFloat("iTime", t);
        AddShaderParameters();

        //int x = resolution.x / 8;
        //int y = resolution.y / 8;
        //int z = resolution.z / 8;
        int x = resolution.x / 8;
        int y = resolution.y / 8;
        int z = resolution.z / 8;
        voxelGeneratorShader.Dispatch(kernelHandle, x, y, z);

        return voxelTexture3D;
    }

    public virtual void AddShaderParameters() { }
}
