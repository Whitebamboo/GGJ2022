using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EventTypes
{
    Reach, //when object reach their move target point
    TimeMove, //when player move one step
    PlayerAction, // called when player attempts to perform an action (move, action, etc.)
    Create,//when new object is creating
    Destroy,//when old object is destroy
    PlayerReachTarget,//when player reach the final target broadcast 
}
