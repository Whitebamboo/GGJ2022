using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EventTypes
{
    Reach, //when object reach their move target point
    TimeMove, //when player move one step
    Create,//when new object is creating
    Destroy,//when old object is destroy
}
