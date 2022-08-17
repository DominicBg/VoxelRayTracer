#include "../Utils/MathUtils.cginc"
#include "../Utils/NoiseUtils.cginc"

float3 SampleGradient(float t)
{
    const uint size = 8;
    float3 cols[size] =
    {   
        GetColor(86, 167, 204),
        GetColor(179, 225, 232),
        GetColor(66, 214, 255),
        GetColor(235, 214, 163),
        GetColor(255, 163, 163),
        GetColor(95, 237, 194),   
        GetColor(29, 26, 176),
        GetColor(96, 63, 204)
    };

    float sizeT = t * size;
    uint id1 = uint(sizeT);
    uint id2 = (id1 + 1);
    
    float tt = unlerp(sizeT, float(id1), float(id2));
    return lerp(cols[id1], cols[id2 % size], tt);    
}

float3 GetWeirdNoise(float2 uv, float t)
{ 
    t *= 0.05;
    float x = abs(0.5 - uv.x * 0.5) * 0.1;
    x = pow(x, 1.2);
    float y = abs(uv.y) * .7;
    
    float noise1 = 0.1 * fbm_4(float3(uv.x, uv.y, sin(4. * TAU * t) * 0.1));
    float noise2 = 0.5 - 0.5 * cellfbm(float2(uv.x, uv.y +  sin(3. * TAU *t) * 0.1), 6);

    return frac(y + x + noise1 - noise2 + t);
}

float3 SampleSimpleSkybox(float3 ro, float3 rd, float t)
{
    float pitch;
    float yaw;
    DirectionToPitchYaw(rd, pitch, yaw);

    //float t = (pitch / PI) + (yaw / TAU);
    float noiseValue = GetWeirdNoise(float2(yaw, pitch) / (TAU)  * 10, t);
    return SampleGradient(noiseValue);
    //return ColorPalette(t, col1, col2, col3, col4);
}


// vec4 GetGradientColor(vec2 uv, float dayCycle)
// {
//     float x = abs(0.5 - uv.x * 0.5) * 0.1;
//     x = pow(x, 1.2);
//     float y = abs(uv.y) * .7;
    
//     float noise1 = 0.1 * fbm_4(vec3(uv.x, uv.y, sin(4. * TAU * dayCycle) * 0.1));
//     float noise2 = 0.5 - 0.5 * cellfbm(vec2(uv.x, uv.y +  sin(3. * TAU *dayCycle) * 0.1), 4);

//     float t = fract(y + x + noise1 - noise2 + dayCycle);
    
//     const int size = 8;
      
//     vec4 cols[size] = vec4[size]
//     (
//         GetCol(86, 167, 204),
//         GetCol(179, 225, 232),
//         GetCol(66, 214, 255),
//         GetCol(235, 214, 163),
//         GetCol(255, 163, 163),
//         GetCol(95, 237, 194), //GetCol(211, 67, 240),    
//         GetCol(29, 26, 176),
//         GetCol(96, 63, 204)
//     );
    
//     float sizeT = t * float(size);
//     int id1 = int(sizeT);
//     int id2 = (id1 + 1);
    
//     float tt = unlerp(sizeT, float(id1), float(id2));
//     return mix(cols[id1], cols[id2 % size], tt);    
// }