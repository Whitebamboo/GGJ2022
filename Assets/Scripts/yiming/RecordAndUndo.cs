using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordAndUndo : MonoBehaviour
{
    
    public class ScreenShot
    {
        public GridSpaceRecoder[,] grid;
        public GameObject[] deadBody;//object that was destroy at this step

    }
}
