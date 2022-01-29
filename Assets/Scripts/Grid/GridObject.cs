using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GridObject : MonoBehaviour
{
    [Tooltip("Indicate whether player movement should cause time to move forward (true) or backward (false)")]
    public bool isForward;

    /// <summary>
    /// Returns whether the grid object is pushable by the player
    /// </summary>
    public virtual bool IsPushable() 
    {
        return false;
    }

    /// <summary>
    /// Returns whether the grid object is standable by the player (player can stand on it)
    /// </summary>
    public virtual bool IsPassable() 
    {
        return false;
    }

    public abstract void MoveTo(Vector3 newPosition);

    public void SetTimeDirection(bool isForward) 
    {
        this.isForward = isForward;
    }
    
    public virtual void interactive()
    {
        print("player tried to interact with this object");
        return;
    }
}
