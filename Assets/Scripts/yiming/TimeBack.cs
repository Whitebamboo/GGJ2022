using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeBack : MonoBehaviour
{
    public RecordAndUndo leftRecorde;
    public bool rightWait = true;
    public bool leftWait = false;
    public RecordAndUndo rightRecorde;
    //when player defeat turn back the whole game
    private void Start()
    {
        EventBus.AddListener(EventTypes.LevelLost, BackWardStart);
        EventBus.AddListener<bool>(EventTypes.SuccessFullyUndo, WaitUntilLastAnime);
    }
    private void OnDestroy()
    {
        EventBus.RemoveListener(EventTypes.LevelLost, BackWardStart);
        EventBus.RemoveListener<bool>(EventTypes.SuccessFullyUndo, WaitUntilLastAnime);
    }
    public void BackWardStart()
    {
        StartCoroutine(StarBackward());

     
    }

    IEnumerator StarBackward()
    {
        yield return new WaitForSeconds(5f);
        BackWard();

    }
    public void BackWard()
    {
        while (leftRecorde.recorders.Count > 0 || rightRecorde.recorders.Count > 0)
        {
            if (leftRecorde.recorders.Count > 0 && leftWait)
            {
                leftWait = false;
                leftRecorde.Undo(true);
            }
            if (rightRecorde.recorders.Count > 0 && rightWait)
            {
                rightWait = false;
                rightRecorde.Undo(false);
            }

        }
        print("successfully undo the whole level");
    }

    public void WaitUntilLastAnime(bool leftright)
    {
        if (leftright)
        {
            leftWait = true;
        }
        else
        {
            rightWait = true;
        }
    }
}
