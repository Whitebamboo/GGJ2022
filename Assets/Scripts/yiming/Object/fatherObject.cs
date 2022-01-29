using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class fatherObject : GridObject
{
    public bool isLeft = true;
    public float speed = 10;
    public float threshold = 0.02f;
    public bool isChangeWithTime = false;//will it be interactive with time, false : not interactive,true: can interactive
    public int age = 0;//it's age change by player's step

    private bool isMove = false;
    private Vector3 startPoint = Vector3.zero;
    private Vector3 endPoint = Vector3.zero;
    private Rigidbody rigidbody;


    // Start is called before the first frame update
    void Start()
    {
        rigidbody = this.GetComponent<Rigidbody>();
        //EventBus.AddListener<Vector3, Vector3>(EventTypes.Move, StartMove);
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);

    }
    private void OnDestroy()
    {
        //EventBus.RemoveListener<Vector3, Vector3>(EventTypes.Move, StartMove);
        EventBus.RemoveListener<bool>(EventTypes.TimeMove, TimeChange);

    }
    private void Update()
    {
        Move();
    }
    public void StartMove(Vector3 startPoint_, Vector3 endPoint_)//left =  true ,right = false
    {
        isMove = true;
        startPoint = startPoint_;
        endPoint = endPoint_;
    }

    public override void MoveTo(Vector3 endPoint_)//left =  true ,right = false
    {
        isMove = true;
        startPoint = transform.position;
        endPoint = endPoint_;
    }

    private void Move()
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
        if (leftRight == isLeft && isChangeWithTime)
        {
            if (isLeft)
            {
                age++;
            }
            else
            {
                age--;
                age = Mathf.Max(age, 0);
            }
        }
    }

    /// <summary>
    /// player use A to interactive
    /// </summary>
    private void interactive()
    {

    }
}
