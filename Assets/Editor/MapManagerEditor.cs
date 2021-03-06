using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEditor.SceneManagement;
using UnityEditor;
using System.Reflection;
using System;
using System.IO;
using UnityEngine.SceneManagement;

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

    Scene m_editorScene;

    string m_savedMapName;

    Transform m_leftInteractiveLayer;
    Transform m_rightInteractiveLayer;

    LevelData m_loadLevelData;

    int totalTime;

    List<GameObject> prefabsInProject = new List<GameObject>();

    void OnEnable()
    {
        if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
        {
            m_editorScene = EditorSceneManager.OpenScene("Assets/Scenes/MapEditing.unity");
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
            if (trans.name == "LeftInteractiveLayer")
            {
                m_leftInteractiveLayer = trans;
            }
            else if (trans.name == "RightInteractiveLayer")
            {
                m_rightInteractiveLayer = trans;
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
        //????????????
        
        if(m_loadLevelData == null)
        {
            GUILayout.Space(10);
            m_savedMapName = EditorGUILayout.TextField("Enter the name of map:", m_savedMapName);
        }
 
        if (m_loadLevelData == null && GUILayout.Button("Save current map", GUILayout.Width(500), GUILayout.Height(30)))
        {
            GUILayout.Space(10);
            if (string.IsNullOrEmpty(m_savedMapName))
            {
                ShowNotification(new GUIContent("map name is empty"));
                return;
            }

            Serialize();
            ShowNotification(new GUIContent("Save successfully"));
        }
        
        GUILayout.Space(10);
        m_loadLevelData = (LevelData)EditorGUILayout.ObjectField("load saved level", m_loadLevelData, typeof(LevelData), false);
        
        GUILayout.Space(10);       
        if (m_loadLevelData != null && GUILayout.Button("Load", GUILayout.Width(500), GUILayout.Height(30)))
        {
            Clear();
            m_savedMapName = m_loadLevelData.name;
            Load(m_leftInteractiveLayer.transform);
            Load(m_rightInteractiveLayer.transform);
        }

        if (m_loadLevelData != null && GUILayout.Button("Save", GUILayout.Width(500), GUILayout.Height(30)))
        {
            Serialize();
        }
    
        if (GUILayout.Button("Clean map elements", GUILayout.Width(500), GUILayout.Height(30)))
        {
            Clear();
        }
    }

    void Clear()
    {
        for (int i = m_leftInteractiveLayer.transform.childCount - 1; i >= 0; i--)
        {
            Transform child = m_leftInteractiveLayer.GetChild(i);
            DestroyImmediate(child.gameObject);
        }

        for (int i = m_rightInteractiveLayer.transform.childCount - 1; i >= 0; i--)
        {
            Transform child = m_rightInteractiveLayer.GetChild(i);
            DestroyImmediate(child.gameObject);
        }

        EditorSceneManager.MarkSceneDirty(m_editorScene);
        EditorSceneManager.SaveOpenScenes();
    }

    void Load(Transform map)
    {
        List<MapElement> elements = null;

        if (map.name == "LeftInteractiveLayer")
        {
            elements = m_loadLevelData.LeftPlayerLevel;
        }
        else if (map.name == "RightInteractiveLayer")
        {
            elements = m_loadLevelData.RightPlayerLevel;
        }

        foreach (MapElement element in elements)
        {
            GameObject obj = Instantiate(prefabsInProject.Find(x => x.name == element.Prefab.name));
            obj.name = obj.name.Replace("(Clone)", "");
            if (map.name == "LeftInteractiveLayer")
            {
                obj.transform.parent = m_leftInteractiveLayer.transform;
            }
            else if (map.name == "RightInteractiveLayer")
            {
                obj.transform.parent = m_rightInteractiveLayer.transform;
            }
            obj.transform.localPosition = new Vector3(element.Col + 0.5f, 0.5f, element.Row + 0.5f);
        }

        totalTime = m_loadLevelData.TotalTime;

        EditorSceneManager.MarkSceneDirty(m_editorScene);
        EditorSceneManager.SaveOpenScenes();
    }

    void Serialize()
    {
        //??Level data??????asset
        LevelData asset = ScriptableObject.CreateInstance<LevelData>();
        AssetDatabase.CreateAsset(asset, LEVEL_DATA_PATH + m_savedMapName + ".asset");

        //add left elements
        SerializeElements(asset, m_leftInteractiveLayer.transform);
        //add right elements
        SerializeElements(asset, m_rightInteractiveLayer.transform);

        Type levelType = typeof(LevelData);
        FieldInfo field = levelType.GetField("totalTime", BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
        field.SetValue(asset, totalTime);

        EditorUtility.FocusProjectWindow();
        Selection.activeObject = asset;
        EditorUtility.SetDirty(asset);
        AssetDatabase.SaveAssets();
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
                    field.SetValue(mapElement, (int)child.localPosition.z);
                }
                else if (field.Name == "col")
                {
                    field.SetValue(mapElement, (int)child.localPosition.x);
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

