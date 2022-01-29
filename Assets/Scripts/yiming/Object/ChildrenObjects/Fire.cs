using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fire : CantMoveWithTimeChange
{
    public GameObject firePrefab;

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

            
            //check all the grid around it to see if it can ignite
            for (int i = myPlace.Item1-1; i < myPlace.Item1 + 2; i++)
            {
                for(int j = myPlace.Item2 - 1; j < myPlace.Item2 + 2; j++)
                {
                    if(gridController.IsValidPosition(i, j))
                    {
                        
                        
                        if (gridController.GetPositionObject(i, j) == null) continue;
                        GameObject gcobject = gridController.GetPositionObject(i, j).gameObject;
                        print(gcobject.name);
                        CanbeIgnite canignite = gcobject.GetComponent<CanbeIgnite>();
                        if(canignite != null)
                        {
                            if (canignite.canIgnite())
                            {
                                Vector3 creatFirePoint = gridController.GetPosition(i, j);
                                GameObject newFire = Instantiate(firePrefab, creatFirePoint, Quaternion.identity);
                            }
                      
                        }
                    }                    
                }
            }
        }
    }
}
