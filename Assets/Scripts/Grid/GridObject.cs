using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GridObject : MonoBehaviour
{
    [Tooltip("Indicate whether player movement should cause time to move forward (true) or backward (false)")]
    public bool isForward;
    public GridController gridController;
    GridObject passedObject;

    /// <summary>
    /// Returns whether the grid object is pushable by the player
    /// </summary>
    public virtual bool IsPushable() 
    {
        return false;
    }

    /// <summary>
    /// Returns whether the grid object is passable by the player and other objects
    /// </summary>
    public virtual bool IsPassable() 
    {
        return false;
    }

    /// <summary>
    /// Returns whether the grid object can be crushed by pushable objects
    /// </summary>
    public virtual bool IsCrushable() 
    {
        return false;
    }

    /// <summary>
    /// Run when crashed into by pushable objects
    /// </summary>
    public virtual void CrashAction() 
    {
        return;
    }

    public void SetPassedObject(GridObject passedObject) 
    {
        if (!IsPassable()) return;
        this.passedObject = passedObject;
    }

    public GridObject GetPassedObject() 
    {
        return passedObject;
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

    public abstract bool Equals(GridObject otherObject);
}
