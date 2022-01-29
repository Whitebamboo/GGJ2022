using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GridObject : MonoBehaviour
{
    public abstract bool IsPushable();
    public abstract void MoveTo(Vector3 newPosition);
}
