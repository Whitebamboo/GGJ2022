using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EventTypes
{
    Move,           // Called when an object (rock) is moved
    PlayerMove,     // Broadcast when a player takes a step, TODO: split by character?
}
