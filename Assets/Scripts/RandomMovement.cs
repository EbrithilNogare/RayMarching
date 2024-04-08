using UnityEngine;

public class RandomMovement : MonoBehaviour
{
    public Transform minPosition;
    public Transform maxPosition;
    public float movementDuration;
    private float elapsedTime;
    private bool movingToMax;

    private void Start()
    {
        elapsedTime = Random.Range(0, movementDuration);
        movementDuration = Random.Range(movementDuration * .8f, movementDuration * 1.2f);
        movingToMax = true;
    }

    void Update()
    {
        elapsedTime += movingToMax ? Time.deltaTime : -Time.deltaTime;

        transform.position = Vector3.Lerp(minPosition.position, maxPosition.position, Mathf.Clamp01(elapsedTime / movementDuration));

        if (elapsedTime >= movementDuration && movingToMax)
        {
            movingToMax = false;
        }

        if (elapsedTime <= 0f && !movingToMax)
        {
            movingToMax = true;
        }
    }
}
