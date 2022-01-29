using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveWithoutTimeChange : fatherObject
{
    public override bool Equals(GridObject otherObject)
    {
        throw new System.NotImplementedException();
    }
    private void Start()
    {
        isChangeWithTime = false;
    }
    //make it pushable
    public override bool IsPushable()
    {
        return true;
    }

    private void Update()
    {
        Move();
    }
}
