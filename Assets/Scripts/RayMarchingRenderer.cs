using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RayMarchingRenderer : MonoBehaviour
{
    public Material rayMarchingMaterial;

    private const int WIDTH = 8;
    private const int HEIGHT = 512;

    public List<Sphere> spheres;

    private void Start()
    {
        spheres = new List<Sphere>();

        FillBuffer();
    }

    private void FillBuffer()
    {
        var texture = new Texture2D(WIDTH, HEIGHT, TextureFormat.RGBAFloat, false, false);
        texture.filterMode = FilterMode.Point;

        for (int i = 0; i < spheres.Count; i++)
        {
            texture.SetPixel(0, i, new Vector4(spheres[i].position.x, spheres[i].position.y, spheres[i].position.z));
            texture.SetPixel(1, i, new Vector4(spheres[i].rotation.x, spheres[i].rotation.y, spheres[i].rotation.z));
            texture.SetPixel(2, i, new Vector4(spheres[i].size.x, spheres[i].size.y, spheres[i].size.z));
            texture.SetPixel(3, i, new Vector4(spheres[i].color.x, spheres[i].color.y, spheres[i].color.z, spheres[i].color.w));
        }

        texture.Apply();

        Debug.Log(texture.GetPixel(0, 0).r);

        rayMarchingMaterial.SetTexture("_BufferData", texture);
        rayMarchingMaterial.SetVector("_CameraPosition", Camera.main.transform.position);
    }

    private void LateUpdate()
    {
        FillBuffer();
        spheres.Clear();
    }
}
