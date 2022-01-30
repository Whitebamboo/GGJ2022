using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum EventTypes
{
    Reach, //when object reach their move target point
    TimeMove, //when player move one step
    TimeMoveEnd, //when player finishes moving one step
    PlayerAction, // called when player attempts to perform an action (move, action, etc.)
    PlayerPush, // called when player is trying to push something
    Create,//when new object is creating
    Destroy,//when old object is destroy
    PlayerReachTarget,//when player reach the final target 
    PlayerLeaveTarget,//when player leave the final target 
    StopAll, // called to stop everything
    GridRecord,//to record grid info mation
    DeadRecord,//when body dead record the info
    CreateRecord,//when body creat record the info 
    ShowSeedHint,
    CloseSeedHint,
    UndoLastMove,
    LevelComplete,
    RestartLevel,
    LevelLost,
    SuccessFullyUndo,
}
