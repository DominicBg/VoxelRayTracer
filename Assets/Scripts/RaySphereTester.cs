using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RaySphereTester : MonoBehaviour
{
	public Vector3 spherePos = new Vector3(0, 0, 10);
	public Vector3 rd = new Vector3(0, 0, 1);
	public float sphereRadius = 1;

	bool RaySphereIntersection(Vector3 ro, Vector3 rd, Vector3 spherePos, float sphereRadius, out float t1, out float t2)
	{
		t1 = 0;
		t2 = 0;

		//solve for tc
		Vector3 L = spherePos - ro;
		float tc = Vector3.Dot(L, rd);

		if (tc < 0.0) return false;
		float d2 = (tc * tc) - Vector3.Dot(L, L);

		float radius2 = sphereRadius * sphereRadius;
		if (d2 > radius2) return false;

		//solve for t1c
		float t1c = Mathf.Sqrt(radius2 - d2);

		//solve for intersection points
		t1 = tc - t1c;
		t2 = tc + t1c;

		return true;
	}

    public void Update()
    {
        if(RaySphereIntersection(Vector3.zero, rd, spherePos, sphereRadius, out float t1, out float t2))
        {
			Debug.Log($"hit with {t1} {t2}");
		}
		else
        {
			Debug.Log("no hit");
        }
    }
}
