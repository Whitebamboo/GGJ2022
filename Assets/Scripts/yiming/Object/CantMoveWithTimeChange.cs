using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Animator))]
public class CantMoveWithTimeChange : fatherObject
{
    //Object that can't move with time change

    public Animator animator;

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

    public override void SetState()
    {
        base.SetState();
        animator = this.GetComponent<Animator>();
        animator.SetInteger("State", currentState);
        animator.SetFloat("Speed", isForward ? 1f : -1f);
    }
}
