using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class River : CantMoveWithTimeChange
{
    bool passable = false;
    private void OnEnable()
    {
        isCycle = true;//river always can cycle
        passable = false;
    }


    public override bool IsPassable()
    {
        print(passable);
        return passable;
    }


    private void FixedUpdate()
    {
        PassChange();
    }
    public void PassChange()
    {
        if(stateLists[currentState].state == 0)
        {
            passable = false;
        }
        else
        {
            passable = true;
        }
    }

}
