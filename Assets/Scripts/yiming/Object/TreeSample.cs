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
    }


    private void Update()
    {
        ChangeState();
    }
    private void ChangeState()
    {
       
       
        if (currentState + 1 < stateLists.Count)
        {
            if (isLeft)
            {
                if(age >= stateLists[currentState + 1].ageThreshold)
                {
                    currentState = stateLists[currentState + 1].state;
                    animator.SetInteger("State", currentState);
                    animator.SetFloat("Speed", 1f);
                }
            }
        }
        if (currentState -1 >= 0)//这样只要配一个树,就可以用到正反两面了
        {
            if (!isLeft)
            {
                if (age >= stateLists[currentState - 1].ageThreshold)
                {
                    currentState = stateLists[currentState - 1].state;
                    animator.SetInteger("State", currentState);
                    animator.SetFloat("Speed", -1f);
                }
            }
        }
         
        
    
    }
}
