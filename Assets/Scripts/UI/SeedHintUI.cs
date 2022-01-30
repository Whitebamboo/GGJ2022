using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeedHintUI : MonoBehaviour
{
    public GameObject hintPlayer1;
    public GameObject hintPlayer2;

    // Start is called before the first frame update
    void Start()
    {
        EventBus.AddListener<GridObject, PlayerController>(EventTypes.ShowSeedHint, OnShowSeedHint);   
        EventBus.AddListener<PlayerController>(EventTypes.CloseSeedHint, OnCloseSeedHint);   
    }

    private void OnDestroy()
    {
        EventBus.RemoveListener<GridObject, PlayerController>(EventTypes.ShowSeedHint, OnShowSeedHint);   
        EventBus.RemoveListener<PlayerController>(EventTypes.CloseSeedHint, OnCloseSeedHint);   
    }

    void OnShowSeedHint(GridObject gridObj, PlayerController player)
    {
        if(player.isForward)
        {
            hintPlayer1.SetActive(true);
        }  
        else
        {
            hintPlayer2.SetActive(true);
        }
    }

    void OnCloseSeedHint(PlayerController player)
    {
        if (player.isForward)
        {
            hintPlayer1.SetActive(false);
        }
        else
        {
            hintPlayer2.SetActive(false);
        }
    }
}
