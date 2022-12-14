#ifndef _MathUtils
#define _MathUtils

#define TAU 6.283185
#define PI 3.141592

bool DirectionToPitchYaw(float3 dir, out float pitch, out float yaw)
{
    pitch = asin(-dir.y);
    yaw = atan2(dir.x, dir.z);
    return true;
    // pitch = asin(V.y / length(V));
    // yaw = asin( V.x / (cos(pitch)*length(V)) ); //Beware cos(pitch)==0, catch this exception!

}

// All components are in the range [0…1], including hue.
float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 GetColor(int r, int g, int b)
{
    return float3(r, g, b) / 255;
}

float3 cos3(float3 v)
{
    return float3(cos(v.x), cos(v.y), cos(v.z));
}

float3 ColorPalette(float t, float3 a, float3 b, float3 c, float3 d)
{
    return a + b * cos3(TAU * (c * t + d));
}

// All components are in the range [0…1], including hue.
float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float Luminance(float3 col)
{
    return col.r * 0.2126 + col.g * 0.7152 + col.b * 0.0722;
}

float3 ShittyRandom(float x)
{
    return float3(sin(70.52 * x), cos(31.527 * x), sin(45.42 * x));
}


float2 rotate2d(float2 v, float a)
{
    float sinA = sin(a);
    float cosA = cos(a);
    return float2(v.x * cosA - v.y * sinA, v.y * cosA + v.x * sinA);
}

float distancesq(float2 x, float2 y)
{
    float2 diff = x - y;
    return dot(diff, diff);
}
float distancesq(float3 x, float3 y)
{
    float3 diff = x - y;
    return dot(diff, diff);
}

float saturate(float x)
{
    return clamp(x, 0., 1.);
}
float3 saturate(float3 v)
{
    return float3(saturate(v.x), saturate(v.y), saturate(v.z));
}
float4 saturate(float4 v)
{
    return float4(saturate(v.x), saturate(v.y), saturate(v.z), saturate(v.w));
}

float unlerp(float x, float fromMin, float fromMax)
{
    return (x - fromMin) / (fromMax - fromMin);
}

float Remap(float fromMin, float fromMax, float toMin, float toMax, float x)
{
    float t = saturate(unlerp(x, fromMin, fromMax));
    return lerp(toMin, toMax, t);
}

float gain(float x, float k)
{
    float a = 0.5 * pow(2.0 * ((x < 0.5) ? x : 1.0 - x), k);
    return (x < 0.5) ? a : 1.0 - a;
}

//Easings
float easeInOutCubic(float x)
{
    return x < 0.5 ? 4. * x * x * x : 1. - pow(-2. * x + 2., 3.) / 2.;
}


float easeOutCirc(float x)
{
    return 1.0 - (1.0 - x) * (1.0 - x) * (1.0 - x) * (1.0 - x) * (1.0 - x);
}

float easeOutQuad(float x)
{
    return 1.0 - (1.0 - x) * (1.0 - x);
}

float easeOutCubic(float x)
{
    return 1.0 - (1.0 - x) * (1.0 - x) * (1.0 - x);
}
float easeInQuad(float x)
{
    return x * x;
}

float easeInCubic(float x)
{
    return x * x * x;
}

float Tri(float x)
{
    return 1. - abs(1. - 2. * x);
}

float Quantize(float x, float resolution)
{
    return floor(x * resolution) / resolution;
}
float2 Quantize(float2 x, float2 resolution)
{
    return floor(x * resolution) / resolution;
}
float3 Quantize(float3 x, float resolution)
{
    return floor(x * resolution) / resolution;
}


// Quaternion multiplication.
// http://mathworld.wolfram.com/Quaternion.html
float4 qmul(float4 q1, float4 q2)
{
    return float4(
        q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz),
        q1.w * q2.w - dot(q1.xyz, q2.xyz)
    );
}

// Rotate a vector with a rotation quaternion.
// http://mathworld.wolfram.com/Quaternion.html
float3 qmul(float4 r, float3 v)
{
    float4 r_c = r * float4(-1.0, -1.0, -1.0, 1.0);
    return qmul(r, qmul(float4(v, 0.0), r_c)).xyz;
}

float4 qAxisAngleRotation(float3 axis, float angle)
{
    axis = normalize(axis);
    float s, c;
    s = sin(angle);
    c = cos(angle);
    return float4(axis.x * s, axis.y * s, axis.z * s, c);
}

float4 qInverse(float4 q)
{
    float4 x = q;
    return float4(1.0 / (dot(x, x)) * x * float4(-1.0, -1.0, -1.0, 1.0));
}




// RNG
uint WangHash(uint n)
{
    // https://gist.github.com/badboy/6267743#hash-function-construction-principles
    // Wang hash: this has the property that none of the outputs will
    // collide with each other, which is important for the purposes of
    // seeding a random number generator.  This was verified empirically
    // by checking all 2^32 uints.
    n = (n ^ 61u) ^(n >> 16);
    n *= 9u;
    n = n ^(n >> 4);
    n *= 0x27d4eb2du;
    n = n ^(n >> 15);

    return n;
}

uint GenerateRngState(uint3 id)
{
    return WangHash(id.x * 532 + id.y * 1227 + id.z * 3523);
}

uint GenerateRngState(float3 id)
{
    return WangHash(id.x * 532 + id.y * 1227 + id.z * 3523);
}

uint GenerateRngState(float3 id, int seed)
{
    id += seed;
    return WangHash(id.x * 532 * + id.y * 1227 + id.z * 3523);
}



uint NextState(uint state)
{
    state ^= state << 13;
    state ^= state >> 17;
    state ^= state << 5;
    return state;
}

