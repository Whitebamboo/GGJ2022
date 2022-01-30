using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Animator))]
public class CantMoveWithTimeChange : fatherObject
{
    //Object that can't move with time change

    public Animator animator;
    public List<GameObject> states;

    public override bool Equals(GridObject otherObject)
    {
        throw new System.NotImplementedException();
    }

    private void Start()
    {
        isChangeWithTime = true;
        animator = this.GetComponent<Animator>();
        SetCurrentStateActive();
        animator.SetTrigger("ChangeState");
    }

    private void Update()
    {
        ChangeState(animator);
    }

    public void SetCurrentStateActive() {
        for (int i = 0; i < states.Count; i++) {
            states[i].SetActive(false);
        }
        states[currentState].SetActive(true);
    }

    public override void SetState()
    {
        base.SetState();
        animator = this.GetComponent<Animator>();
    }
}
