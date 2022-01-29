using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GridObject : MonoBehaviour
{
    public virtual bool IsPushable() {
        return false;
    }
    public abstract void MoveTo(Vector3 newPosition);
}
