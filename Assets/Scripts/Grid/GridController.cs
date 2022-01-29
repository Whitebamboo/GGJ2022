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

    GridSpaceController[,] grid;

    GameManager gameManager;

    void Awake()
    {
        // gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
        grid = new GridSpaceController[height, width];
        CreateGrid();
    }

    public void SetLevel(List<MapElement> mapElements) 
    {
        // TODO: move player to the level data, create grid here
        // CreateGrid(); 
        foreach (MapElement mapElement in mapElements) {
            int r = mapElement.Row; int c = mapElement.Col;
            GameObject elementPrefab = Instantiate(mapElement.Prefab, transform);
            elementPrefab.transform.position = GetPosition(r, c);

            // TODO: set position object when all the prefab have the correct classes
            SetPositionObject(r, c, elementPrefab.GetComponent<GridObject>());
        }
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

    public bool Push(int row, int col, Direction dir) 
    {
        GridObject gridObject = GetPositionObject(row, col);
        SetPositionObject(row, col, null);

        int xOff = GetXOffset(dir);
        int yOff = GetYOffset(dir);

        int newRow = row + yOff;
        int newCol = col + xOff;

        if (IsValidPosition(newRow, newCol))
        {
            gridObject.MoveTo(GetPosition(newRow, newCol));
            SetPositionObject(newRow, newCol, gridObject);
            return true;
        }

        return false;
    }
}