using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Animator))]
public class CantMoveWithTimeChange : fatherObject
{
    //Object that can't move with time change

    Animator animator;

    public override bool Equals(GridObject otherObject)
    {
        throw new System.NotImplementedException();
    }

    private void Start()
    {
        isChangeWithTime = true;
        animator = this.GetComponent<Animator>();
        animator.SetInteger("State", currentState);
    }


    private void Update()
    {
        ChangeState(animator);
    }
}
