using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeadBody : MonoBehaviour
{
    //use to record all infomation about this destroy object
    public int step;//was destroy at which step
    public (int, int) grid;//grid info
    public GameObject deadObject;//the object that gona be destroy
}
