using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : CSingletonMono<GameManager>
{
    public List<LevelData> levels;

    public GridController leftGridController;
    public GridController rightGridController;

    int currentLevel = 0;

    void Start()
    {
        leftGridController.SetLevel(levels[0].LeftPlayerLevel);
        rightGridController.SetLevel(levels[0].RightPlayerLevel);
    }

    void Update()
    {
        
    }
}
