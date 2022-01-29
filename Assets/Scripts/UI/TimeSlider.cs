using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TimeSlider : MonoBehaviour
{
    public RectTransform fill;
    public RectTransform leftHandle;
    public RectTransform rightHandle;

    Vector3 leftStart, rightStart;
    float originalFillSize, originalFillWidth;

    private void Awake() 
    {
        leftStart = leftHandle.transform.position;
        rightStart = rightHandle.transform.position;
        originalFillSize = fill.sizeDelta.x;  
        originalFillWidth = fill.rect.width;
    }

    public void UpdateUI(int leftTime, int rightTime, int totalTime) 
    {
        float changeAmount = originalFillWidth / totalTime;

        leftHandle.position = leftStart + new Vector3(changeAmount * leftTime, 0, 0);
        rightHandle.position = rightStart - new Vector3(changeAmount * (totalTime - rightTime), 0, 0);

        float fillRatio = ((float)(rightTime - leftTime)) / ((float)totalTime);
        fill.sizeDelta = new Vector2 (originalFillSize * fillRatio, fill.sizeDelta.y);
        fill.position = (leftHandle.position + rightHandle.position)/2;
    }
}
