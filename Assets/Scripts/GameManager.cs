using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : CSingletonMono<GameManager>
{
    public List<LevelData> levels;

    public GridController leftGridController;
    public GridController rightGridController;

    public TimeSlider timerSlider;

    int currentLevel = 0;

    bool player1ReachTarget, player2ReachTarget = false;
    bool resetLevel = false;

    void Start()
    {
        leftGridController.SetLevel(levels[currentLevel].LeftPlayerLevel);
        rightGridController.SetLevel(levels[currentLevel].RightPlayerLevel);

        EventBus.AddListener<bool>(EventTypes.PlayerReachTarget, ReachTarget);
    }

    void Update() {
        if (resetLevel && Input.GetKeyDown(KeyCode.R)) {
            leftGridController.SetLevel(levels[currentLevel].LeftPlayerLevel);
            rightGridController.SetLevel(levels[currentLevel].RightPlayerLevel);

            player1ReachTarget = false;
            player2ReachTarget = false;
            resetLevel = false;

            // TODO: reset timer UI, overall I think the timer UI should be connected to gamemanager
        }
    }

    void ReachTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = true;
        else player2ReachTarget = true;

        if (player1ReachTarget && player2ReachTarget) {
            if (AreGridsEqual()) {
                Debug.Log("WIN");
                currentLevel++;
                if (currentLevel < levels.Count) {
                    resetLevel = true;
                }
            } else {
                Debug.Log("LOSE");
                resetLevel = true;
            }
        }
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
