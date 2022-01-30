using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RestartUI : MonoBehaviour
{
    public GameObject hint;    


    // Start is called before the first frame update
    void Start()
    {
        EventBus.AddListener(EventTypes.LevelLost, OnShowUI);   
        EventBus.AddListener(EventTypes.RestartLevel, OnHideUI);   
    }

    private void OnDestroy()
    {
        EventBus.RemoveListener(EventTypes.LevelLost, OnShowUI);   
        EventBus.RemoveListener(EventTypes.RestartLevel, OnHideUI); 
    }

    void OnShowUI()
    {
        hint.SetActive(true);
    }

    void OnHideUI()
    {
        hint.SetActive(false);
    }
}
