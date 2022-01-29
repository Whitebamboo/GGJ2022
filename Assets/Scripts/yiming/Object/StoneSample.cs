using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class StoneSample : fatherObject
{
    public override bool IsPushable() {
        return true;
    }

    public override bool Equals(GridObject otherObject) 
    {
        return otherObject.GetComponent<StoneSample>() != null;
    }
}
