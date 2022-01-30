using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreatBody : MonoBehaviour
{
    //use to record all infomation about this destroy object
    public (int, int) grid;//grid info
    public GameObject creatBody;//the object that creat and need to be destory when undo

    public void getCreatInformation(GameObject go, (int, int) grid)
    {
        
        this.grid = grid;
        creatBody = go;

    }
}
