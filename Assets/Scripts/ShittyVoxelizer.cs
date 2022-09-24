using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShittyVoxelizer : VoxelGenerator
{
    public Mesh mesh;
    public float triPlaneDist = 0;
    private List<int> triangles;
    private List<Vector3> vertices;
    private Vector3[] triangle;

    Texture3D text3d;
    public override RenderTexture Generate()
    {
        if (triangles == null)
        {
            triangles = new List<int>(50);
            vertices = new List<Vector3>(50);
            triangle = new Vector3[3];
            text3d = new Texture3D(resolution.x, resolution.y, resolution.z, TextureFormat.R8, false);
            text3d.dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
        }

        mesh.GetTriangles(triangles, 0);
        mesh.GetVertices(vertices);

        EnsureTexture();

        for (int x = 0; x < resolution.x; x++)
        {
            for (int y = 0; y < resolution.y; y++)
            {
                for (int z = 0; z < resolution.z; z++)
                {
                    for (int i = 0; i < triangles.Count; i += 3)
                    {
                        triangle[0] = vertices[triangles[i]];
                        triangle[1] = vertices[triangles[i + 1]];
                        triangle[2] = vertices[triangles[i + 2]];

                        Vector3 normal = Vector3.Cross(triangle[1] - triangle[0], triangle[2] - triangle[0]);

                        if (AABBTriIntersection(triangle, normal, triPlaneDist, new Vector3(x,y,z), Vector3.one))
                        {
                            text3d.SetPixel(x,y,z, Color.white);
                        }
                        else
                        {
                            text3d.SetPixel(x, y, z, Color.clear);
                        }
                    }
                }
            }
        }

        text3d.Apply();
        computeShader.SetTexture(0, "input", text3d);
        Dispatch();

        return renderTexture3D;
    }



    // CONSTANTS //////////////////////////////////////////////////////////////////////////////////////////////////////

    private static readonly Vector3[] BOX_DIR = new Vector3[3] { Vector3.right, Vector3.up, Vector3.forward };

    // FIELDS /////////////////////////////////////////////////////////////////////////////////////////////////////////

    //private Vector3 m_Center;
    //private Vector3 m_Extent;
   // private readonly float[] m_MinMax = new float[6];

    // METHODS ////////////////////////////////////////////////////////////////////////////////////////////////////////

    //-----------------------------------------------------------------------------------------------------------------
    //public void Setup(Vector3 boxCenter, Vector3 boxExtents)
    //{
    //    m_Center = boxCenter;
    //    m_Extent = boxExtents;

    //    Vector3 min = boxCenter - boxExtents;
    //    Vector3 max = boxCenter + boxExtents;

    //    m_MinMax[0] = min.x;
    //    m_MinMax[1] = max.x;
    //    m_MinMax[2] = min.y;
    //    m_MinMax[3] = max.y;
    //    m_MinMax[4] = min.z;
    //    m_MinMax[5] = max.z;
    //}

    //-----------------------------------------------------------------------------------------------------------------
    public bool AABBTriIntersection(Vector3[/*3*/] tri, Vector3 triPlaneN, float triPlaneD, Vector3 boxCenter, Vector3 boxExtents)
    {
        Vector3 min = boxCenter - boxExtents;
        Vector3 max = boxCenter + boxExtents;

        Vector3 dir;
        float tMin, tMax, bMin, bMax;

        // tri's normal...

        tMin = tMax = -triPlaneD;

        ProjectBox(triPlaneN, boxCenter, boxExtents, out bMin, out bMax);

        if (tMax < tMin || bMax < tMin)
            return false;

        // normals of box faces...

        ProjectTri(Vector3.right, tri, out tMin, out tMax);   // tMin = min( tri[0].x, ... , tri[2].x )
                                                           // tMax = max( tri[0].x, ... , tri[2].x )
        if (tMax < min.x || max.x < tMin)
            return false;

        ProjectTri(Vector3.up, tri, out tMin, out tMax);   // tMin = min( tri[0].y, ... , tri[2].y )
                                                           // tMax = max( tri[0].y, ... , tri[2].y )
        if (tMax < min.y || max.y < tMin)
            return false;

        ProjectTri(Vector3.forward, tri, out tMin, out tMax);   // tMin = min( tri[0].z, ... , tri[2].z )
                                                           // tMax = max( tri[0].z, ... , tri[2].z )
        if (tMax < min.z || max.z < tMin)
            return false;

        // cross-products of tri edges and box axis...

        for (int i = 0, j = 2; i < 3; j = i++)
        {
            Vector3 edge = tri[i] - tri[j];

            for (int k = 0; k < 3; ++k)
            {
                dir = Vector3.Cross(edge, BOX_DIR[k]);

                ProjectBox(dir, boxCenter, boxExtents, out bMin, out bMax);
                ProjectTri(dir, tri, out tMin, out tMax);

                if (tMax < bMin || bMax < tMin)
                    return false;
            }
        }

        return true;
    }

    //-----------------------------------------------------------------------------------------------------------------
    private void ProjectBox(Vector3 dir, Vector3 boxCenter, Vector3 boxExtents, out float projMin, out float projMax)
    {
        //float c = (dir.x * boxCenter.x) + (dir.y * boxCenter.y) + (dir.z * boxCenter.z);
        float c = Vector3.Dot(dir, boxCenter);
        float e = Mathf.Abs(dir.x * boxExtents.x) + Mathf.Abs(dir.y * boxExtents.y) + Mathf.Abs(dir.z * boxExtents.z);

        projMin = c - e;
        projMax = c + e;
    }

    //-----------------------------------------------------------------------------------------------------------------
    private static void ProjectTri(Vector3 dir, Vector3[] tri, out float projMin, out float projMax)
    {
        projMin =
        projMax = Vector3.Dot(dir, tri[0]);

        float p = Vector3.Dot(dir, tri[1]);

        if (p < projMin) projMin = p;
        else
        if (p > projMax) projMax = p;

        p = Vector3.Dot(dir, tri[2]);

        if (p < projMin) projMin = p;
        else
        if (p > projMax) projMax = p;
    }
}


