using DG.Tweening;
using UnityEngine;
public class RandomMovement : MonoBehaviour
{
    public Transform minPosition;
    public Transform maxPosition;
    public float movementDuration;

    private void Start()
    {
        movementDuration = Random.Range(movementDuration * .8f, movementDuration * 1.2f);
        if (Random.Range(0, 2) < 1)
            MoveToMax();
        else
            MoveToMin();
    }

    private void MoveToMax()
    {
        Vector3 nextPosition = Random.insideUnitSphere;
        nextPosition.Scale((maxPosition.localScale - transform.localScale) / 2);
        nextPosition += maxPosition.position;

        transform.DOMove(nextPosition, movementDuration)
            .SetSpeedBased(true)
            .SetEase(Ease.Linear)
            .OnComplete(() =>
            {
                MoveToMin();
            });
    }
    private void MoveToMin()
    {
        Vector3 nextPosition = Random.insideUnitSphere;
        nextPosition.Scale((minPosition.localScale - transform.localScale) / 2);
        nextPosition += minPosition.position;

        transform.DOMove(nextPosition, movementDuration)
            .SetSpeedBased(true)
            .SetEase(Ease.Linear)
            .OnComplete(() =>
            {
                MoveToMax();
            });
    }
}
