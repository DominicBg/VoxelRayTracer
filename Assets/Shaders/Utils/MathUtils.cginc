#ifndef _MathUtils
#define _MathUtils

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

float sdSphere(float3 p, float d) { return length(p) - d; } 

float sdBox( float3 p, float3 b )
{
  float3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float2 rotate2d(float2 v, float a) {
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


float easeInOutCubic(float x)
{
    return x < 0.5 ? 4. * x * x * x : 1. - pow(-2. * x + 2., 3.) / 2.;
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
	float s,c;
	s = sin(angle);
    c = cos(angle);
	return float4(axis.x*s,axis.y*s,axis.z*s,c);
}

float4 qInverse(float4 q)
{
    float4 x = q;
    return float4(1.0/(dot(x, x)) * x * float4(-1.0, -1.0, -1.0, 1.0));
}



// RNG
uint WangHash(uint n)
{
    // https://gist.github.com/badboy/6267743#hash-function-construction-principles
    // Wang hash: this has the property that none of the outputs will
    // collide with each other, which is important for the purposes of
    // seeding a random number generator.  This was verified empirically
    // by checking all 2^32 uints.
    n = (n ^ 61u) ^ (n >> 16);
    n *= 9u;
    n = n ^ (n >> 4);
    n *= 0x27d4eb2du;
    n = n ^ (n >> 15);

    return n;
}

uint NextState(uint state)
{
    state ^= state << 13;
    state ^= state >> 17;
    state ^= state << 5;
    return state;
}

float NextFloat(float xmin, float xmax, inout uint state)
{
    state = NextState(state);
    int n = int(state % 1000u);
    float t = float(n) / 1000.;   
    return lerp(xmin, xmax, t);
}

float2 NextVec2(float2 rmin, float2 rmax, inout uint state)
{
    float x = NextFloat(rmin.x, rmax.x, state);
    float y = NextFloat(rmin.y, rmax.y, state);
    return float2(x, y);
}

float3 NextVec3(float3 rmin, float3 rmax, inout uint state)
{
    float x = NextFloat(rmin.x, rmax.x, state);
    float y = NextFloat(rmin.y, rmax.y, state);
    float z = NextFloat(rmin.z, rmax.z, state);
    return float3(x, y, z);
}

#endif