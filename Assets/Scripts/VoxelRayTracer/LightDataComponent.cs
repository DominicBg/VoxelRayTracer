using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class LightDataComponent : MonoBehaviour
{
    public VoxelLightType lightType;
    public Color color = Color.white;
    public float intensity = 1;
    public float radius = 1;
    public float penumbraRadius = 1;
    public float volumetricIntensity = 0.01f;

    public ERenderType renderType;

    public LightData GetLightData()
    {
        return new LightData()
        {
            lightType = lightType,
            position = transform.position,
            direction = transform.forward,
            color = new Vector3(color.r, color.g, color.b),
            intensity = intensity,
            volumetricIntensity = volumetricIntensity,
            penumbraRadius = penumbraRadius,
            radius = radius
        };
    }
}
