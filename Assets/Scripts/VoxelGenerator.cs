using UnityEngine;

public class VoxelGenerator : MonoBehaviour
{
    public ComputeShader voxelGeneratorShader;
    int kernelHandle;
    RenderTexture outputTexture;


    private void Start()
    {
        kernelHandle = voxelGeneratorShader.FindKernel("CSMain");
    }

    public virtual RenderTexture Generate(Vector3Int resolution, float t)
    {
        if (outputTexture == null || outputTexture.width != resolution.x || outputTexture.height != resolution.y || outputTexture.volumeDepth != resolution.z)
        {
            outputTexture = new RenderTexture(resolution.x, resolution.y, 0, RenderTextureFormat.RInt);
            outputTexture.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
            outputTexture.volumeDepth = resolution.z;

            outputTexture.enableRandomWrite = true;
            outputTexture.Create();
        }

        voxelGeneratorShader.SetTexture(kernelHandle, "Result", outputTexture);
        voxelGeneratorShader.SetFloat("iTime", t);
        AddShaderParameters();

        //int x = resolution.x / 8;
        //int y = resolution.y / 8;
        //int z = resolution.z / 8;
        int x = resolution.x / 1;
        int y = resolution.y / 1;
        int z = resolution.z / 1;
        voxelGeneratorShader.Dispatch(kernelHandle, x, y, z);

        return outputTexture;
    }

    public virtual void AddShaderParameters() { }
}
