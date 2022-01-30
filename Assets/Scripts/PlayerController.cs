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
    public KeyCode undoKeycode;

    int moveSpeed = 3;

    Direction playerDirection
    {
        get { return _playerDirection; }
        set
        {
            _playerDirection = value;
            switch (_playerDirection)
            {
                case Direction.Up: 
                    transform.rotation = Quaternion.Euler(0, 0, 0);
                    break;
                case Direction.Down:
                    transform.rotation = Quaternion.Euler(0, 180, 0);
                    break;
                case Direction.Left:
                    transform.rotation = Quaternion.Euler(0, -90, 0);
                    break;
                case Direction.Right:
                    transform.rotation = Quaternion.Euler(0, 90, 0);
                    break;
                default: break;
            }
        }
    }

    private Direction _playerDirection;

    bool keyDown;

    Vector3 currentPosition;
    Vector3 targetPosition;
    float currentTime;
    bool isMoving = false;
    bool isPushing = false;

    float cooldownTime = 0.3f;
    bool canMove = true;
    bool advanceTimeMove = false;

    public Animator anim;

     private MusicManager musicManager;

    void Start()
    {
        GameObject MM = GameObject.Find("MusicManager");
        if (MM) musicManager = MM.GetComponent<MusicManager>();

        EventBus.AddListener(EventTypes.StopAll, StopAll);
        EventBus.AddListener(EventTypes.LevelComplete, LevelComplete);
        EventBus.AddListener<bool>(EventTypes.PlayerPush, TryPush);
    }

    private void OnDestroy() 
    {
        EventBus.RemoveListener(EventTypes.StopAll, StopAll);
        EventBus.RemoveListener(EventTypes.LevelComplete, LevelComplete);
        EventBus.RemoveListener<bool>(EventTypes.PlayerPush, TryPush);
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
                canMove = true;

                if (!isPushing) {
                    anim.SetBool("Move", false);
                }
                if (advanceTimeMove) EventBus.Broadcast<bool>(EventTypes.TimeMoveEnd, isForward);
                isPushing = false;
            }
        }
        
        if (!canMove) return;
        if (!keyDown)
        {
            if (Input.GetKey(upKeycode))
            {
                playerDirection = Direction.Up;
                TryMove();
            }
            else if (Input.GetKey(downKeycode))
            {
                playerDirection = Direction.Down;
                TryMove();
            }
            else if (Input.GetKey(leftKeycode))
            {
                playerDirection = Direction.Left;
                TryMove();
            }
            else if (Input.GetKey(rightKeycode))
            {
                playerDirection = Direction.Right;
                TryMove();
            }
            else if (Input.GetKey(interactKeycode))
            {
                TryInteract();
            }
            else if (Input.GetKey(undoKeycode)) 
            {
                TryUndo();
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

    void TryUndo() 
    {
        keyDown = true;
        Invoke(nameof(KeyCooldown), cooldownTime);

        EventBus.Broadcast<bool>(EventTypes.UndoLastMove, isForward);
    }

    void TryInteract()
    {
        keyDown = true;
        Invoke(nameof(KeyCooldown), cooldownTime);

        EventBus.Broadcast<PlayerController, PlayerAction, Direction>
            (EventTypes.PlayerAction, this, PlayerAction.Interact, playerDirection);
    }

    void KeyCooldown() {
        keyDown = false;
    }

    public override void MoveTo(Vector3 newPosition)
    {
        canMove = false;
        newPosition.y = transform.position.y;

        targetPosition = newPosition;
        currentPosition = transform.position;
        currentTime = 0;
        isMoving = true;

        if (musicManager) musicManager.PlayWalkSFX();
        if (!isPushing) {
            anim.SetBool("Move", true);
        }
        advanceTimeMove = true;
    }

    public void MoveTo(Vector3 newPosition,bool canmove)
    {
        canMove = false;
        newPosition.y = transform.position.y;

        targetPosition = newPosition;
        //print(targetPosition);
        
        currentPosition = transform.position;
        //print(currentPosition);
        currentTime = 0;
        isMoving = true;   

        if (musicManager) musicManager.PlayWalkSFX();
        if (!isPushing) {
            anim.SetBool("Move", true);
        }
        advanceTimeMove = false;
    }

    public void ChangeDirection(Direction dir) 
    {
        playerDirection = dir;
    }

    public void StopAll() 
    {
        canMove = false;
    }

    public void LevelComplete() 
    {
        anim.SetBool("Celebrate", true);
    }

    public void TryPush(bool isForward)
    {
        if (this.isForward != isForward) return;
        if (musicManager) musicManager.PlayPushSFX();
        anim.SetTrigger("Push");
        isPushing = true;
    }

    public override bool Equals(GridObject otherObject)
    {
        return otherObject.GetComponent<PlayerController>() != null;
    }
}