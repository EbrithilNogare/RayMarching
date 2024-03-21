using TMPro;
using UnityEngine;

public class FpsCounter : MonoBehaviour
{
    public float refreshRate;
    private float lastTime;
    private int framesCount;

    void Start()
    {
        lastTime = Time.time;
        framesCount = 0;
    }

    void Update()
    {
        framesCount++;
        if (Time.time - lastTime > refreshRate)
        {
            transform.GetComponent<TextMeshProUGUI>().SetText("FPS: " + Mathf.Round(framesCount / (Time.time - lastTime)));
            lastTime = Time.time;
            framesCount = 0;
        }
    }
}
