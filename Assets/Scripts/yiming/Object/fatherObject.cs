using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(Rigidbody))]
public abstract class fatherObject : GridObject
{
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
    private Rigidbody rb;

   
    
    // Start is called before the first frame update
    void Awake()
    {
        rb = this.GetComponent<Rigidbody>();
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);
        EventBus.AddListener<GameObject>(EventTypes.Destroy, DestroySelf);
        // print("add event Timemove");
    }
    private void OnDestroy()
    {
        //EventBus.RemoveListener<Vector3, Vector3>(EventTypes.Move, StartMove);
        EventBus.RemoveListener<bool>(EventTypes.TimeMove, TimeChange);
        EventBus.RemoveListener<GameObject>(EventTypes.Destroy, DestroySelf);
    }
   
    void DestroySelf(GameObject objToDestroy) 
    {
        if (objToDestroy == gameObject) {
            // Don't actually destroy - might undo
            EventBus.Broadcast<GameObject,bool>(EventTypes.DeadRecord, gameObject, isForward);
            gameObject.SetActive(false);

            // Destroy(gameObject);
        }
    }

    public override void SetAge(int age) {
        this.age = age;
        SetState();
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
            rb.MovePosition(rb.transform.position + dir * speed * Time.deltaTime);
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

    public virtual void SetState()
    {
        Debug.Log("Age: " + age);
        for (int i = 0; i < stateLists.Count - 1; i++) {
            Debug.Log($"curr: {stateLists[i].ageThreshold}, next: {stateLists[i+1].ageThreshold}");
            if (age >= stateLists[i].ageThreshold && age < stateLists[i+1].ageThreshold) {
                currentState = stateLists[i].state;
            }
        }
        if (age >= stateLists[stateLists.Count - 1].ageThreshold) 
        {
            currentState = stateLists[stateLists.Count - 1].state;
        }
        Debug.Log("Current state: " + currentState);
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
                    if (animator)
                    {
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", 1f);
                    }
                }
            }
            else
            {
                if (age >= stateLists[stateLists.Count - 1].ageThreshold +offset && isCycle)
                {
                    currentState = 0;
                    age = 0;
                    if (animator)
                    {
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", 1f);
                    }
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
                    if (animator)
                    {
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", -1f);
                    }
                }
            }
            else
            {
                if (age <= stateLists[0].ageThreshold- offset && isCycle)
                {
                    currentState = stateLists.Count-1;
                    age = stateLists[stateLists.Count-1].ageThreshold;
                    if (animator)
                    {
                        animator.SetInteger("State", currentState);
                        animator.SetFloat("Speed", -1f);
                    }
                }
            }
        }
    }
}
