using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateAround : MonoBehaviour
{
    public Transform center;
    public float speed = 1;
    public Vector3 axis = Vector3.up;
    public float distFromCenter = 15;

    public void Update()
    {
        var rotation = Quaternion.AngleAxis(speed * Time.time, axis);

        transform.position = center.position + (rotation * Vector3.forward) * distFromCenter;
        transform.LookAt(center);
    }

}
