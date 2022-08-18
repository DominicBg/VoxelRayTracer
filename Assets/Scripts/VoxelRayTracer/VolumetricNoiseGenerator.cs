using UnityEngine;

public class VolumetricNoiseGenerator : RenderTexture3DGenerator
{
    protected override RenderTextureFormat TextureType() => RenderTextureFormat.RFloat;
    float t;

    public RenderTexture GenerateWithParameters(float time)
    {
        t = time;
        return Generate();
    }

    protected override void AddShaderParameters(ComputeShader computeShader)
    {
        base.AddShaderParameters(computeShader);
        computeShader.SetFloat("iTime", t);
    }

}
