using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GridObject : MonoBehaviour
{
    public bool isLeft;

    public virtual bool IsPushable() 
    {
        return false;
    }
    public abstract void MoveTo(Vector3 newPosition);

    public void SetTimeDirection(bool isLeft) 
    {
        this.isLeft = isLeft;
    }
    
    public virtual void interactive()
    {
        print("player tried to interact with this object");
        return;
    }
}
