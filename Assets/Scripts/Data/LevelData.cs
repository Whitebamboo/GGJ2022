using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "LevelData", menuName = "Config/Level")]
public class LevelData : ScriptableObject
{
    [SerializeField]
    int totalTime;

    [SerializeField]
    List<MapElement> leftPlayerLevel;

    [SerializeField]
    List<MapElement> rightPlayerLevel;

    public int TotalTime => totalTime;

    public List<MapElement> RightPlayerLevel => rightPlayerLevel;

    public List<MapElement> LeftPlayerLevel => leftPlayerLevel;

    public void AddLeftMapElement(MapElement element)
    {
        if (leftPlayerLevel == null)
        {
            leftPlayerLevel = new List<MapElement>();
        }
        leftPlayerLevel.Add(element);
    }

    public void AddRightMapElement(MapElement element)
    {
        if (rightPlayerLevel == null)
        {
            rightPlayerLevel = new List<MapElement>();
        }
        rightPlayerLevel.Add(element);
    }

    public List<State> TreeStates = new List<State>();
}

[System.Serializable]
public class MapElement
{
    [SerializeField]
    GameObject prefab;

    [SerializeField]
    int row;

    [SerializeField]
    int col;

    public GameObject Prefab => prefab;
    public int Row => row;
    public int Col => col;

    public bool HasStartAge;
    public int StartAge;
}

[System.Serializable]
public class State
{
    public int ageThreshold;
    public int state;
}
