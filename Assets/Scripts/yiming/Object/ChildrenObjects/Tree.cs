using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tree : CantMoveWithTimeChange,CanbeIgnite
{
    public bool isIgnite = false;//if it is in the state of ignite
    public bool canIgnite()
    {
        if (!isIgnite)
        {
            isIgnite = true;
            return true;
        }
        else
        {
            return false;
        }
        
    }

    public override bool IsCrushable() 
    {
        return currentState == 0;
    }

    public override void CrashAction() 
    {
        if (currentState == 4) {
            currentState = 3;
            ChangeState(animator);
        }
    }

    public override bool Equals(GridObject otherObject)
    {
        Tree otherTree = otherObject.GetComponent<Tree>();
        if (otherTree == null) return false;
        return currentState == otherTree.currentState;
    }
}
