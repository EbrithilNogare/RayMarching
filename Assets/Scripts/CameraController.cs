using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    public float moveSpeed;
    public float sensitivity;

    private Vector2 lookInput;
    private Vector2 moveInput;

    void Update()
    {
        RotateCamera();
        MoveCamera();
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        lookInput = context.ReadValue<Vector2>();
    }

    public void OnMove(InputAction.CallbackContext context)
    {
        moveInput = context.ReadValue<Vector2>();
    }

    void RotateCamera()
    {
        transform.Rotate(Vector3.up * lookInput.x * sensitivity * Time.deltaTime);
        transform.Rotate(Vector3.left * lookInput.y * sensitivity * Time.deltaTime);
    }

    void MoveCamera()
    {
        moveInput.Normalize();
        Vector3 moveDirection = transform.right * moveInput.x + transform.forward * moveInput.y;
        transform.position += moveDirection * moveSpeed * Time.deltaTime;
    }
}
