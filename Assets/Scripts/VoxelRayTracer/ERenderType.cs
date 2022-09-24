using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Flags]
public enum ERenderType
{ 
    Progressive = 2 << 0,
    Fixed = 2 << 1
}
