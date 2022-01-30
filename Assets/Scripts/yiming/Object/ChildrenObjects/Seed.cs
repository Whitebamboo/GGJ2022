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
        EventBus.Broadcast<GameObject, bool, (int, int)>(EventTypes.DeadRecord, gameObject, isForward, gridController.objectMapping[this.gameObject]);
        EventBus.Broadcast(EventTypes.Create, go, gameObject);
        EventBus.Broadcast(EventTypes.Destroy, gameObject);
    }

    public override bool Equals(GridObject otherObject)
    {
        return otherObject.GetComponent<Seed>() != null;
    }
}
