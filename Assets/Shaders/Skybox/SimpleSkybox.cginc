#include "../Utils/MathUtils.cginc"

float3 SampleSimpleSkybox(float3 ro, float3 rd, float t)
{
    float pitch;
    float yaw;
    DirectionToPitchYaw(rd, pitch, yaw);

    float3 col1 = GetColor(51, 33, 110);
    float3 col2 = GetColor(21, 3, 43);

    return lerp(col1, col2, saturate(abs(pitch)));
}
