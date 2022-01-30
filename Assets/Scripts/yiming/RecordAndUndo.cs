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


    private void Start()
    {
        EventBus.AddListener<int, GridSpaceController[,],bool>(EventTypes.GridRecord, GridRecord);
        EventBus.AddListener<int, GameObject,bool>(EventTypes.DeadRecord, DeadRecord);
    }
    private void OnDestroy()
    {
        EventBus.RemoveListener<int, GridSpaceController[,], bool>(EventTypes.GridRecord, GridRecord);
        EventBus.RemoveListener<int, GameObject, bool>(EventTypes.DeadRecord, DeadRecord);
    }
    /// <summary>
    /// record before player start the new step like player make step one and record
    /// </summary>
    /// <param name="step"></param>
    /// <param name="grids"></param>
    /// <param name="leftright"></param>
    public void GridRecord(int step, GridSpaceController[,] grids, bool leftright)
    {
        if(isForward == leftright)
        {
            if (step > recorders.Count)
            {
                ScreenShot ss = new ScreenShot();
                recorders.Push(ss);
                //put info into record
                GetInfoinGrids(ss, grids);
            }
            else
            {
                //put info into this step
                ScreenShot ss = recorders.Peek();
                GetInfoinGrids(ss, grids);
            }
        }
        
    }

    public void DeadRecord(int step, GameObject go, bool leftright)
    {
        if(isForward == leftright)
        {
            if (step > recorders.Count)
            {
                ScreenShot ss = new ScreenShot();
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
            for (int j = 0; j < row; j++)
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
    public void Undo()
    {
        if (recorders.Count > 0)
        {
            ScreenShot ss = recorders.Pop();
        }
    }

}
