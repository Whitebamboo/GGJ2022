using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeBack : MonoBehaviour
{
    public RecordAndUndo leftRecorde;
    public bool rightWait = true;
    public bool leftWait = false;
    public RecordAndUndo rightRecorde;

    public List<bool> undoSuccess = new List<bool>();
   
       
    //when player defeat turn back the whole game
    private void Start()
    {
        EventBus.AddListener(EventTypes.LevelLost, BackWardStart);
        EventBus.AddListener<bool>(EventTypes.SuccessFullyUndo, ResetLevel);
    }
    private void OnDestroy()
    {
        EventBus.RemoveListener(EventTypes.LevelLost, BackWardStart);
        EventBus.RemoveListener<bool>(EventTypes.SuccessFullyUndo, ResetLevel);

    }
    public void BackWardStart()
    {
        print("startBackward");
        StartCoroutine(StarBackward());

     
    }

    IEnumerator StarBackward()
    {
        yield return new WaitForSeconds(.2f);
        print("startBackward1");
        BackWard();

    }
    public void BackWard()
    {
        leftRecorde.BackUndo(true);
        rightRecorde.BackUndo(false);
 
    }
    public void ResetLevel(bool success)
    {
        GameManager GM = (GameManager)FindObjectOfType(typeof(GameManager));
        
        undoSuccess.Add(success);
        print(GM.levels[GM.currentLevel].TotalTime);
        print(undoSuccess.Count);
        if(undoSuccess.Count >= GM.levels[GM.currentLevel].TotalTime+2)
        {
            print("success reset");
            undoSuccess.Clear();
            GM.ResetLevel();
        }
    }


}
