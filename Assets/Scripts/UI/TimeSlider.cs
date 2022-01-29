using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TimeSlider : MonoBehaviour
{
    public RectTransform fill;
    public RectTransform leftHandle;
    public RectTransform rightHandle;

    int totalTime, leftTime, rightTime;
    float changeAmount;
    Vector3 leftStart, rightStart;
    float originalFillSize;

    private void Start() 
    {
        leftStart = leftHandle.transform.position;
        rightStart = rightHandle.transform.position;
        originalFillSize = fill.sizeDelta.x;

        // TODO: temporary for testing slider
        SetTime(20);    
    }

    public void SetTime(int totalTime) 
    {
        this.totalTime = totalTime;
        leftTime = 0;
        rightTime = totalTime;
        EventBus.AddListener<bool>(EventTypes.TimeMove, TimeChange);
        changeAmount = fill.rect.width / totalTime;

        UpdateUI();
    }

    public void TimeChange(bool isLeft) 
    {
        if (isLeft) leftTime = Mathf.Min(rightTime, leftTime + 1);
        else rightTime = Mathf.Max(leftTime, rightTime - 1);

        UpdateUI();
        if (leftTime == rightTime) {
            // TODO: Do something
        }
    }

    void UpdateUI() 
    {
        Debug.Log("Left: " + leftTime + "; Right: " + rightTime);
        leftHandle.position = leftStart + new Vector3(changeAmount * leftTime, 0, 0);
        rightHandle.position = rightStart - new Vector3(changeAmount * (totalTime - rightTime), 0, 0);
        Debug.Log(fill.sizeDelta);
        float fillRatio = ((float)(rightTime - leftTime)) / ((float)totalTime);
        Debug.Log(fillRatio);

        fill.sizeDelta = new Vector2 (originalFillSize * fillRatio, fill.sizeDelta.y);
        fill.position = (leftHandle.position + rightHandle.position)/2;
    }
}
