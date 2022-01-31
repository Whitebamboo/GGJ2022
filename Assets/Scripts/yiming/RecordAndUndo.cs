using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordAndUndo : MonoBehaviour
{
    [System.Serializable]
    public class ScreenShot
    {
        public int step;
        public GridSpaceRecoder[,] grids;
        public List<DeadBody> deadBodies = new List<DeadBody>();
        public List<CreatBody> creatBodies = new List<CreatBody>();

        public override string ToString() {
            return $"Step: {step}, # dead bodies: {deadBodies.Count}, # create bodies: {creatBodies.Count}\n";
        }
    }

    public bool isForward = true;
    public Stack<ScreenShot> recorders = new Stack<ScreenShot>();
    public GridController gridController;
    GameManager gameManager;

    /// <summary>
    /// clear all record
    /// </summary>
    public void ClearRecord()
    {
        foreach (ScreenShot ss in recorders) {
            foreach (DeadBody body in ss.deadBodies) {
                Destroy(body.deadObject);
            }
        }
        recorders.Clear();
    }

    private void Start()
    {
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();

        EventBus.AddListener<GridSpaceController[,],bool>(EventTypes.GridRecord, GridRecord);
        EventBus.AddListener<GameObject,bool,(int,int)>(EventTypes.DeadRecord, DeadRecord);
        EventBus.AddListener<GameObject,GameObject,bool,(int,int)>(EventTypes.CreateRecord, CreateRecord);
        EventBus.AddListener(EventTypes.RestartLevel, ClearRecord);
        EventBus.AddListener<bool>(EventTypes.UndoLastMove, Undo);
    }
    private void OnDestroy()
    {
        EventBus.RemoveListener<GridSpaceController[,], bool>(EventTypes.GridRecord, GridRecord);
        EventBus.RemoveListener<GameObject, bool, (int, int)>(EventTypes.DeadRecord, DeadRecord);
        EventBus.AddListener<GameObject,GameObject,bool,(int,int)>(EventTypes.CreateRecord, CreateRecord);
        EventBus.RemoveListener(EventTypes.RestartLevel, ClearRecord);
        EventBus.RemoveListener<bool>(EventTypes.UndoLastMove, Undo);
    }


    /// <summary>
    /// Perform a recording of the entire grid before the player takes a step,
    /// such as pushing or moving. Should record the state of the board
    /// before the time step
    /// </summary>
    /// <param name="grids"></param>
    /// <param name="leftright"></param>
    public void GridRecord(GridSpaceController[,] grids, bool leftright)
    {
        int step = gameManager.GetStep(leftright); // Gets the current step of the board

        if (isForward == leftright)
        {
            ScreenShot ss = new ScreenShot();
            ss.step = step;
            //put info into record
            GetInfoinGrids(ss, grids);
            recorders.Push(ss);
        }
    }

    /// <summary>
    /// Stores the death of an object
    /// </summary>
    /// <param name="go"></param>
    /// <param name="leftright"></param>
    /// <param name="position"></param>
    public void DeadRecord(GameObject go, bool leftright,(int,int) position)
    {
        int step = gameManager.GetStep(leftright); // Gets the current step of the board

        if (isForward == leftright)
        {
            ScreenShot ss = new ScreenShot();
            ss.step = step;
            recorders.Push(ss);
            GetInfoFromDead(ss, go, position);
        }
    }

    /// <summary>
    /// Stores the creation of an object
    /// </summary>
    /// <param name="parent"></param>
    /// <param name="go"></param>
    /// <param name="leftright"></param>
    /// <param name="position"></param>
    public void CreateRecord(GameObject parent,GameObject go, bool leftright, (int, int) position)
    {
        int step = gameManager.GetStep(leftright);

        if (isForward == leftright)
        {
            ScreenShot ss = new ScreenShot();
            ss.step = step;
            recorders.Push(ss);
            GetInfoFromCreate(ss, go, position);
            GetInfoFromDead(ss, parent, position);
        }
    }


    private void GetInfoFromCreate(ScreenShot ss, GameObject go, (int, int) grid)
    {
        if (ss.creatBodies == null)
        {
            ss.creatBodies = new List<CreatBody>();
        }
        CreatBody cb = new CreatBody();
        cb.getCreatInformation(go, grid);
        ss.creatBodies.Add(cb);
    }

    private void GetInfoFromDead(ScreenShot ss,GameObject go,(int,int)grid)
    {
        if (ss.deadBodies == null)
        {
            ss.deadBodies = new List<DeadBody>();
        }
        DeadBody db = new DeadBody();
        db.getdeadInfomation(go,grid);
        ss.deadBodies.Add(db);
    }

    private void GetInfoinGrids(ScreenShot ss,GridSpaceController[,] grids)
    {
        int row = grids.GetLength(0);
        int col = grids.GetLength(1);

        ss.grids = new GridSpaceRecoder[row, col];

        for (int i = 0; i < row; i++)
        {
            for (int j = 0; j < col; j++)
            {
                ss.grids[i, j] = new GridSpaceRecoder();
                if(grids[i,j].GetObject() != null)
                {
                    GridObject go = grids[i, j].GetObject();

                    ss.grids[i, j].SetEmpty(false);
                    ss.grids[i, j].SetObject(go.gameObject.name);
                    ss.grids[i, j].StoreInfo(go.gameObject);
                }
                else
                {
                    ss.grids[i, j].isEmpty = true;
                }
            }
        }
    }

    /// <summary>
    /// Run when undo is pressed, should undo everything to the previous step
    /// </summary>
    public void Undo(bool leftright)
    {
        int step = gameManager.GetStep(leftright); // Gets the current step
        // We need to revert to one step before

        if(isForward == leftright)
        {
            
            while (recorders.Count > 0 && recorders.Peek().step >= step - 1) 
            {
                ScreenShot ss = recorders.Pop();
                if (ss.creatBodies != null && ss.creatBodies.Count > 0)
                {
                    UndoCreate(ss.creatBodies);
                }
                if (ss.deadBodies != null && ss.deadBodies.Count > 0 )
                {
                    UndoDeadBodies(ss.deadBodies);
                }
                UndoGrids(ss);
            }
            gameManager.UndoTimeChange(isForward);
            EventBus.Broadcast(EventTypes.SuccessFullyUndo, leftright);
        }
    }

    /// <summary>
    /// for all back ward
    /// </summary>
    /// <param name="leftright"></param>
    public bool BackUndo(bool leftright)
    {
        if (recorders.Count > 0)
        {
            Undo(isForward);
            StartCoroutine(BigBackWard(leftright));
        }
        else
        {
            EventBus.Broadcast(EventTypes.SuccessFullyUndo, true);
            ClearRecord();
        }

        return false;
           
            
        
    }

    IEnumerator BigBackWard(bool backward)
    {
        yield return new WaitForSeconds(.6f);
        BackUndo(backward);
    }



    private void UndoCreate(List<CreatBody> cbList)
    {
        if (cbList.Count > 0)
        {
            for(int i=0; i< cbList.Count; i++)
            {
                (int, int) creatPoint = cbList[i].grid;
                gridController.SetPositionObject(creatPoint.Item1, creatPoint.Item2, null);
                gridController.objectMapping.Remove(cbList[i].creatBody);
                Destroy(cbList[i].creatBody);

            }
        }
    }


    private void UndoDeadBodies(List<DeadBody> dbList)
    {
        if(dbList.Count>0)
        {
            for(int i=0; i< dbList.Count; i++)
            {
                (int,int) creatPoint = dbList[i].grid;

                GameObject deadObj = dbList[i].deadObject;
                deadObj.transform.position = gridController.GetPosition(creatPoint.Item1, creatPoint.Item2);
                gridController.SetPositionObject(creatPoint.Item1, creatPoint.Item2, deadObj.GetComponent<GridObject>());
                gridController.objectMapping[deadObj] = (creatPoint.Item1, creatPoint.Item2);
                deadObj.GetComponent<GridObject>().RestoreObject();
                deadObj.GetComponent<fatherObject>().SetAge(deadObj.GetComponent<fatherObject>().age - 1);
            }
        }
    }

    private void UndoGrids(ScreenShot ss)
    {
        int row = 0;
        int col = 0;
        if(ss.grids != null) {
           row = ss.grids.GetLength(0);
           col = ss.grids.GetLength(1);
        }
     
        for(int i = 0; i < row; i++)
        {
            for(int j = 0; j < col; j++)
            {
                if (!ss.grids[i, j].isEmpty)
                {
                    if(ss.grids[i,j].t == "Player")
                    {
                        GameObject go = GameObject.Find(ss.grids[i, j].GetObject());
                        // print("go.name" + go.name);
                        (int, int) pasPos = gridController.objectMapping[go];
                        PlayerController player = go.GetComponent<PlayerController>();
                        Vector3 targetPosition = gridController.GetPosition(i, j);
                        if (gridController.GetPositionObject(pasPos.Item1, pasPos.Item2) == player) {
                            gridController.SetPositionObject(pasPos.Item1, pasPos.Item2, null);
                        }
                        player.MoveTo(targetPosition,true);

                        gridController.SetPositionObject(i, j, go.GetComponent<GridObject>());
                        gridController.objectMapping[go] = (i, j);
                    }
                    else //if(ss.grids[i, j].t == "Object")
                    {
                        GameObject go = GameObject.Find(ss.grids[i, j].GetObject());
                        //print("find object" + go.name);

                        if (gridController.objectMapping.TryGetValue(go,out(int, int) paspos))
                        {
                            if(paspos != (i, j))
                            {
                                // print("move" + go.name + "from" + paspos + " to " + (i, j));
                                Vector3 targetPosition = gridController.GetPosition(i, j);
                                fatherObject fo = go.GetComponent<fatherObject>();
                                if (gridController.GetPositionObject(paspos.Item1, paspos.Item2) == fo)
                                {
                                    gridController.SetPositionObject(paspos.Item1, paspos.Item2, null);
                                }
                                fo.MoveTo(targetPosition);

                                gridController.SetPositionObject(i, j, go.GetComponent<GridObject>());
                                gridController.objectMapping[go] = (i, j);
                               
                            }
                            if (ss.grids[i, j].haveState)
                            {
                                go.GetComponent<fatherObject>().age = ss.grids[i, j].age;
                                go.GetComponent<fatherObject>().currentState = ss.grids[i, j].state;
                            }
                        }
                    }

                }
            }
        }
    }
}
