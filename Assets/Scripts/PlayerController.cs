using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Direction { Up, Down, Left, Right };

public class PlayerController : GridObject
{
    GridController gridController;
    
    int playerRow = 0;
    int playerCol = 0;
    Direction playerDirection;

    bool keyDown;

    Vector3 currentPosition;
    Vector3 targetPosition;
    float currentTime;
    bool isMoving = false;

    void Start()
    {
        gridController = GameObject.Find("GridController").GetComponent<GridController>();
        gridController.SetPositionObject(playerRow, playerCol, this);
    }

    void Update()
    {
        if (isMoving)
        {
            transform.position = Vector3.Lerp(currentPosition, targetPosition, currentTime);
            currentTime += 3 * Time.deltaTime;

            if (currentTime >= 1)
            {
                transform.position = targetPosition;
                isMoving = false;
            }
        }
        
        if (!keyDown)
        {
            if (Input.GetAxis("Vertical") > 0)
            {
                transform.rotation = Quaternion.Euler(0, 0, 0);
                playerDirection = Direction.Up;
                TryMove(playerRow + 1, playerCol);
            }
            else if (Input.GetAxis("Vertical") < 0)
            {
                transform.rotation = Quaternion.Euler(0, 180, 0);
                playerDirection = Direction.Down;
                TryMove(playerRow - 1, playerCol);
            }
            else if (Input.GetAxis("Horizontal") < 0)
            {
                transform.rotation = Quaternion.Euler(0, -90, 0);
                playerDirection = Direction.Left;
                TryMove(playerRow, playerCol - 1);
            }
            else if (Input.GetAxis("Horizontal") > 0)
            {
                transform.rotation = Quaternion.Euler(0, 90, 0);
                playerDirection = Direction.Right;
                TryMove(playerRow, playerCol + 1);
            }
        }

        if (Input.GetAxis("Vertical") == 0 && Input.GetAxis("Horizontal") == 0) keyDown = false;
    }

    void TryMove(int newRow, int newCol)
    {
        keyDown = true;

        if (!gridController.IsValidPosition(newRow, newCol)) return;
        if (gridController.GetPositionObject(newRow, newCol) != null) return;

        gridController.SetPositionObject(playerRow, playerCol, null);
        gridController.SetPositionObject(newRow, newCol, this);

        Vector3 gridPos = gridController.GetPosition(newRow, newCol);
        gridPos.y = transform.position.y;

        targetPosition = gridPos;
        currentPosition = transform.position;
        currentTime = 0;
        isMoving = true;

        playerRow = newRow;
        playerCol = newCol;
    }
}