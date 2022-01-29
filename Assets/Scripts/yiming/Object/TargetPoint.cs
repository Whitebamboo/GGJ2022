using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetPoint : GridObject
{
    public override void MoveTo(Vector3 newPosition)
    {
        throw new System.NotImplementedException();
    }

    private void OnTriggerEnter(Collider other)
    {
        //when player reach point if it at left info 1 at right info 2
        if(other.tag == "Player")
        {
            PlayerController player = other.gameObject.GetComponent<PlayerController>();
            if (player.isForward)
            {
                EventBus.Broadcast(EventTypes.PlayerReachTarget, 1);
                print("reach target");
            }
            else
            {
                EventBus.Broadcast(EventTypes.PlayerReachTarget, 2);
            }
            
        }

    }
}