float NextFloat(inout uint state)
{
    state = NextState(state);
    int n = int(state % 1000u);
    return float(n) / 1000.;
}

float NextInt(int xmax, inout uint state)
{
    state = NextState(state);
    int n = int(state % xmax);
    return n;
}

float NextFloat(float xmin, float xmax, inout uint state)
{
    state = NextState(state);
    int n = int(state % 1000u);
    float t = float(n) / 1000.;
    return lerp(xmin, xmax, t);
}

float2 NextFloat2(float2 rmin, float2 rmax, inout uint state)
{
    float x = NextFloat(rmin.x, rmax.x, state);
    float y = NextFloat(rmin.y, rmax.y, state);
    return float2(x, y);
}

float3 NextFloat3(float3 rmin, float3 rmax, inout uint state)
{
    float x = NextFloat(rmin.x, rmax.x, state);
    float y = NextFloat(rmin.y, rmax.y, state);
    float z = NextFloat(rmin.z, rmax.z, state);
    return float3(x, y, z);
}

float3 NextRandomDirection(float3 direction, float spread, inout uint state)
{
    // Make an orthogonal basis whose third vector is along `direction'
    float3 b3 = normalize(direction);
    float3 different = (abs(b3.x) < 0.5) ? float3(1.0, 0.0, 0.0) : float3(0.0, 1.0, 0.0);
    float3 b1 = normalize(cross(b3, different));
    float3 b2 = cross(b1, b3);
    
    // Pick (x,y,z) randomly around (0,0,1)
    //float z = NextFloat((spread * PI), 1, state);
    float z = NextFloat(0, (spread * PI), state);
    //float r = sqrt(1.0f - z * z);
    float r = sqrt(z);

    float theta = NextFloat(-PI, +PI, state);
    float x = r * cos(theta);
    float y = r * sin(theta);
    
    // Construct the vector that has coordinates (x,y,z) in the basis formed by b1, b2, b3
    return x * b1 + y * b2 + z * b3;
}

float3 RandomOnCube(inout uint state)
{
    float result[3];

    //5 faces
    int s = NextInt(6, state);
    int c = s % 3; // get the axis perpendicular to the side you just picked

    result[c] = (s > 2) ? 1. : 0.;
    result[(c + 1) % 3] = NextFloat(state);
    result[(c + 2) % 3] = NextFloat(state);

    return float3(result[0], result[1], result[2]);
}

float3 RandomInSphere(inout uint state)
{
    float u = NextFloat(state);
    float v = NextFloat(state);
    float theta = u * 2.0 * PI;
    float phi = acos(2.0 * v - 1.0);
    //float r = cbrt(NextFloat(state)); //doesn't exist
    float r = pow(NextFloat(state), 1. / 3.); //cube root
    float sinTheta = sin(theta);
    float cosTheta = cos(theta);
    float sinPhi = sin(phi);
    float cosPhi = cos(phi);
    float x = r * sinPhi * cosTheta;
    float y = r * sinPhi * sinTheta;
    float z = r * cosPhi;
    return float3(x, y, z);
}


bool RaySphereIntersection(float3 ro, float3 rd, float3 spherePos, float sphereRadius, out float t1, out float t2)
{
    t1 = 0;
    t2 = 0;

    //solve for tc
    float3 l = spherePos - ro;
    float tc = dot(l, rd);
    
    if (tc < 0.0) return false;
    float d2 = (tc * tc) - dot(l, l);
    
    float radius2 = sphereRadius * sphereRadius;
    if (d2 > radius2) return false;

    //solve for t1c
    float t1c = sqrt(radius2 - d2);

    //solve for intersection points
    t1 = tc - t1c;
    t2 = tc + t1c;
    
    return true;
}


inline float3 projectOnNormalNormalized(float3 vec, float3 normal)
{
    return normal * dot(vec, normal);
}

inline float3 projectOnNormal(float3 vec, float3 normal)
{
    return normal * (dot(vec, normal) / dot(normal, normal));
}

inline float3 projectOnPlaneNormalized(float3 vec, float3 normal)
{
    return vec - normal * dot(vec, normal);
}

inline float3 projectOnPlane(float3 vec, float3 normal)
{
    return vec - normal * (dot(vec, normal) / dot(normal, normal));
}

void GetTangentBitangent(float3 normal, out float3 tangent, out float3 bitangent)
{
    float3 zAxis = float3(0, 0, 1);
    float3 yAxis = float3(0, 1, 0);
    //might be swapped
    //tangent = (dot(normal, yAxis) > 0.9999) ? zAxis : yAxis;
    //bitangent = cross(tangent, normal);
   // bitangent = cross(normal, tangent);

    bitangent = (dot(normal, yAxis) > 0.9999) ? zAxis : yAxis;
    //tangent = cross(normal, bitangent);
    tangent = cross(normal, bitangent);
}

float3x3 GetTBN(float3 normal)
{
    float3 tangent, bitangent;
    GetTangentBitangent(normal, tangent, bitangent);
    return float3x3(tangent, bitangent, normal);
}

float2 ProjectOnPlaneTo2D(float3 vec, float3 normal)
{
    float3 posProj = projectOnPlaneNormalized(vec, normal);

    float3 tangent, bitangent;
    GetTangentBitangent(normal, tangent, bitangent);
    // float3 zAxis = float3(0, 0, 1);
    // float3 yAxis = float3(0, 1, 0);
    // float3 axis1 = (dot(normal, yAxis) > 0.9999) ? zAxis : yAxis;
    // float3 axis2 = cross(axis1, normal);

    return float2(dot(posProj, tangent), dot(posProj, bitangent));
}

///
#endif