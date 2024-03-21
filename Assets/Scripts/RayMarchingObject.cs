using UnityEngine;

public class RayMarchingObject : MonoBehaviour
{
    public Color color;
    public RayMarchingRenderer RayMarchingRenderer;

    void Start()
    {

    }

    void Update()
    {
        var self = new Sphere();
        self.position = transform.position;
        self.rotation = transform.rotation.eulerAngles;
        self.size = transform.localScale;
        self.color = color;

        RayMarchingRenderer.spheres.Add(self);
    }
}
