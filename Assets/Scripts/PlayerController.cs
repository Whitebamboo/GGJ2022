using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum Direction { Up, Down, Left, Right };
public enum PlayerAction { Move, Interact };

public class PlayerController : GridObject
{
    // Set keys for movement
    public KeyCode upKeycode;
    public KeyCode downKeycode;
    public KeyCode leftKeycode;
    public KeyCode rightKeycode;
    public KeyCode interactKeycode;

    [Tooltip("Indicate whether player movement should cause time to move forward (true) or backward (false)")]
    public bool isForward;

    int moveSpeed = 4;
    Direction playerDirection;

    bool keyDown;

    Vector3 currentPosition;
    Vector3 targetPosition;
    float currentTime;
    bool isMoving = false;

    float cooldownTime = 0.3f;

    void Start()
    {

    }

    void Update()
    {
        if (isMoving)
        {
            transform.position = Vector3.Lerp(currentPosition, targetPosition, currentTime);
            currentTime += moveSpeed * Time.deltaTime;

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
                TryMove();
            }
            else if (Input.GetKey(downKeycode))
            {
                transform.rotation = Quaternion.Euler(0, 180, 0);
                playerDirection = Direction.Down;
                TryMove();
            }
            else if (Input.GetKey(leftKeycode))
            {
                transform.rotation = Quaternion.Euler(0, -90, 0);
                playerDirection = Direction.Left;
                TryMove();
            }
            else if (Input.GetKey(rightKeycode))
            {
                transform.rotation = Quaternion.Euler(0, 90, 0);
                playerDirection = Direction.Right;
                TryMove();
            }
            else if (Input.GetKey(interactKeycode))
            {
                EventBus.Broadcast<PlayerController, PlayerAction, Direction>
                    (EventTypes.PlayerAction, this, PlayerAction.Interact, playerDirection);
            }
        }
    }

    void TryMove() 
    {
        keyDown = true;
        Invoke(nameof(KeyCooldown), cooldownTime);

        EventBus.Broadcast<PlayerController, PlayerAction, Direction>
            (EventTypes.PlayerAction, this, PlayerAction.Move, playerDirection);
    }

    void KeyCooldown() {
        keyDown = false;
    }

    public override void MoveTo(Vector3 newPosition)
    {
        EventBus.Broadcast<bool>(EventTypes.TimeMove, isForward);
        newPosition.y = transform.position.y;

        targetPosition = newPosition;
        currentPosition = transform.position;
        currentTime = 0;
        isMoving = true;
    }
}