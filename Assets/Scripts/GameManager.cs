using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : CSingletonMono<GameManager>
{
    public List<LevelData> levels;

    public GridController leftGridController;
    public GridController rightGridController;

    public TimeSlider timerSlider;

    int totalTime, leftTime, rightTime;

    int currentLevel = 0;

    bool player1ReachTarget, player2ReachTarget = false;
    bool resetLevel = false;

    void Start()
    {
        leftGridController.SetLevel(levels[currentLevel].LeftPlayerLevel);
        rightGridController.SetLevel(levels[currentLevel].RightPlayerLevel);

        EventBus.AddListener<bool>(EventTypes.PlayerReachTarget, ReachTarget);
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);
        ResetTime(50); // TODO: get info from level
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

    void Update() 
    {
        if (resetLevel && Input.GetKeyDown(KeyCode.R)) 
        {
            leftGridController.SetLevel(levels[currentLevel].LeftPlayerLevel);
            rightGridController.SetLevel(levels[currentLevel].RightPlayerLevel);

            player1ReachTarget = false;
            player2ReachTarget = false;
            resetLevel = false;

            ResetTime(50);
        }
    }

    void ReachTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = true;
        else player2ReachTarget = true;

        CheckPassCondition();
    }

    void CheckPassCondition() {
        if (player1ReachTarget && player2ReachTarget && AreGridsEqual()) {
            // Also check leftTime == rightTime
            Debug.Log("WIN");
            currentLevel++;
            if (currentLevel < levels.Count) {
                resetLevel = true;
            }
            return;
        }

        Debug.Log("LOSE");
        resetLevel = true;
    }

    bool AreGridsEqual() {
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
