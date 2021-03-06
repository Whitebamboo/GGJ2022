using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
[RequireComponent(typeof(Rigidbody))]
public abstract class fatherObject : GridObject
{
    public List<State> stateLists = new List<State>();
    public int currentState {
        set {
            if (_currentState != value) {
                _currentState = value;

                Animator anim = GetComponent<Animator>();
                if (anim) anim.SetTrigger("ChangeState");
            }
        }
        get {
            return _currentState;
        }
    } //a pointer to State ,will be the same as State.state

    private int _currentState = 0;

    public bool isCycle = false;//can this object  can cycle in the state 
    public float speed = 10;
    public float threshold = 0.02f;
    public bool isChangeWithTime = false;//will it be interactive with time, false : not interactive,true: can interactive
    public int age = 0;//it's age change by player's step

    private bool isMove = false;
    private Vector3 startPoint = Vector3.zero;
    private Vector3 endPoint = Vector3.zero;
    private Rigidbody rb;
    private Sequence mySequence;
    
    // Start is called before the first frame update
    public void Awake()
    {
        mySequence = DOTween.Sequence();
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
            //EventBus.Broadcast<GameObject,bool,(int,int)>(EventTypes.DeadRecord, gameObject, isForward,gridController.objectMapping[gameObject]);
            mySequence.Kill();
            gameObject.transform.localPosition = new Vector3(5, -5, -22);
            gameObject.transform.SetParent(null);
            EventBus.RemoveListener<bool>(EventTypes.TimeMove, TimeChange);

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
        Move();
    }

    public void Move()
    {
        if (isMove)
        {
            mySequence = DOTween.Sequence();
            mySequence.Append(transform.DOMove(endPoint, 1f).SetEase(Ease.OutCubic).OnComplete(()=> {
                isMove = false;
                EventBus.Broadcast(EventTypes.Reach, this.gameObject);
            }));
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
        if (stateLists.Count == 0) return;

        for (int i = 0; i < stateLists.Count - 1; i++) {
            if (age >= stateLists[i].ageThreshold && age < stateLists[i+1].ageThreshold) {
                currentState = stateLists[i].state;
            }
        }
        if (age >= stateLists[stateLists.Count - 1].ageThreshold) 
        {
            currentState = stateLists[stateLists.Count - 1].state;
        }
    }

    public override void RestoreObject()
    {
        base.RestoreObject();
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);
    }
   
    /// <summary>
    /// change object's state and call the animator 
    /// </summary>
    public void ChangeState(Animator animator)
    {
        int offset = (stateLists[stateLists.Count - 1].ageThreshold - stateLists[0].ageThreshold) / Mathf.Max(stateLists.Count-1,0);
        if (isCycle) {
            age = age % stateLists[stateLists.Count - 1].ageThreshold;
        }

        SetState();
    }
}
