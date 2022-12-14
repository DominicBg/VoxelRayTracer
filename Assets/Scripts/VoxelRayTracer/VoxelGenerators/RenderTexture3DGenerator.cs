using UnityEngine;

public abstract class RenderTexture3DGenerator : MonoBehaviour
{
    [SerializeField] protected ComputeShader computeShader;
    [SerializeField] protected Vector3Int resolution = Vector3Int.one * 100;

    [Header("Compute shader specific")]
    [SerializeField] protected Vector3Int computeShaderThreadGroup = Vector3Int.one * 8;
    [SerializeField] protected string kernelName = "CSMain";

    int kernelHandle;
    protected RenderTexture renderTexture3D;
    protected abstract RenderTextureFormat TextureType();

    private void Awake()
    {
        kernelHandle = computeShader.FindKernel(kernelName);
    }

    public virtual RenderTexture Generate()
    {
        EnsureTexture();
        AddShaderParameters(computeShader);
        Dispatch();
        return renderTexture3D;
    }

    protected void EnsureTexture()
    {
        if (renderTexture3D == null || renderTexture3D.width != resolution.x || renderTexture3D.height != resolution.y || renderTexture3D.volumeDepth != resolution.z)
        {
            renderTexture3D = new RenderTexture(resolution.x, resolution.y, 0, TextureType());
            renderTexture3D.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
            renderTexture3D.volumeDepth = resolution.z;

            renderTexture3D.enableRandomWrite = true;
            renderTexture3D.Create();
        }
    }

    protected void Dispatch()
    {
        computeShader.SetTexture(kernelHandle, "Result", renderTexture3D);
        int x = resolution.x / computeShaderThreadGroup.x;
        int y = resolution.y / computeShaderThreadGroup.y;
        int z = resolution.z / computeShaderThreadGroup.z;
        computeShader.Dispatch(kernelHandle, x, y, z);
    }
    protected virtual void AddShaderParameters(ComputeShader computeShader) { }
}
