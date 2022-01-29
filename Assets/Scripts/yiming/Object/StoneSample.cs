using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class StoneSample : MonoBehaviour
{
    public float speed = 10;
    public float threshold = 0.02f;

    private bool isMove = false;
    private Vector3 startPoint = Vector3.zero;
    private Vector3 endPoint = Vector3.zero;
    private Rigidbody rigidbody;


    // Start is called before the first frame update
    void Start()
    {
        rigidbody = this.GetComponent<Rigidbody>();
        EventBus.AddListener<Vector3, Vector3, bool>(EventTypes.Move, StartMove);
    }

    private void Update()
    {
        Move();
    }
    public void StartMove(Vector3 startPoint_, Vector3 endPoint_, bool leftRight_)//left =  true ,right = false
    {
        isMove = true;
        startPoint = startPoint_;
        endPoint = endPoint_;
    }

    private void Move()
    {
      if(isMove)
        {
            Vector3 dir = startPoint - endPoint;
            dir = Vector3.Normalize(dir);
            rigidbody.MovePosition(rigidbody.transform.position + dir * speed * Time.deltaTime);
            if(Vector3.Distance(rigidbody.transform.position, endPoint) < threshold)
            {
                isMove = false;
            }
        }

    }
}
