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
        public List<DeadBody> deadBodies;
        public List<CreatBody> creatBodies;
    }

    public bool isForward = true;
    public Stack<ScreenShot> recorders = new Stack<ScreenShot>();
    public GridController gridController;
    GameManager gameManager;
   

    private void Start()
    {
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
        EventBus.AddListener<GridSpaceController[,],bool>(EventTypes.GridRecord, GridRecord);
        EventBus.AddListener<GameObject,bool,(int,int)>(EventTypes.DeadRecord, DeadRecord);
        EventBus.AddListener<GameObject,GameObject,bool,(int,int)>(EventTypes.CreateRecord, CreateRecord);
        EventBus.AddListener<bool>(EventTypes.UndoLastMove, Undo);
    }
    private void OnDestroy()
    {
        EventBus.RemoveListener<GridSpaceController[,], bool>(EventTypes.GridRecord, GridRecord);
        EventBus.RemoveListener<GameObject, bool, (int, int)>(EventTypes.DeadRecord, DeadRecord);
        EventBus.RemoveListener<bool>(EventTypes.UndoLastMove, Undo);
    }
    private void Update()
    {
        //print(recorders.Count);
    }
    /// <summary>
    /// record before player start the new step like player make step one and record
    /// </summary>
    /// <param name="step"></param>
    /// <param name="grids"></param>
    /// <param name="leftright"></param>
    public void GridRecord(GridSpaceController[,] grids, bool leftright)
    {
        //
        int step = gameManager.GetStep(leftright);
        if(isForward == leftright)
        {
            print("record Grid");
            if (step == recorders.Count)
            {
                
                ScreenShot ss = new ScreenShot();
                ss.step = step;//step = recorders.count = n-1
                //put info into record
                GetInfoinGrids(ss, grids);
                recorders.Push(ss);
            }
            else//step<recorders.count or step>
            {
                print(step);
                //put info into this step
                ScreenShot ss = recorders.Peek();
              
                GetInfoinGrids(ss, grids);
                print("do peek"+recorders.Peek().grids.GetLength(0));
            }
        }
        
    }

    public void DeadRecord(GameObject go, bool leftright,(int,int) grid)
    {
        
        int step = gameManager.GetStep(leftright);
       
        if (isForward == leftright)
        {
            print("get destroy info");
            if (step+1 == recorders.Count)
            {
                ScreenShot ss = new ScreenShot();
                ss.step = step+1;
                recorders.Push(ss);
                GetInfoFromDead(ss, go,grid);
            }
          
             
        }   
    }

    public void CreateRecord(GameObject parent, GameObject go, bool leftright, (int, int) grid)
    {

        int step = gameManager.GetStep(leftright);
        
        if (isForward == leftright)
        {
            print("recorders' count: "+recorders.Count);
            if (step == recorders.Count)
            {
                print(step);
            
                ScreenShot ss = new ScreenShot();
                ss.step = step;
                recorders.Push(ss);
                GetInfoFromDead(ss, parent, grid);
                GetInfoFromCreate(ss, go, grid);
                print("get creatobject info");
                print(ss.step);
            }


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
        if(ss.deadBodies == null)
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
                




                if(ss.step == step)//step = n at this step their have dead body
                {
                    if (ss.deadBodies.Count > 0)
                    {
                        temperarylist = ss.deadBodies;
                    }
                    if (ss.creatBodies.Count > 0)
                    {
                        UndoCreate(ss.creatBodies);
                    }
                    if (recorders.Count > 0)
                    {
                        ss = recorders.Pop();
                        UndoGrids(ss);
                    }
                   
                    
                    
                    if (temperarylist .Count > 0)
                    {
                       
                        UndoDeadBodies(temperarylist);
                    }
                    if(ss.deadBodies != null && ss.deadBodies.Count > 0)
                    {
                        ScreenShot newss = new ScreenShot();
                       
                        newss.step = step - 1;
                        newss.deadBodies = ss.deadBodies;
                        recorders.Push(newss);
                    }
                    if (ss.creatBodies != null && ss.creatBodies.Count > 0)
                    {
                        ScreenShot newss = new ScreenShot();
                       
                        newss.step = step - 1;
                        newss.creatBodies = ss.creatBodies;
                        recorders.Push(newss);
                    }

                }
                else
                {
                    print(step);
                    print(ss.step);
                    UndoGrids(ss);
                    if(ss.deadBodies != null && ss.deadBodies.Count > 0 )
                    {
                        ScreenShot newss = new ScreenShot();
                        newss.step = step - 1;
                        newss.deadBodies = ss.deadBodies;
                        recorders.Push(newss);
                    }
                }
                gameManager.UndoTimeChange(isForward);
            }
            
        }
        
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
              
                dbList[i].deadObject.transform.position = gridController.GetPosition(creatPoint.Item1, creatPoint.Item2);
                gridController.objectMapping[dbList[i].deadObject] = (creatPoint.Item1, creatPoint.Item2);
                gridController.SetPositionObject(creatPoint.Item1, creatPoint.Item2, dbList[i].deadObject.GetComponent<GridObject>());
            }
        }
    }

    private void UndoGrids(ScreenShot ss)
    {
    
        
        int row = ss.grids.GetLength(0);
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
                        player.MoveTo(targetPosition,true);
              
                        gridController.SetPositionObject(i, j, go.GetComponent<GridObject>());
                        gridController.objectMapping[go] = (i, j);
                    }
                    else //if(ss.grids[i, j].t == "Object")
                    {
                        GameObject go = GameObject.Find(ss.grids[i, j].GetObject());
                        print("find object" + go.name);

                        
                        if (gridController.objectMapping.TryGetValue(go,out(int, int) paspos))
                        {
                            if(paspos != (i, j))
                            {
                                print("move" + go.name + "from" + paspos + " to " + (i, j));
                                Vector3 targetPosition = gridController.GetPosition(i, j);
                                fatherObject fo = go.GetComponent<fatherObject>();
                                gridController.SetPositionObject(paspos.Item1, paspos.Item2, null);
                                fo.MoveTo(targetPosition);

                                gridController.SetPositionObject(i, j, go.GetComponent<GridObject>());
                                gridController.objectMapping[go] = (i, j);
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

}
