using UnityEngine;

public class RayMarchingObject : MonoBehaviour
{
    public Color color;
    public MathematicalStructType type;
    public RayMarchingRenderer rayMarchingRenderer;

    void Start()
    {
        if (type != MathematicalStructType.Light)
        {
            GetComponent<MeshRenderer>().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly;
        }
    }

    void Update()
    {
        switch (type)
        {
            case MathematicalStructType.Light: ConnectLight(); break;
            case MathematicalStructType.Sphere: ConnectSphere(); break;
        }
    }

    void ConnectLight()
    {
        rayMarchingRenderer.lightPosition = transform.position;
        rayMarchingRenderer.lightColor = color * GetComponent<Light>().color;
    }

    void ConnectSphere()
    {
        var self = new Sphere();
        self.position = transform.position;
        self.rotation = transform.rotation.eulerAngles;
        self.size = transform.localScale;
        self.color = color;

        rayMarchingRenderer.spheres.Add(self);
    }
}
