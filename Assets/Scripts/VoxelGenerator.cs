using UnityEngine;

public class VoxelGenerator : MonoBehaviour
{
    public ComputeShader voxelGeneratorShader;
    public ComputeShader voxelGeneratorShaderTransparent;

    int kernelHandle;
    int kernelHandleTransparent;
    RenderTexture voxelTexture3D;
    RenderTexture voxelTextureTransparent3D;
    public Vector3Int resolution = Vector3Int.one * 100;

    private void Start()
    {
        kernelHandle = voxelGeneratorShader.FindKernel("CSMain");
        kernelHandleTransparent = voxelGeneratorShaderTransparent.FindKernel("CSMain");
    }


    public virtual RenderTexture Generate(float t)
    {
        EnsureTexture(ref voxelTexture3D);
        AddShaderParameters();
        Dispatch(voxelGeneratorShader, kernelHandle, voxelTexture3D, t);
        return voxelTexture3D;
    }

    public virtual RenderTexture GenerateTransparent(float t)
    {
        EnsureTexture(ref voxelTextureTransparent3D);
        AddShaderParametersTransparent();
        Dispatch(voxelGeneratorShaderTransparent, kernelHandleTransparent, voxelTextureTransparent3D, t);
        return voxelTextureTransparent3D;
    }

    void EnsureTexture(ref RenderTexture texture)
    {
        if (texture == null || texture.width != resolution.x || texture.height != resolution.y || texture.volumeDepth != resolution.z)
        {
            texture = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.RInt);
            texture.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
            texture.volumeDepth = resolution.z;

            texture.enableRandomWrite = true;
            texture.Create();
        }
    }

    void Dispatch(ComputeShader shader, int kernelHandle, RenderTexture renderTexture, float t)
    {
        shader.SetTexture(kernelHandle, "Result", renderTexture);
        shader.SetFloat("iTime", t);

        int x = resolution.x / 8;
        int y = resolution.y / 8;
        int z = resolution.z / 8;
        shader.Dispatch(kernelHandle, x, y, z);
    }

    public virtual void AddShaderParameters() { }
    public virtual void AddShaderParametersTransparent() { }
}
