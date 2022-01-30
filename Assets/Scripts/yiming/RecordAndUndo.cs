using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RecordAndUndo : MonoBehaviour
{
    
    public class ScreenShot
    {
        public int step;
        public GridSpaceRecoder[,] grids;
        public List<DeadBody> deadBodies;
    }

    public bool isForward = true;
    public Stack<ScreenShot> recorders = new Stack<ScreenShot>();
    public GridController gridController;
    GameManager gameManager;
   

    private void Start()
    {
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
        EventBus.AddListener<GridSpaceController[,],bool>(EventTypes.GridRecord, GridRecord);
        EventBus.AddListener<GameObject,bool>(EventTypes.DeadRecord, DeadRecord);
        EventBus.AddListener<bool>(EventTypes.UndoLastMove, Undo);
    }
    private void OnDestroy()
    {
        EventBus.RemoveListener<GridSpaceController[,], bool>(EventTypes.GridRecord, GridRecord);
        EventBus.RemoveListener<GameObject, bool>(EventTypes.DeadRecord, DeadRecord);
    }
    /// <summary>
    /// record before player start the new step like player make step one and record
    /// </summary>
    /// <param name="step"></param>
    /// <param name="grids"></param>
    /// <param name="leftright"></param>
    public void GridRecord(GridSpaceController[,] grids, bool leftright)
    {
        int step = gameManager.GetStep(leftright);
        if(isForward == leftright)
        {
            if (step + 1 > recorders.Count)
            {
                ScreenShot ss = new ScreenShot();
                ss.step = step;
                //put info into record
                GetInfoinGrids(ss, grids);
                recorders.Push(ss);
            }
            else
            {
                //put info into this step
                ScreenShot ss = recorders.Peek();
                GetInfoinGrids(ss, grids);
            }
        }
        
    }

    public void DeadRecord(GameObject go, bool leftright)
    {
        int step = gameManager.GetStep(leftright);
        if(isForward == leftright)
        {
            if (step+1 > recorders.Count)
            {  
                ScreenShot ss = new ScreenShot();
                ss.step = step;
                recorders.Push(ss);
                GetInfoFromDead(ss, go);
            }
            else
            {
                ScreenShot ss = recorders.Peek();
                GetInfoFromDead(ss, go);
            }
        }   
    }

    private void GetInfoFromDead(ScreenShot ss,GameObject go)
    {
        if(ss.deadBodies == null)
        {
            ss.deadBodies = new List<DeadBody>();
        }
        DeadBody db = new DeadBody();
        db.getdeadInfomation(go);
        ss.deadBodies.Add(db);
    }

    private void GetInfoinGrids(ScreenShot ss,GridSpaceController[,] grids)
    {
        int row = grids.Rank;
        int col = grids.GetLength(1);
        ss.grids = new GridSpaceRecoder[row, col];
        for (int i = 0; i < row; i++)
        {
            for (int j = 0; j < col; j++)
            {
                if(grids[i,j].GetObject() != null)
                {
                    GridObject go = grids[i, j].GetObject();
                    ss.grids[i, j].isEmpty = false;
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
    /// when press the button undo
    /// </summary>
    public void Undo(bool leftright)
    {
        List<DeadBody> temperarylist = new List<DeadBody>();
        int step = gameManager.GetStep(leftright);
        if(isForward == leftright)
        {
            if (recorders.Count > 0)
            {
                ScreenShot ss = recorders.Pop();
                if(ss.step == step)//first bring the dead one alive and then pop another one if this is the current step
                {
                    if (ss.deadBodies.Count > 0)
                    {
                        temperarylist = ss.deadBodies;
                    }
                    ss = recorders.Pop();
                    UndoGrids(ss);
                    if (temperarylist .Count > 0)
                    {
                        UndoDeadBodies(temperarylist);
                    }
                    if(ss.deadBodies.Count > 0)
                    {
                        ScreenShot newss = new ScreenShot();
                        newss.step = step - 1;
                        newss.deadBodies = ss.deadBodies;
                        recorders.Push(newss);
                    }
                  
                }
                else
                {
                    UndoGrids(ss);
                    if(ss.deadBodies.Count > 0)
                    {
                        ScreenShot newss = new ScreenShot();
                        newss.step = step - 1;
                        newss.deadBodies = ss.deadBodies;
                        recorders.Push(newss);
                    }
                }
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
                dbList[i].gameObject.transform.position = gridController.GetPosition(creatPoint.Item1, creatPoint.Item2);

            }
        }
    }

    private void UndoGrids(ScreenShot ss)
    {
        int row = ss.grids.Rank;
        int col = ss.grids.GetLength(1);
        for(int i = 0; i < row; i++)
        {
            for(int j = 0; j < col; j++)
            {
                if (!ss.grids[i, j].isEmpty)
                {
                    if(ss.grids[i,j].t == "Player")
                    {
                        GameObject go = GameObject.Find(ss.grids[i, j].GetObject());
                        (int, int) pasPos = gridController.objectMapping[go];
                        PlayerController player = go.GetComponent<PlayerController>();
                        Vector3 targetPosition = gridController.GetPosition(i, j);
                        gridController.SetPositionObject(pasPos.Item1, pasPos.Item2, null);
                        player.MoveTo(targetPosition);

                        gridController.SetPositionObject(i, j, go.GetComponent<GridObject>());
                        gridController.objectMapping[go] = (i, j);
                    }
                    else
                    {
                        GameObject go = GameObject.Find(ss.grids[i, j].GetObject());
                        (int, int) pasPos = gridController.objectMapping[go];
                        Vector3 targetPosition = gridController.GetPosition(i, j);
                        fatherObject fo = go.GetComponent<fatherObject>();
                        gridController.SetPositionObject(pasPos.Item1, pasPos.Item2, null);
                        fo.MoveTo(targetPosition);
                        
                        gridController.SetPositionObject(i, j, go.GetComponent<GridObject>());
                        gridController.objectMapping[go] = (i, j);
                        if (ss.grids[i, j].haveState)
                        {
                            go.GetComponent<fatherObject>().currentState = ss.grids[i, j].age;
                            go.GetComponent<fatherObject>().currentState = ss.grids[i, j].state;
                        }
                    }
                   
                }
            }
        }
    }

}
