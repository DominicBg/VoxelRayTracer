#ifndef _NoiseUtils
#define _NoiseUtils

#include "MathUtils.cginc"

// All this section is taken from 
//https://github.com/Unity-Technologies/Unity.Mathematics/blob/master/src/Unity.Mathematics/Noise/noise2D.cs
float mod(float x, float m) { return x % m; }
float2 mod(float2 x, float2 m) { return x % m; }
float3 mod(float3 x, float3 m) { return x % m; }
float4 mod(float4 x, float4 m) { return x % m; }


float mod289(float x)  
{ return x - floor(x * (1.0 / 289.0)) * 289.0; }
float2 mod289(float2 x) 
{ return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 mod289(float3 x) 
{ return x - floor(x * (1.0 / 289.0)) * 289.0; }
 float4 mod289(float4 x) 
{ return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 permute(float3 x) 
{ return mod289((34.0 * x + 1.0) * x); }
float4 permute(float4 x) 
{ return mod289((34.0 * x + 1.0) * x); }
float3 mod7(float3 x) 
{ return x - floor(x * (1.0f / 7.0f)) * 7.0f; }
float4 taylorInvSqrt(float4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float2 fade(float2 t) { return t*t*t*(t*(t*6.0-15.0)+10.0); }
float3 fade(float3 t) { return t*t*t*(t*(t*6.0-15.0)+10.0); }
float4 fade(float4 t) { return t*t*t*(t*(t*6.0-15.0)+10.0); }
        
float snoise(float2 v)
{
    float4 C = float4(0.211324865405187,  // (3.0-math.sqrt(3.0))/6.0
                          0.366025403784439,  // 0.5*(math.sqrt(3.0)-1.0)
                         -0.577350269189626,  // -1.0 + 2.0 * C.x
                          0.024390243902439); // 1.0 / 41.0
    // First corner
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Other corners
    float2 i1;
    //i1.x = math.step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0f, 1.0f);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;

    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

    float  gx = a0.x * x0.x + h.x * x0.y;
    float2 gyz = a0.yz * x12.xz + h.yz * x12.yw;
    float3 g = float3(gx,gyz);

    return 130.0 * dot(m, g);
}

float snoiseRotate(float2 center, float r, float t)
{
    t *= TAU;
    float s = sin(t), c = cos(t);
    float2 p = center + r * float2(s, c);
    return snoise(p);
}

float snoise(float3 v)
{
    float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
    float4 D = float4(0.0, 0.5, 1.0, 2.0);
    float3 i = floor(v + dot(v, C.yyy));
    float3 x0 = v - i + dot(i, C.xxx);
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy;
    float3 x3 = x0 - D.yyy; 
    i = mod289(i);
    float4 p = permute(permute(permute(
                                 i.z + float4(0.0, i1.z, i2.z, 1.0))
                             + i.y + float4(0.0, i1.y, i2.y, 1.0))
                     + i.x + float4(0.0, i1.x, i2.x, 1.0));

    float n_ = 0.142857142857;
    float3 ns = n_ * D.wyz - D.xzx;
    float4 j = p - 49.0 * floor(p * ns.z * ns.z);
    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_);
    float4 x = x_ * ns.x + ns.yyyy;
    float4 y = y_ * ns.x + ns.yyyy;
    float4 h = 1.0 - abs(x) - abs(y);
    float4 b0 = float4(x.xy, y.xy);
    float4 b1 = float4(x.zw, y.zw);
    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, 0.0);
    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
    float3 p0 = float3(a0.xy, h.x);
    float3 p1 = float3(a0.zw, h.y);
    float3 p2 = float3(a1.xy, h.z);
    float3 p3 = float3(a1.zw, h.w);
    float4 norm = taylorInvSqrt(float4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    float4 m = max(0.6 - float4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m * m, float4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}


float pnoise(float2 P, float2 rep)
{
    float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
    float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    float4 ix = Pi.xzxz;
    float4 iy = Pi.yyww;
    float4 fx = Pf.xzxz;
    float4 fy = Pf.yyww;

    float4 i = permute(permute(ix) + iy);

    float4 gx = frac(i * (1.0 / 41.0)) * 2.0 - 1.0;
    float4 gy = abs(gx) - 0.5;
    float4 tx = floor(gx + 0.5);
    gx = gx - tx;

    float2 g00 = float2(gx.x, gy.x);
    float2 g10 = float2(gx.y, gy.y);
    float2 g01 = float2(gx.z, gy.z);
    float2 g11 = float2(gx.w, gy.w);

    float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;

    float n00 = dot(g00, float2(fx.x, fy.x));
    float n10 = dot(g10, float2(fx.y, fy.y));
    float n01 = dot(g01, float2(fx.z, fy.z));
    float n11 = dot(g11, float2(fx.w, fy.w));

    float2 fade_xy = fade(Pf.xy);
    float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
    float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}


float2 cellular(float2 P)
{
    const float K = 0.142857142857f; // 1/7
    const float Ko = 0.428571428571f; // 3/7
    const float jitter = 1.0f; // Less gives more regular pattern

    float2 Pi = mod289(floor(P));
    float2 Pf = frac(P);
    float3 oi = float3(-1.0, 0.0, 1.0);
    float3 of = float3(-0.5, 0.5, 1.5);
    float3 px = permute(Pi.x + oi);
    float3 p = permute(px.x + Pi.y + oi); // p11, p12, p13
    float3 ox = frac(p * K) - Ko;
    float3 oy = mod7(floor(p * K)) * K - Ko;
    float3 dx = Pf.x + 0.5 + jitter * ox;
    float3 dy = Pf.y - of + jitter * oy;
    float3 d1 = dx * dx + dy * dy; // d11, d12 and d13, squared
    p = permute(px.y + Pi.y + oi); // p21, p22, p23
    ox = frac(p * K) - Ko;
    oy = mod7(floor(p * K)) * K - Ko;
    dx = Pf.x - 0.5 + jitter * ox;
    dy = Pf.y - of + jitter * oy;
    float3 d2 = dx * dx + dy * dy; // d21, d22 and d23, squared
    p = permute(px.z + Pi.y + oi); // p31, p32, p33
    ox = frac(p * K) - Ko;
    oy = mod7(floor(p * K)) * K - Ko;
    dx = Pf.x - 1.5 + jitter * ox;
    dy = Pf.y - of + jitter * oy;
    float3 d3 = dx * dx + dy * dy; // d31, d32 and d33, squared
    // Sort out the two smallest distances (F1, F2)
    float3 d1a = min(d1, d2);
    d2 = max(d1, d2); // Swap to keep candidates for F2
    d2 = min(d2, d3); // neither F1 nor F2 are now in d3
    d1 = min(d1a, d2); // F1 is now in d1
    d2 = max(d1a, d2); // Swap to keep candidates for F2
    d1.xy = (d1.x < d1.y) ? d1.xy : d1.yx; // Swap if smaller
    d1.xz = (d1.x < d1.z) ? d1.xz : d1.zx; // F1 is in d1.x
    d1.yz = min(d1.yz, d2.yz); // F2 is now not in d2.yz
    d1.y = min(d1.y, d1.z); // nor in  d1.z
    d1.y = min(d1.y, d2.x); // F2 is in d1.y, we're done.
    return sqrt(d1.xy);
}

float2 cellular(float3 P)
{
    const float K = 0.142857142857; // 1/7
    const float Ko = 0.428571428571; // 1/2-K/2
    const float K2 = 0.020408163265306; // 1/(7*7)
    const float Kz = 0.166666666667; // 1/6
    const float Kzo = 0.416666666667; // 1/2-1/6*2
    const float jitter = 1.0f; // smaller jitter gives more regular pattern

    float3 Pi = mod289(floor(P));
    float3 Pf = frac(P) - 0.5;
    float3 Pfx = Pf.x + float3(1.0, 0.0, -1.0);
    float3 Pfy = Pf.y + float3(1.0, 0.0, -1.0);
    float3 Pfz = Pf.z + float3(1.0, 0.0, -1.0);
    float3 p = permute(Pi.x + float3(-1.0, 0.0, 1.0));
    float3 p1 = permute(p + Pi.y - 1.0);
    float3 p2 = permute(p + Pi.y);
    float3 p3 = permute(p + Pi.y + 1.0);
    float3 p11 = permute(p1 + Pi.z - 1.0);
    float3 p12 = permute(p1 + Pi.z);
    float3 p13 = permute(p1 + Pi.z + 1.0);
    float3 p21 = permute(p2 + Pi.z - 1.0);
    float3 p22 = permute(p2 + Pi.z);
    float3 p23 = permute(p2 + Pi.z + 1.0);
    float3 p31 = permute(p3 + Pi.z - 1.0);
    float3 p32 = permute(p3 + Pi.z);
    float3 p33 = permute(p3 + Pi.z + 1.0);
    float3 ox11 = frac(p11 * K) - Ko;
    float3 oy11 = mod7(floor(p11 * K)) * K - Ko;
    float3 oz11 = floor(p11 * K2) * Kz - Kzo; // p11 < 289 guaranteed
    float3 ox12 = frac(p12 * K) - Ko;
    float3 oy12 = mod7(floor(p12 * K)) * K - Ko;
    float3 oz12 = floor(p12 * K2) * Kz - Kzo;
    float3 ox13 = frac(p13 * K) - Ko;
    float3 oy13 = mod7(floor(p13 * K)) * K - Ko;
    float3 oz13 = floor(p13 * K2) * Kz - Kzo;
    float3 ox21 = frac(p21 * K) - Ko;
    float3 oy21 = mod7(floor(p21 * K)) * K - Ko;
    float3 oz21 = floor(p21 * K2) * Kz - Kzo;
    float3 ox22 = frac(p22 * K) - Ko;
    float3 oy22 = mod7(floor(p22 * K)) * K - Ko;
    float3 oz22 = floor(p22 * K2) * Kz - Kzo;
    float3 ox23 = frac(p23 * K) - Ko;
    float3 oy23 = mod7(floor(p23 * K)) * K - Ko;
    float3 oz23 = floor(p23 * K2) * Kz - Kzo;
    float3 ox31 = frac(p31 * K) - Ko;
    float3 oy31 = mod7(floor(p31 * K)) * K - Ko;
    float3 oz31 = floor(p31 * K2) * Kz - Kzo;
    float3 ox32 = frac(p32 * K) - Ko;
    float3 oy32 = mod7(floor(p32 * K)) * K - Ko;
    float3 oz32 = floor(p32 * K2) * Kz - Kzo;
    float3 ox33 = frac(p33 * K) - Ko;
    float3 oy33 = mod7(floor(p33 * K)) * K - Ko;
    float3 oz33 = floor(p33 * K2) * Kz - Kzo;
    float3 dx11 = Pfx + jitter * ox11;
    float3 dy11 = Pfy.x + jitter * oy11;
    float3 dz11 = Pfz.x + jitter * oz11;
    float3 dx12 = Pfx + jitter * ox12;
    float3 dy12 = Pfy.x + jitter * oy12;
    float3 dz12 = Pfz.y + jitter * oz12;
    float3 dx13 = Pfx + jitter * ox13;
    float3 dy13 = Pfy.x + jitter * oy13;
    float3 dz13 = Pfz.z + jitter * oz13;
    float3 dx21 = Pfx + jitter * ox21;
    float3 dy21 = Pfy.y + jitter * oy21;
    float3 dz21 = Pfz.x + jitter * oz21;
    float3 dx22 = Pfx + jitter * ox22;
    float3 dy22 = Pfy.y + jitter * oy22;
    float3 dz22 = Pfz.y + jitter * oz22;
    float3 dx23 = Pfx + jitter * ox23;
    float3 dy23 = Pfy.y + jitter * oy23;
    float3 dz23 = Pfz.z + jitter * oz23;
    float3 dx31 = Pfx + jitter * ox31;
    float3 dy31 = Pfy.z + jitter * oy31;
    float3 dz31 = Pfz.x + jitter * oz31;
    float3 dx32 = Pfx + jitter * ox32;
    float3 dy32 = Pfy.z + jitter * oy32;
    float3 dz32 = Pfz.y + jitter * oz32;
    float3 dx33 = Pfx + jitter * ox33;
    float3 dy33 = Pfy.z + jitter * oy33;
    float3 dz33 = Pfz.z + jitter * oz33;
    float3 d11 = dx11 * dx11 + dy11 * dy11 + dz11 * dz11;
    float3 d12 = dx12 * dx12 + dy12 * dy12 + dz12 * dz12;
    float3 d13 = dx13 * dx13 + dy13 * dy13 + dz13 * dz13;
    float3 d21 = dx21 * dx21 + dy21 * dy21 + dz21 * dz21;
    float3 d22 = dx22 * dx22 + dy22 * dy22 + dz22 * dz22;
    float3 d23 = dx23 * dx23 + dy23 * dy23 + dz23 * dz23;
    float3 d31 = dx31 * dx31 + dy31 * dy31 + dz31 * dz31;
    float3 d32 = dx32 * dx32 + dy32 * dy32 + dz32 * dz32;
    float3 d33 = dx33 * dx33 + dy33 * dy33 + dz33 * dz33;

    // Sort out the two smallest distances (F1, F2)
    // Do it right and sort out both F1 and F2
    float3 d1a = min(d11, d12);
    d12 = max(d11, d12);
    d11 = min(d1a, d13); // Smallest now not in d12 or d13
    d13 = max(d1a, d13);
    d12 = min(d12, d13); // 2nd smallest now not in d13
    float3 d2a = min(d21, d22);
    d22 = max(d21, d22);
    d21 = min(d2a, d23); // Smallest now not in d22 or d23
    d23 = max(d2a, d23);
    d22 = min(d22, d23); // 2nd smallest now not in d23
    float3 d3a = min(d31, d32);
    d32 = max(d31, d32);
    d31 = min(d3a, d33); // Smallest now not in d32 or d33
    d33 = max(d3a, d33);
    d32 = min(d32, d33); // 2nd smallest now not in d33
    float3 da = min(d11, d21);
    d21 = max(d11, d21);
    d11 = min(da, d31); // Smallest now in d11
    d31 = max(da, d31); // 2nd smallest now not in d31
    d11.xy = (d11.x < d11.y) ? d11.xy : d11.yx;
    d11.xz = (d11.x < d11.z) ? d11.xz : d11.zx; // d11.x now smallest
    d12 = min(d12, d21); // 2nd smallest now not in d21
    d12 = min(d12, d22); // nor in d22
    d12 = min(d12, d31); // nor in d31
    d12 = min(d12, d32); // nor in d32
    d11.yz = min(d11.yz, d12.xy); // nor in d12.yz
    d11.y = min(d11.y, d12.z); // Only two more to go
    d11.y = min(d11.y, d11.z); // Done! (Phew!)
    return sqrt(d11.xy); // F1, F2
}


const float3x3 m3  = float3x3( 0.00,  0.80,  0.60,
                      -0.80,  0.36, -0.48,
                      -0.60, -0.48,  0.64 );
     


float cellfbm(float2 x, int n)
{
    float f = 2.0;
    float s = 0.5;
    float a = 0.0;
    float b = 0.5;
    for(int i = 0; i < n; i++)
    {
        float n = cellular(x).x;
        a += b*n;
        b *= s;
        x = f * x;
    }
	return a;
}

// float cellfbmr(float2 x, float2x2 rot, int n)
// {
//     float f = 2.0;
//     float s = 0.5;
//     float a = 0.0;
//     float b = 0.5;
//     for( int i = 0; i < n; i++)
//     {
//         float n = cellular(x).x;
//         a += b*n;
//         b *= s;
//         x = f * (rot * x);
//     }
// 	return a;
// }
     
// float fbm_4r(float3 x)
// {
//     float f = 2.0;
//     float s = 0.5;
//     float a = 0.0;
//     float b = 0.5;
//     for( int i = 0; i < 4; i++)
//     {
//         float n = snoise(x);
//         a += b*n;
//         b *= s;
//         x = f*m3*x;
//     }
// 	return a;
// }

float fbm_4(float3 x)
{
    float f = 2.0;
    float s = 0.5;
    float a = 0.0;
    float b = 0.5;
    for(int i = 0; i < 4; i++)
    {
        float n = snoise(x);
        a += b * n;
        b *= s;
    }
	return a;
}

float fbm_4(float2 x)
{
    float f = 2.0;
    float s = 0.5;
    float a = 0.0;
    float b = 0.5;
    for(int i = 0; i < 4; i++)
    {
        float n = snoise(x);
        a += b * n;
        b *= s;
    }
	return a;
}

// float fbm_4r( in float3 x, float3x3 rot)
// {
//     float f = 2.0;
//     float s = 0.5;
//     float a = 0.0;
//     float b = 0.5;
//     for( int i=0; i<4; i++ )
//     {
//         float n = snoise(x);
//         a += b*n;
//         b *= s;
//         x = f*rot*x;
//     }
// 	return a;
// }

float fmb4_3x( in float3 x)
{
    return fbm_4(x + fbm_4(x + fbm_4(x)));
}

// float fmb4r_3x( in float3 x, float3x3 rot)
// {
//     return fbm_4r(x + float3(fbm_4r(x + float3(fbm_4r(x, rot), rot), rot)));
// }

float fmb4_3x( in float3 x, float3 offset)
{
    return fbm_4(x + offset + fbm_4(x + fbm_4(x)));
}

#endif