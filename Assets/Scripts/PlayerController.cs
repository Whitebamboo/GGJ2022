using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Direction { Up, Down, Left, Right };

public class PlayerController : GridObject
{
    // Set keys for movement
    public KeyCode upKeycode;
    public KeyCode downKeycode;
    public KeyCode leftKeycode;
    public KeyCode rightKeycode;

    public GridController gridController;

    [Tooltip("Indicate whether player movement should cause time to move forward (1) or backward (-1)")]
    [Range(-1,1)]
    public int moveFactor;
    
    int playerRow = 0;
    int playerCol = 0;
    Direction playerDirection;

    bool keyDown;

    Vector3 currentPosition;
    Vector3 targetPosition;
    float currentTime;
    bool isMoving = false;

    float cooldownTime = 0.3f;

    void Start()
    {
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
            if (Input.GetKey(upKeycode))
            {
                transform.rotation = Quaternion.Euler(0, 0, 0);
                playerDirection = Direction.Up;
                TryMove(playerRow + 1, playerCol);
            }
            else if (Input.GetKey(downKeycode))
            {
                transform.rotation = Quaternion.Euler(0, 180, 0);
                playerDirection = Direction.Down;
                TryMove(playerRow - 1, playerCol);
            }
            else if (Input.GetKey(leftKeycode))
            {
                transform.rotation = Quaternion.Euler(0, -90, 0);
                playerDirection = Direction.Left;
                TryMove(playerRow, playerCol - 1);
            }
            else if (Input.GetKey(rightKeycode))
            {
                transform.rotation = Quaternion.Euler(0, 90, 0);
                playerDirection = Direction.Right;
                TryMove(playerRow, playerCol + 1);
            }
        }
    }

    void TryMove(int newRow, int newCol)
    {
        keyDown = true;

        if (!gridController.IsValidPosition(newRow, newCol)) return;
        if (gridController.GetPositionObject(newRow, newCol) != null) return;

        EventBus.Broadcast<int>(EventTypes.PlayerMove, moveFactor);

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

        Invoke(nameof(KeyCooldown), cooldownTime);
    }

    void KeyCooldown() {
        keyDown = false;
    }
}