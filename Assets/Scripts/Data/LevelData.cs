using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "LevelData", menuName = "Config/Level")]
public class LevelData : ScriptableObject
{
    [SerializeField]
    List<MapElement> leftPlayerLevel;
    public List<MapElement> LeftPlayerLevel => leftPlayerLevel;

    [SerializeField]
    List<MapElement> rightPlayerLevel;
    public List<MapElement> RightPlayerLevel => rightPlayerLevel;
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
