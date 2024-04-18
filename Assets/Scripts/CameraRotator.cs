using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotator : MonoBehaviour
{
    // Start is called before the first frame update
    public Vector3 LookingPosition;
    public float loopTime;
    public float distance;

    private void Start()
    {
        distance = Vector3.Distance(transform.position, LookingPosition);
    }

    // Update is called once per frame
    void Update()
    {
        // Calculate the rotation angle based on time
        float angle = Time.time * 360.0f / loopTime;

        // Calculate the new position of the camera
        Vector3 offset = new Vector3(Mathf.Sin(angle * Mathf.Deg2Rad), 0, Mathf.Cos(angle * Mathf.Deg2Rad));
        transform.position = LookingPosition + offset * distance; // Adjust the 5.0f according to your desired distance from the object

        // Ensure the camera is always looking at the target
        transform.LookAt(LookingPosition);

    }
}
