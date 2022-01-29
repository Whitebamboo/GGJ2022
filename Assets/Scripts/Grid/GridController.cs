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
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
        grid = new GridSpaceController[height, width];

        CreateGrid();
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
}