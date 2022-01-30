using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetPoint : fatherObject
{
    public override void MoveTo(Vector3 newPosition)
    {
        throw new System.NotImplementedException();
    }

    private void OnTriggerEnter(Collider other)
    {
        //when player reach point
        if(other.tag == "Player")
        {
            PlayerController player = other.gameObject.GetComponent<PlayerController>();
            print("reach target");
            EventBus.Broadcast(EventTypes.PlayerReachTarget, player.isForward);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        //when player leaves point
        if(other.tag == "Player")
        {
            PlayerController player = other.gameObject.GetComponent<PlayerController>();
            print("leave target");
            EventBus.Broadcast(EventTypes.PlayerLeaveTarget, player.isForward);
        }
    }

    public override bool IsPassable() {
        return true;
    }

    public override bool Equals(GridObject otherObject) 
    {
        return otherObject.GetComponent<TargetPoint>() != null;
    }
}
