using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float sensitivity = 2f;

    private Vector2 lookInput;
    private Vector2 moveInput;

    void FixedUpdate()
    {
        RotateCamera();
        MoveCamera();
    }

    void RotateCamera()
    {
        lookInput = Mouse.current.delta.ReadValue() * sensitivity * Time.deltaTime;
        transform.Rotate(Vector3.up * lookInput.x);
        transform.Rotate(Vector3.left * lookInput.y);
    }

    void MoveCamera()
    {
        moveInput = new Vector2(
            (Keyboard.current.dKey.isPressed ? 1 : 0) - (Keyboard.current.aKey.isPressed ? 1 : 0),
            (Keyboard.current.wKey.isPressed ? 1 : 0) - (Keyboard.current.sKey.isPressed ? 1 : 0)
        );
        moveInput.Normalize();
        Vector3 moveDirection = transform.right * moveInput.x + transform.forward * moveInput.y;
        transform.position += moveDirection * moveSpeed * Time.deltaTime;
    }
}
