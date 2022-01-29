using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public bool isForward = true;
    public SeedSample seed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonUp(1))
        {
            print("click mouse");
            EventBus.Broadcast(EventTypes.TimeMove, isForward);
        }
        if(Input.GetKeyDown(KeyCode.Space))
        {
            if (seed) { seed.interactive(); }
        }
    }
}
