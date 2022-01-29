using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Stone : MoveWithTimeChange
{
    public override bool IsPushable()
    {
        return true;
    }
}
