using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SettingUI : MonoBehaviour
{
    public float hintTime = 5f;

    public GameObject settingPage;
    public GameObject controlPage;
    public GameObject creditPage;

    bool isBegin = true;

    private void Start()
    {
        if (isBegin)
        {
            controlPage.SetActive(true);
            isBegin = false;
            StartCoroutine(CloseControlHint());
        }
    }

    public void OnOpenSetting()
    {
        settingPage.SetActive(!settingPage.activeSelf);
    }

    public void OpenControlPage(bool active)
    {
        settingPage.SetActive(active);
    }

    IEnumerator CloseControlHint()
    {
        yield return new WaitForSeconds(hintTime);
        controlPage.SetActive(false);
    }

    public void OnClickControlButton()
    {
        controlPage.SetActive(!controlPage.activeSelf);
    }

    public void OnClickQuitButton()
    {
        Application.Quit();
    }

    public void OnClickCreditButton()
    {
        creditPage.SetActive(!creditPage.activeSelf);
    }
}
