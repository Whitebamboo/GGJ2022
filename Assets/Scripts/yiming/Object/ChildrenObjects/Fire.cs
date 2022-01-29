using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fire : CantMoveWithTimeChange
{
    public GridController gridController;


    private void FixedUpdate()
    {
        Ignite();
    }

    //statelists
    // 0:start fire
    // 1: middle fire
    // 2: big fire
    // 3: end 
    //cant cycle 
    /// <summary>
    /// ignite the object around
    /// </summary>
    public void Ignite()
    {
        if (stateLists[currentState].state == 2)
        {
            (int, int) myPlace = gridController.objectMapping[this.gameObject];
            print(myPlace);
        }
    }
}
