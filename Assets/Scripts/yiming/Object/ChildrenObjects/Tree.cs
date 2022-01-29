using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tree : CantMoveWithTimeChange,CanbeIgnite
{
    public override bool Equals(GridObject otherObject)
    {
        Tree otherTree = otherObject.GetComponent<Tree>();
        if (otherTree == null) return false;
        return currentState == otherTree.currentState;
    }
}
