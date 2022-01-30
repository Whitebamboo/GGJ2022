using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SettingUI : MonoBehaviour
{
    public GameObject settingPage;
    public GameObject controlPage;

    public void OnOpenSetting()
    {
        settingPage.SetActive(!settingPage.activeSelf);
    }


}
