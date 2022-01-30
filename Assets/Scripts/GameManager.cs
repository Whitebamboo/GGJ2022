using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : CSingletonMono<GameManager>
{
    public List<LevelData> levels;

    public GridController leftGridController;
    public GridController rightGridController;

    public TimeSlider timerSlider;

    public GameObject skyMesh;

    int totalTime, leftTime, rightTime;

    int currentLevel = 0;

    bool player1ReachTarget, player2ReachTarget = false;
    bool resettingLevel = false;

    void Start()
    {
        leftGridController.SetLevel(levels[currentLevel].LeftPlayerLevel);
        rightGridController.SetLevel(levels[currentLevel].RightPlayerLevel);

        EventBus.AddListener<bool>(EventTypes.PlayerReachTarget, ReachTarget);
        EventBus.AddListener<bool>(EventTypes.PlayerLeaveTarget, LeaveTarget);
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);
        ResetTime(levels[currentLevel].TotalTime); 
    }

    void ResetTime(int totalTime) 
    {
        this.totalTime = totalTime;
        leftTime = 0;
        rightTime = totalTime;

        timerSlider.UpdateUI(leftTime, rightTime, totalTime);
    }

    public void TimeChange(bool isForward) 
    {
        if (isForward) leftTime = Mathf.Min(rightTime, leftTime + 1);
        else rightTime = Mathf.Max(leftTime, rightTime - 1);

        timerSlider.UpdateUI(leftTime, rightTime, totalTime);

        if (leftTime == rightTime) {
            CheckPassCondition();
        }
    }

    /// <summary>
    /// Gets the current step count for a given player based on isForward
    /// parameter
    /// </summary>
    /// <param name="isForward"></param>
    public int GetStep(bool isForward) {
        if (isForward) {
            return leftTime;
        } else {
            return totalTime - rightTime;
        }
    }

    void Update() 
    {
        if (!resettingLevel && Input.GetKeyDown(KeyCode.R)) 
        {
            skyMesh.GetComponent<Animator>().SetTrigger("ChangeLevel");
            resettingLevel = true;
            Invoke(nameof(ResetLevel), 3f);
        }
    }

    void ResetLevel()
    {
        leftGridController.SetLevel(levels[currentLevel].LeftPlayerLevel);
        rightGridController.SetLevel(levels[currentLevel].RightPlayerLevel);

        player1ReachTarget = false;
        player2ReachTarget = false;
        resettingLevel = false;

        ResetTime(levels[currentLevel].TotalTime);
    }

    void ReachTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = true;
        else player2ReachTarget = true;
        CheckPassCondition();
    }

    void LeaveTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = false;
        else player2ReachTarget = false;
    }

    void CheckPassCondition() 
    {
        if (player1ReachTarget && player2ReachTarget) 
        {
            if (AreGridsEqual()) {
                EventBus.Broadcast(EventTypes.StopAll);
                Debug.Log("WIN");
                if (currentLevel < levels.Count - 1) {
                    currentLevel++;
                }
                return;
            }
        }

        if (leftTime == rightTime) {
            EventBus.Broadcast(EventTypes.StopAll);
            Debug.Log("LOSE");
        }
    }

    bool AreGridsEqual() 
    {
        int width = leftGridController.width;
        int height = leftGridController.height;

        for (int r = 0; r < height; r++) {
            for (int c = 0; c < width; c++) {
                GridObject leftObj = leftGridController.GetPositionObject(r, c);
                GridObject rightObj = rightGridController.GetPositionObject(r, c);

                if (leftObj == null && rightObj == null) continue;
                if (leftObj == null || rightObj == null) return false;
                if (!leftObj.Equals(rightObj)) return false;
            }
        }

        return true;
    }
}
