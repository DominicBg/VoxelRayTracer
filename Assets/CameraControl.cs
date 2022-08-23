//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;

//public class CameraControl : MonoBehaviour
//{
//    public float normalSpeed = 1;
//    public float shiftSpeed = 2;

//    // Update is called once per frame
//    void Update()
//    {
//        float speed = Input.GetKey(KeyCode.LeftShift) ? shiftSpeed : normalSpeed;

//        Vector2 input = new Vector2(
//            Input.GetAxis("Horizontal"),
//            Input.GetAxis("Vertical")
//        );

//        Vector2 mouseInput = Input.mouseScrollDelta;


//        if(Input.GetMouseButton(1))
//        {
//            transform.Rotate()
//        }


//        transform.position += (transform.forward * input.y + transform.right * input.x) * speed * Time.deltaTime;
//    }
//}
