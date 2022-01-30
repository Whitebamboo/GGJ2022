using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridController : MonoBehaviour
{
    public GameObject gridPrefab;
    public GameObject bottomLeft;
    public int height;
    public int width;
    public float gridSpacing;

    public bool isForward;

    GridSpaceController[,] grid;

    // Dictionary for every object on the grid to their row/col position
    public Dictionary<GameObject, (int, int)> objectMapping;

    GameManager gameManager;

    void Awake()
    {
        EventBus.AddListener<PlayerController, PlayerAction, Direction>(EventTypes.PlayerAction, TryPlayerAction);
        EventBus.AddListener<GameObject, GameObject>(EventTypes.Create, CreateObject);
        EventBus.AddListener<GameObject>(EventTypes.Destroy, DestroyObject);

        grid = new GridSpaceController[height, width];
        objectMapping = new Dictionary<GameObject, (int, int)>();
    }

    public void SetLevel(LevelData levelData) 
    {
        DestroyLevel();
        CreateGrid(); 

        List<MapElement> mapElements = isForward ? levelData.LeftPlayerLevel : levelData.RightPlayerLevel;
        List<State> treeStates = levelData.TreeStates;
        int elemAge = isForward ? 0 : levelData.TotalTime;

        foreach (MapElement mapElement in mapElements) {
            int r = mapElement.Row; int c = mapElement.Col;
            GameObject elementPrefab = Instantiate(mapElement.Prefab, transform);
            elementPrefab.transform.position = GetPosition(r, c);

            GridObject gridObj = elementPrefab.GetComponent<GridObject>();
            SetPositionObject(r, c, gridObj);
            gridObj.SetTimeDirection(isForward);
            gridObj.gridController = this;
            gridObj.SetAge(elemAge);
            if (elementPrefab.GetComponent<Tree>() != null) {
                if (treeStates.Count > 0) elementPrefab.GetComponent<Tree>().stateLists = treeStates;
            }
            
            objectMapping.Add(elementPrefab, (r, c));
        }
    }

    void DestroyLevel() 
    {
        for (int r = 0; r < height; r++)
        {
            for (int c = 0; c < width; c++)
            {
                if (grid[r, c] != null) {
                    if (GetPositionObject(r, c) != null) {
                        objectMapping.Remove(GetPositionObject(r, c).gameObject);
                        Destroy(GetPositionObject(r, c).gameObject);
                    }
                    Destroy(grid[r, c].gameObject);
                }
            }
        }

        foreach (GameObject obj in objectMapping.Keys) {
            Destroy(obj);
        }
        objectMapping.Clear();
    }

    void CreateGrid()
    {
        for (int r = 0; r < height; r++)
        {
            for (int c = 0; c < width; c++)
            {
                GameObject gridSpace = Instantiate(gridPrefab, transform);
                gridSpace.transform.position = bottomLeft.transform.position + (new Vector3(c * gridSpacing, 0, r * gridSpacing));
                grid[r, c] = gridSpace.GetComponent<GridSpaceController>();
            }
        }

        bottomLeft.SetActive(false);
    }

    public void SetPositionObject(int row, int col, GridObject gridObj)
    {
        grid[row, col].SetObject(gridObj);
    }

    public GridObject GetPositionObject(int row, int col)
    {
        return grid[row, col].GetObject();
    }

    public Vector3 GetPosition(int row, int col)
    {
        return grid[row, col].gameObject.transform.position;
    }

    public bool IsValidPosition(int row, int col)
    {
        return 0 <= row && row < height && 0 <= col && col < width;
    }

    int GetXOffset(Direction dir)
    {
        switch (dir)
        {
            case Direction.Left:
                return -1;
            case Direction.Right:
                return 1;
        }
        return 0;
    }

    int GetYOffset(Direction dir)
    {
        switch (dir)
        {
            case Direction.Down:
                return -1;
            case Direction.Up:
                return 1;
        }
        return 0;
    }

    public bool TryPush(int row, int col, Direction dir) 
    {
        GridObject pushObject = GetPositionObject(row, col);
        if (pushObject.IsPassable()) {
            pushObject = pushObject.GetPassedObject();
        }

        int xOff = GetXOffset(dir);
        int yOff = GetYOffset(dir);

        int newRow = row + yOff;
        int newCol = col + xOff;

        if (IsValidPosition(newRow, newCol))
        {
            GridObject newPositionObject = GetPositionObject(newRow, newCol);
            bool successfulMove = false;

            if (newPositionObject == null) // Nothing in pushed spot
            {
                successfulMove = true;
            }
            else if (newPositionObject.IsPassable()) // Something passable in pushed spot
            {
                newPositionObject.SetPassedObject(pushObject);
                successfulMove = true;
            }
            else if (newPositionObject.IsCrushable()) // Something crushable in pushed spot
            {
                EventBus.Broadcast(EventTypes.Destroy, newPositionObject.gameObject);
                successfulMove = true;
            }
            else 
            {
                newPositionObject.CrashAction();
            }

            if (successfulMove) 
            {
                if (GetPositionObject(row, col).IsPassable()) {
                    GetPositionObject(row, col).SetPassedObject(null);
                }

                pushObject.MoveTo(GetPosition(newRow, newCol));
                if (GetPositionObject(row, col) == pushObject) {
                    SetPositionObject(row, col, null);
                }

                if (newPositionObject == null || !newPositionObject.IsPassable()) {
                    SetPositionObject(newRow, newCol, pushObject);
                }

                objectMapping[pushObject.gameObject] = (newRow, newCol);
                return true;
            }
        }

        return false;
    }

    void TryPlayerAction(PlayerController player, PlayerAction action, Direction playerDirection) 
    {
        if (player.isForward != isForward) return;
        EventBus.Broadcast<GridSpaceController[,],bool>(EventTypes.GridRecord, grid, isForward);

        switch(action) {
            case PlayerAction.Move: 
                TryMovePlayer(player, playerDirection);
                break;
            default:
                TryInteract(player, playerDirection);
                return;
        }
    }

    public void TryMovePlayer(PlayerController player, Direction playerDirection) 
    {
        (int, int) playerPosition = objectMapping[player.gameObject];
        int playerRow = playerPosition.Item1; 
        int playerCol = playerPosition.Item2;

        int xOff = GetXOffset(playerDirection);
        int yOff = GetYOffset(playerDirection);

        int newRow = playerRow + yOff;
        int newCol = playerCol + xOff;

        if (!IsValidPosition(newRow, newCol)) return;
        if (GetPositionObject(newRow, newCol) != null) {
            // Something is in the position we want to move to
            GridObject gridObject = GetPositionObject(newRow, newCol);

            // Try to push the object
            if (gridObject.IsPushable()) {
                if (TryPush(newRow, newCol, playerDirection)) {
                    MovePlayerToNewPosition(player, playerRow, playerCol, newRow, newCol);
                }
                return;
            }

            if (gridObject.IsPassable()) {
                GridObject passedObject = gridObject.GetPassedObject();
                if (passedObject != null && passedObject.IsPushable()) {
                    if (TryPush(newRow, newCol, playerDirection)) {
                        MovePlayerToNewPosition(player, playerRow, playerCol, newRow, newCol);
                    }
                    return;
                }
                else {
                    SetPositionObject(playerRow, playerCol, null);
                    gridObject.SetPassedObject(player);

                    EventBus.Broadcast(EventTypes.CloseSeedHint, player);
                    CheckAround(player);

                    player.MoveTo(GetPosition(newRow, newCol));
                    objectMapping[player.gameObject] = (newRow, newCol);
                    return;
                }
            }

            return;
        }

        MovePlayerToNewPosition(player, playerRow, playerCol, newRow, newCol);
    }

    void MovePlayerToNewPosition(PlayerController player, int playerRow, int playerCol, int newRow, int newCol) {
        if (GetPositionObject(playerRow, playerCol) == player) {
            SetPositionObject(playerRow, playerCol, null);
        }
        SetPositionObject(newRow, newCol, player);
        objectMapping[player.gameObject] = (newRow, newCol);

        EventBus.Broadcast(EventTypes.CloseSeedHint, player);
        CheckAround(player);
        
        player.MoveTo(GetPosition(newRow, newCol));
    }

    public void TryInteract(PlayerController player, Direction playerDirection) 
    {
        (int, int) playerPosition = objectMapping[player.gameObject];
        int playerRow = playerPosition.Item1; 
        int playerCol = playerPosition.Item2;

        int xOff = GetXOffset(playerDirection);
        int yOff = GetYOffset(playerDirection);

        int newRow = playerRow + yOff;
        int newCol = playerCol + xOff;

        if (IsValidPosition(newRow, newCol)) {
            if (GetPositionObject(newRow, newCol) != null) {
                // Something is in the position we can interact with
                GridObject gridObject = GetPositionObject(newRow, newCol);
                gridObject.interactive();
                if(gridObject is Seed)
                    EventBus.Broadcast(EventTypes.CloseSeedHint, player);
                return;
            }
        }

        // Try every direction
        foreach (Direction dir in Enum.GetValues(typeof(Direction))) {
            xOff = GetXOffset(dir);
            yOff = GetYOffset(dir);

            newRow = playerRow + yOff;
            newCol = playerCol + xOff;

            if (IsValidPosition(newRow, newCol)) {
                if (GetPositionObject(newRow, newCol) != null) {
                    // Something is in the position we can interact with
                    GridObject gridObject = GetPositionObject(newRow, newCol);
                    gridObject.interactive();
                    player.ChangeDirection(dir);
                    if (gridObject is Seed)
                        EventBus.Broadcast(EventTypes.CloseSeedHint, player);
                    return;
                }
            }
        }
    }

    public void CheckAround(PlayerController player)
    {
        (int, int) playerPosition = objectMapping[player.gameObject];
        int playerRow = playerPosition.Item1;
        int playerCol = playerPosition.Item2;

        // Try every direction
        foreach (Direction dir in Enum.GetValues(typeof(Direction)))
        {
            int xOff = GetXOffset(dir);
            int yOff = GetYOffset(dir);

            int newRow = playerRow + yOff;
            int newCol = playerCol + xOff;

            if (IsValidPosition(newRow, newCol))
            {
                if (GetPositionObject(newRow, newCol) != null)
                {
                    // Something is in the position we can interact with
                    GridObject gridObject = GetPositionObject(newRow, newCol);
                    if(gridObject is Seed)
                        EventBus.Broadcast(EventTypes.ShowSeedHint, gridObject, player);
                }
            }
        }
    }

    // Create an object at the given parent object's position (and replace parent)
    public void CreateObject(GameObject newObject, GameObject parentObject) 
    {
        (int, int) position;
        if (objectMapping.TryGetValue(parentObject, out position)) 
        {
            SetPositionObject(position.Item1, position.Item2, newObject.GetComponent<GridObject>());
            newObject.GetComponent<GridObject>().isForward = isForward;
            objectMapping.Remove(parentObject);
            objectMapping.Add(newObject, position);
        }
    }

    public void DestroyObject(GameObject toDeleteObj) 
    {
        if (objectMapping.ContainsKey(toDeleteObj)) {
            objectMapping.Remove(toDeleteObj);
        }
    }
}