using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEditor.SceneManagement;
using UnityEditor;
using System.Reflection;
using System;
using System.IO;

public class MapManagerEditor : EditorWindow
{
    [MenuItem("Tools/MapWindow")]
    static void AddWindow()
    {
        Rect wr = new Rect(0, 0, 500, 500);
        MapManagerEditor window = (MapManagerEditor)GetWindowWithRect(typeof(MapManagerEditor), wr, true, "Map Window");
        window.Show();
    }

    const string LEVEL_DATA_PATH = "Assets/Data/";
    const string PREFAB_PATH = "Assets/Prefabs/";

    string m_savedMapName;

    Tilemap m_leftInteractiveLayer;
    Tilemap m_rightInteractiveLayer;

    List<GameObject> prefabsInProject = new List<GameObject>();

    void OnEnable()
    {
        if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
        {
            EditorSceneManager.OpenScene("Assets/Scenes/MapEditing.unity");
        }

        InitAllLayers();
        InitAllPrefabInfo();
    }

    void InitAllLayers()
    {
        var allGos = Resources.FindObjectsOfTypeAll(typeof(GameObject));
        var previousSelection = Selection.objects;
        Selection.objects = allGos;
        var selectedTransforms = Selection.GetTransforms(SelectionMode.Editable | SelectionMode.ExcludePrefab);
        Selection.objects = previousSelection;
        foreach (var trans in selectedTransforms)
        {
            Tilemap m_map = trans.GetComponent<Tilemap>();
            if (m_map != null)
            {
                if (m_map.name == "LeftInteractiveLayer")
                {
                    m_leftInteractiveLayer = m_map;
                }
                else if (m_map.name == "RightInteractiveLayer")
                {
                    m_rightInteractiveLayer = m_map;
                }
            }
        }
    }

    void InitAllPrefabInfo()
    {
        string[] prefabFiles = Directory.GetFiles(PREFAB_PATH, "*.prefab", SearchOption.AllDirectories);

        foreach(string path in prefabFiles)
        {
            prefabsInProject.Add(AssetDatabase.LoadAssetAtPath<GameObject>(path));
        }
        
    }

    void OnGUI()
    {
        //输入地图名字
        m_savedMapName = EditorGUILayout.TextField("输入保存的地图文件名:", m_savedMapName);

        if (GUILayout.Button("保存当前地图", GUILayout.Width(500), GUILayout.Height(30)))
        {
            if (string.IsNullOrEmpty(m_savedMapName))
            {
                ShowNotification(new GUIContent("文件名不得为空"));
                return;
            }
            Serialize();
            ShowNotification(new GUIContent("保存成功"));
        }
        
    }

    void Serialize()
    {
        //将Level data创建为asset
        LevelData asset = ScriptableObject.CreateInstance<LevelData>();
        AssetDatabase.CreateAsset(asset, LEVEL_DATA_PATH + m_savedMapName + ".asset");

        //add left elements
        SerializeElements(asset, m_leftInteractiveLayer.transform);
        //add right elements
        SerializeElements(asset, m_rightInteractiveLayer.transform);

        EditorUtility.FocusProjectWindow();
        Selection.activeObject = asset;
        EditorUtility.SetDirty(asset);
        AssetDatabase.SaveAssets();
        //AssetDatabase.ForceReserializeAssets();
    }

    void SerializeElements(LevelData asset, Transform map)
    {
        Type mapType = typeof(MapElement);
        FieldInfo[] allfields = mapType.GetFields(BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);

        int children = map.childCount;
        for (int i = 0; i < children; ++i)
        {
            MapElement mapElement = new MapElement();
            Transform child = map.GetChild(i);
            foreach (var field in allfields)
            {
                if (field.Name == "row")
                {
                    field.SetValue(mapElement, (int)child.localPosition.x);
                }
                else if (field.Name == "col")
                {
                    field.SetValue(mapElement, (int)child.localPosition.z);
                }
                else if (field.Name == "prefab")
                {
                    field.SetValue(mapElement, prefabsInProject.Find(x => x.name == child.name));
                }
            }
            if (map.name == "LeftInteractiveLayer")
            {
                asset.AddLeftMapElement(mapElement);
            }
            else if (map.name == "RightInteractiveLayer")
            {
                asset.AddRightMapElement(mapElement);
            }
        }
    }
}

