using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SettingUI : MonoBehaviour
{
    public float hintTime = 5f;

    public GameObject settingPage;
    public GameObject controlPage;
    public GameObject creditPage;
    public GameObject lostPage;

    bool isBegin = true;

    private void Start()
    {
        if (isBegin)
        {
            controlPage.SetActive(true);
            isBegin = false;
            StartCoroutine(CloseControlHint());
        }

        EventBus.AddListener(EventTypes.GameFinish, ShowCredits);
        EventBus.AddListener(EventTypes.LevelLost, ShowLost);
        EventBus.AddListener(EventTypes.SuccessFullyRestart, HideLost);
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

    public void ShowCredits()
    {
        creditPage.SetActive(true);
    }

    void ShowLost() 
    {
        lostPage.SetActive(true);
    }

    void HideLost() 
    {
        lostPage.SetActive(false);
    }
}
