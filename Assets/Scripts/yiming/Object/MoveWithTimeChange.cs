using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Animator))]
public class MoveWithTimeChange : fatherObject
{

    //Object that can move with time change

    Animator animator;
    private void Start()
    {
        isChangeWithTime = true;
        animator = this.GetComponent<Animator>();
        animator.SetInteger("State", currentState);
    }


    private void Update()
    {
        Move();
        ChangeState(animator);
    }
}
