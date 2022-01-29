using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EventTypes
{
    Reach, //when object reach their move target point
    TimeMove, //when player move one step
    PlayerAction, // called when player attempts to perform an action (move, action, etc.)
}
