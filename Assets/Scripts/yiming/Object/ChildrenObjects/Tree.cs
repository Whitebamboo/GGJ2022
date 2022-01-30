using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tree : CantMoveWithTimeChange,CanbeIgnite
{
    public bool isIgnite = false;//if it is in the state of ignite

    MusicManager musicManager;

    private void Awake()
    {
        base.Awake();
        GameObject MM = GameObject.Find("MusicManager");
        if (MM) musicManager = MM.GetComponent<MusicManager>();
    }

    public bool canIgnite()
    {
        if (!isIgnite)
        {
            isIgnite = true;
            return true;
        }
        else
        {
            return false;
        }
    }

    public override void CrushAction(Direction dir)
    {
        base.CrushAction(dir);
        
        // Rotate by direction
        switch (dir)
        {
            case Direction.Up: 
                animator.SetTrigger("FallUp");
                break;
            case Direction.Down:
                animator.SetTrigger("FallDown");
                break;
            case Direction.Left:
                animator.SetTrigger("FallLeft");
                break;
            case Direction.Right:
                animator.SetTrigger("FallRight");
                break;
            default: break;
        }

        if (musicManager) musicManager.PlayTreeSnapSFX();
        Invoke(nameof(BroadcastDestroy), 1f);
    }

    void BroadcastDestroy() {
        EventBus.Broadcast(EventTypes.Destroy, gameObject);
    }

    public override bool IsCrushable() 
    {
        return currentState == 0;
    }

    public override void CrashAction() 
    {
        if (currentState == 4) {
            currentState = 3;
            ChangeState(animator);
        }
    }

    public override bool Equals(GridObject otherObject)
    {
        Tree otherTree = otherObject.GetComponent<Tree>();
        if (otherTree == null) return false;
        return currentState == otherTree.currentState;
    }
}
