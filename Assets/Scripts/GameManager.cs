using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : CSingletonMono<GameManager>
{
    public List<LevelData> levels;

    public GridController leftGridController;
    public GridController rightGridController;

    int currentLevel = 0;

    bool player1ReachTarget, player2ReachTarget = false;

    void Start()
    {
        leftGridController.SetLevel(levels[0].LeftPlayerLevel);
        rightGridController.SetLevel(levels[0].RightPlayerLevel);

        EventBus.AddListener<bool>(EventTypes.PlayerReachTarget, ReachTarget);
    }

    void ReachTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = true;
        else player2ReachTarget = true;

        if (player1ReachTarget && player2ReachTarget) {
            // Check grids
        }
    }
}
