using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class GameManager : CSingletonMono<GameManager>
{
    public List<LevelData> levels;

    public GridController leftGridController;
    public GridController rightGridController;

    public TimeSlider timerSlider;

    public GameObject skyMesh;

    int totalTime, leftTime, rightTime;

    public int currentLevel = 0;

    bool player1ReachTarget, player2ReachTarget = false;
    bool resettingLevel = false;

    Vector3 leftGridControllerPosition;
    Vector3 rightGridControllerPosition;

    public GameObject butterflyPrefab;

    List<GameObject> butterflies = new List<GameObject>();

    private MusicManager musicManager;

    void Start()
    {
        GameObject MM = GameObject.Find("MusicManager");
        if (MM) musicManager = MM.GetComponent<MusicManager>();
        
        leftGridControllerPosition = leftGridController.transform.position;
        rightGridControllerPosition = rightGridController.transform.position;

        EventBus.AddListener<bool>(EventTypes.PlayerReachTarget, ReachTarget);
        EventBus.AddListener<bool>(EventTypes.PlayerLeaveTarget, LeaveTarget);
        EventBus.AddListener<bool>(EventTypes.TimeMoveEnd, TimeChange);
        EventBus.AddListener(EventTypes.InteractionComplete, CheckPassCondition);
        ResetTime(levels[currentLevel].TotalTime); 
        ResetLevel();
    }

    void ResetTime(int totalTime)
    {
        this.totalTime = totalTime;
        leftTime = 0;
        rightTime = totalTime;

        timerSlider.UpdateUI(leftTime, rightTime, totalTime);
    }

    public void TimeChange(bool isForward) 
    {
        if (isForward) leftTime = Mathf.Min(rightTime, leftTime + 1);
        else rightTime = Mathf.Max(leftTime, rightTime - 1);

        timerSlider.UpdateUI(leftTime, rightTime, totalTime);

        if (leftTime == rightTime) {
            CheckPassCondition();
        }
    }


    public void UndoTimeChange(bool isForward)
    {
        if (isForward) leftTime = Mathf.Max(0, leftTime - 1);
        else rightTime = Mathf.Min(totalTime, rightTime + 1);
        timerSlider.UpdateUI(leftTime, rightTime, totalTime);

        if (leftTime == rightTime)
        {
            CheckPassCondition();
        }
    }

    /// <summary>
    /// Gets the current step count for a given player based on isForward
    /// parameter
    /// </summary>
    /// <param name="isForward"></param>
    public int GetStep(bool isForward) {
        if (isForward) {
            return leftTime;
        } else {
            return totalTime - rightTime;
        }
    }

    void Update() 
    {
        if(Input.GetKeyDown(KeyCode.R))
        {
            ResetLevel();
        }
    }

    IEnumerator ResetAnimation()
    {
        yield return null;
    }

    void WinAnimation()
    {
        PlayerController player1 = leftGridController.player;
        PlayerController player2 = rightGridController.player;
        player1.transform.eulerAngles = new Vector3(0, 90, 0);
        player2.transform.eulerAngles = new Vector3(0, -90, 0);
        player1.transform.position -= new Vector3(0.3f, 0, 0);
        player2.transform.position -= new Vector3(-0.3f, 0, 0);

        float midPoint = (leftGridController.transform.position.x + rightGridController.transform.position.x) / 2f;

        leftGridController.transform.DOMoveX(midPoint, 2f).SetEase(Ease.OutCubic);
        rightGridController.transform.DOMoveX(midPoint, 2f).SetEase(Ease.OutCubic);

        skyMesh.transform.DOMoveY(6, 3.5f).SetEase(Ease.OutCubic).SetDelay(2f).OnComplete(()=> {
            ResetLevel();
            skyMesh.transform.DOMoveY(-156, 3f);
            leftGridController.transform.DOMove(leftGridControllerPosition, 0.5f).SetEase(Ease.OutCubic);
            rightGridController.transform.DOMove(rightGridControllerPosition, 0.5f).SetEase(Ease.OutCubic);
        });
    }

    public void ResetLevel()
    {
        EventBus.Broadcast(EventTypes.RestartLevel);

        foreach (GameObject butterfly in butterflies) {
            Destroy(butterfly);
        }
        butterflies.Clear();

        leftGridController.SetLevel(levels[currentLevel]);
        rightGridController.SetLevel(levels[currentLevel]);
        SpawnButterflies();

        player1ReachTarget = false;
        player2ReachTarget = false;
        resettingLevel = false;

        ResetTime(levels[currentLevel].TotalTime);
    }

    void SpawnButterflies() {
        int numButterflies = Random.Range(1, 3);
        for (int i = 0; i < numButterflies; i++) {
            int row, col;

            do {
                row = Random.Range(0, 5);
                col = Random.Range(0, leftGridController.width - 1);
            } while (leftGridController.GetPositionObject(row, col) != null 
                  && rightGridController.GetPositionObject(row, col) != null);

            GameObject butterfly = Instantiate(butterflyPrefab, leftGridController.transform);
            butterfly.transform.position = leftGridController.GetPosition(row, col);            
            butterflies.Add(butterfly);

            butterfly = Instantiate(butterflyPrefab, rightGridController.transform);
            butterfly.transform.position = rightGridController.GetPosition(row, col);            
            butterflies.Add(butterfly);
        }
    }

    void ReachTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = true;
        else player2ReachTarget = true;
        CheckPassCondition();
    }

    void LeaveTarget(bool isForward) 
    {
        if (isForward) player1ReachTarget = false;
        else player2ReachTarget = false;
    }

    void CheckPassCondition() 
    {
        if (resettingLevel) return;
        if (player1ReachTarget && player2ReachTarget) 
        {
            if (AreGridsEqual()) {
                EventBus.Broadcast(EventTypes.StopAll);
                EventBus.Broadcast(EventTypes.LevelComplete);
                Debug.Log("WIN");
                if (currentLevel < levels.Count - 1) {
                    resettingLevel = true;
                    currentLevel++;
                } else {
                    EventBus.Broadcast(EventTypes.GameFinish);
                    return;
                }

                if (musicManager) musicManager.PlayWinSFX();
                Invoke(nameof(WinAnimation), 0.5f);
                return;
            }
        }

        if (leftTime == rightTime) {
            EventBus.Broadcast(EventTypes.StopAll);
            EventBus.Broadcast(EventTypes.LevelLost);
            if (musicManager) musicManager.PlayFailSFX();
            Debug.Log("LOSE");
        }
    }

    bool AreGridsEqual() 
    {
        int width = leftGridController.width;
        int height = leftGridController.height;

        for (int r = 0; r < height; r++) {
            for (int c = 0; c < width; c++) {
                GridObject leftObj = leftGridController.GetPositionObject(r, c);
                GridObject rightObj = rightGridController.GetPositionObject(r, c);

                if (leftObj == null && rightObj == null) continue;
                if (leftObj == null || rightObj == null) return false;
                if (!leftObj.Equals(rightObj)) return false;
            }
        }

        return true;
    }
}
