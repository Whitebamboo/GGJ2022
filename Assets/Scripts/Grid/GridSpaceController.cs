using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class GridSpaceController : MonoBehaviour
{
    GridObject gridObject;

    public void SetObject(GridObject gridObject)
    {
        this.gridObject = gridObject;
    }

    public GridObject GetObject()
    {
        return gridObject;
    }
}