using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Seed : MoveWithoutTimeChange
{
    public GameObject treePrefab;

 


    public override void interactive()
    {
        base.interactive();
        GameObject go = GameObject.Instantiate(treePrefab, this.transform.position, Quaternion.identity);
        EventBus.Broadcast(EventTypes.Create, go, this.gameObject);
        EventBus.Broadcast(EventTypes.Destroy, this.gameObject);
        Destroy(this.gameObject, .1f);
    }
}
