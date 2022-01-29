using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SeedSample : fatherObject
{
    public GameObject treePrefab;

    public override void interactive()
    {
        base.interactive();
        GameObject go =  GameObject.Instantiate(treePrefab, this.transform.position, Quaternion.identity);
        EventBus.Broadcast(EventTypes.Create, go, this.gameObject);
        EventBus.Broadcast(EventTypes.Destroy, this.gameObject);
        Destroy(this.gameObject, .1f);
    }

    public override bool IsPushable() {
        return true;
    }

    public override bool Equals(GridObject otherObject) 
    {
        return otherObject.GetComponent<SeedSample>() != null;
    }
}
