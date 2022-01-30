using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TimeSlider : MonoBehaviour
{
    public RectTransform fill;
    public RectTransform fillArea;
    public RectTransform leftHandle;
    public RectTransform rightHandle;

    Vector3 leftStart, rightStart;
    float originalFillSize, originalFillWidth;
    float distanceAmount;

    private void Awake() 
    {
        leftStart = leftHandle.localPosition;
        rightStart = rightHandle.localPosition;

        distanceAmount = Vector3.Distance(leftStart, rightStart);
        originalFillSize = fillArea.rect.width;
    }

    public void UpdateUI(int leftTime, int rightTime, int totalTime) 
    {
        float changeAmount = distanceAmount / totalTime;

        leftHandle.localPosition = leftStart + new Vector3(changeAmount * leftTime, 0, 0);
        rightHandle.localPosition = rightStart - new Vector3(changeAmount * (totalTime - rightTime), 0, 0);

        float fillRatio = ((float)(rightTime - leftTime)) / ((float)totalTime);
        fill.sizeDelta = new Vector2 (originalFillSize * fillRatio, fill.sizeDelta.y);
        fill.localPosition = (leftHandle.localPosition + rightHandle.localPosition)/2;
    }
}
