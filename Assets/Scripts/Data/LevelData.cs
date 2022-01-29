using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "LevelData", menuName = "Config/Level")]
public class LevelData : ScriptableObject
{
    [SerializeField]
    List<MapElement> leftPlayerLevel;
    public List<MapElement> LeftPlayerLevel => leftPlayerLevel;

    public void AddLeftMapElement(MapElement element)
    {
        if(leftPlayerLevel == null)
        {
            leftPlayerLevel = new List<MapElement>();
        }
        leftPlayerLevel.Add(element);
    }

    [SerializeField]
    List<MapElement> rightPlayerLevel;
    public List<MapElement> RightPlayerLevel => rightPlayerLevel;

    public void AddRightMapElement(MapElement element)
    {
        if (rightPlayerLevel == null)
        {
            rightPlayerLevel = new List<MapElement>();
        }
        rightPlayerLevel.Add(element);
    }
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
}
