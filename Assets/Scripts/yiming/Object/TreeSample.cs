using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class TreeSample : fatherObject
{
    Animator animator;


    private void OnEnable()
    {
        isChangeWithTime = true;
        animator = this.GetComponent<Animator>();
        animator.SetInteger("State", currentState);
    }


    private void Update()
    {
        ChangeState();
    }

    private void ChangeState()
    {
        if (currentState + 1 < stateLists.Count)
        {
            if (isForward)
            {
                if(age >= stateLists[currentState + 1].ageThreshold)
                {
                    currentState = stateLists[currentState + 1].state;
                    animator.SetInteger("State", currentState);
                    animator.SetFloat("Speed", 1f);
                }
            }
        }
        if (currentState -1 >= 0)//����ֻҪ��һ����,�Ϳ����õ�����������
        {
            if (!isForward)
            {
                if (age <= stateLists[currentState - 1].ageThreshold)
                {
                    currentState = stateLists[currentState - 1].state;
                    animator.SetInteger("State", currentState);
                    animator.SetFloat("Speed", -1f);
                }
            }
        }
    }

    public override bool Equals(GridObject otherObject) 
    {
        TreeSample otherTreeComponent = otherObject.GetComponent<TreeSample>();
        if (otherTreeComponent == null) return false;

        return otherTreeComponent.currentState == currentState;
    }
}
