using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// Was used to control the appearance of a grid tile based on its value
// Probably not needed for our project
public class GridSpaceController : MonoBehaviour
{
    public Material emptyMaterial;
    public Material destinationMaterial;
    public Material fullMaterial;

    GridValue gridValue;

    public void SetValue(GridValue value)
    {
        gridValue = value;
        switch (value)
        {
            case GridValue.Space:
                GetComponent<MeshRenderer>().material = emptyMaterial;
                break;
            case GridValue.Destination:
                GetComponent<MeshRenderer>().material = destinationMaterial;
                break;
            default:
                GetComponent<MeshRenderer>().material = fullMaterial;
                break;
        }
    }

    public GridValue GetValue()
    {
        return gridValue;
    }
}