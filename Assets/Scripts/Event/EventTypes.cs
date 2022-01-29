using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EventTypes
{

    PlayerMove,     // Broadcast when a player takes a step, TODO: split by character?
    Reach, //when object reach their move target point
    TimeMove, //when player move one step
}
