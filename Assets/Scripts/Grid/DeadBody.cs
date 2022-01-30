using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeadBody : MonoBehaviour
{
    //use to record all infomation about this destroy object
    public (int, int) grid;//grid info
    public GameObject deadObject;//the object that gona be destroy

    public void getdeadInfomation(GameObject go,(int,int) grid)
    {
        GridObject g = go.GetComponent<GridObject>();
        this.grid = grid;
        deadObject = go;
        print("dead obeject name: " + deadObject.name);
    }
}
