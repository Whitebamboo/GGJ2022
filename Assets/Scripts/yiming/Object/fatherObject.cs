using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Rigidbody))]
public abstract class fatherObject : GridObject
{
    [System.Serializable]
    /// <summary>
    /// use to fill the state of object base on age
    /// </summary>
    public struct State
    {
        public int ageThreshold;// left: age need to >= ageThreshold than the state will change
                         // right:age need to <= ageThreshold than the state will change
        public int state;// make sure right and lefts
    }
    public List<State> stateLists = new List<State>();
    public int currentState = 0;//a pointer to State ,will be the same as State.state

   
    public bool isCycle = false;//can this object  can cycle in the state 
    public float speed = 10;
    public float threshold = 0.02f;
    public bool isChangeWithTime = false;//will it be interactive with time, false : not interactive,true: can interactive
    public int age = 0;//it's age change by player's step

    private bool isMove = false;
    private Vector3 startPoint = Vector3.zero;
    private Vector3 endPoint = Vector3.zero;
    private Rigidbody rigidbody;

    private int startState;
    private int startAge;
    
    // Start is called before the first frame update
    void Awake()
    {
        rigidbody = this.GetComponent<Rigidbody>();
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);
        // print("add event Timemove");
        startState = currentState;
        startAge = age;

    }
    private void OnDestroy()
    {
        //EventBus.RemoveListener<Vector3, Vector3>(EventTypes.Move, StartMove);
        EventBus.RemoveListener<bool>(EventTypes.TimeMove, TimeChange);

    }
   
 

    public override void MoveTo(Vector3 endPoint_)//left =  true ,right = false
    {
        isMove = true;
        startPoint = transform.position;
        endPoint = endPoint_;
    }

    public void Move()
    {
        if (isMove)
        {
            Vector3 dir = endPoint - startPoint;
            dir = Vector3.Normalize(dir);
            rigidbody.MovePosition(rigidbody.transform.position + dir * speed * Time.deltaTime);
            if (Vector3.Distance(transform.position, endPoint) < threshold)
            {
                transform.position = endPoint;
                isMove = false;
                EventBus.Broadcast(EventTypes.Reach, this.gameObject);//���Լ�����grid manager
            }
        }
    }
    /// <summary>
    /// true is left and false is right
    /// </summary>
    /// <param name="leftRight"></param>
    public void TimeChange(bool leftRight)
    {
        if (leftRight == isForward && isChangeWithTime)
        {
            if (isForward)
            {
                age++;
            }
            else
            {
                age--;
                
            }
        }
    }


   
    /// <summary>
    /// change object's state and call the animator 
    /// </summary>
    public void ChangeState(Animator animator)
    {
        int offset = (stateLists[stateLists.Count - 1].ageThreshold - stateLists[0].ageThreshold) / Mathf.Max(stateLists.Count-1,0);
            if (isForward)
            {
                if (currentState + 1 < stateLists.Count)
                {
                    if (age >= stateLists[currentState + 1].ageThreshold)
                    {
                        currentState = stateLists[currentState + 1].state;
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", 1f);
                    }
                }
                else
                {
                    if (age >= stateLists[stateLists.Count - 1].ageThreshold +offset && isCycle)
                    {
                        currentState = startState;
                        age = startAge;
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", 1f);
                    }
                }
            }
        
       
            if (!isForward)
            {
                if (currentState - 1 >= 0)//
                {
                    if (age <= stateLists[currentState - 1].ageThreshold)
                    {
                        currentState = stateLists[currentState - 1].state;
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", -1f);
                    }
                }
                else
                {
                    if (age <= stateLists[0].ageThreshold- offset && isCycle)
                    {
                        currentState = startState;
                        age = startAge;
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", -1f);
                    }
                }
            }
        
    }
}
