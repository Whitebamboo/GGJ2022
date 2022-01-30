using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridSpaceRecoder : MonoBehaviour
{
    public bool isEmpty;
    public string gridObjectName;
    public string t;//the object's type
    public bool haveState;//is this object have state
    public int state;
    public int age;

    public void SetObject(string gridObjectName)
    {
        this.gridObjectName = gridObjectName;
    }

    public string GetObject()
    {
        return gridObjectName;
    }

    public void StoreInfo(GameObject gameObject)
    {
        if(gameObject.tag == "Player")
        {
            t = "Player";
            haveState = false;//whatever it is

        }
        else
        {
            t = "Object";
            fatherObject fo = gameObject.GetComponent<fatherObject>();
            if (fo.stateLists.Count > 0)
            {
                haveState = true;
                state = fo.currentState;
                age = fo.age;
            }
        }
    }

}
