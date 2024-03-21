using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RayMarchingRenderer : MonoBehaviour
{
    public int maxSpheres;
    public Material rayMarchingMaterial;
    RenderTexture textureBuffer;

    public List<Sphere> spheres;

    private void Start()
    {
        maxSpheres = 10; // todo
        spheres = new List<Sphere>();
        InitializeSphereDataTexture();
        FillBuffer();
    }

    private void InitializeSphereDataTexture()
    {
        textureBuffer = new RenderTexture(8, 512, 0, RenderTextureFormat.ARGBFloat);
        textureBuffer.enableRandomWrite = true;
        textureBuffer.filterMode = FilterMode.Point;
        textureBuffer.Create();

        rayMarchingMaterial.SetTexture("_BufferData", textureBuffer);
    }

    private void FillBuffer()
    {
        var texture = new Texture2D(8, 512, TextureFormat.ARGB32, false);

        for (int i = 0; i < spheres.Count; i++)
        {
            texture.SetPixel(0, i, new Color(spheres[i].position.x, spheres[i].position.y, spheres[i].position.z));
            texture.SetPixel(1, i, new Color(spheres[i].rotation.x, spheres[i].rotation.y, spheres[i].rotation.z));
            texture.SetPixel(2, i, new Color(spheres[i].size.x, spheres[i].size.y, spheres[i].size.z));
            texture.SetPixel(3, i, new Color(spheres[i].color.x, spheres[i].color.y, spheres[i].color.z, spheres[i].color.w));
        }

        texture.Apply();
        rayMarchingMaterial.SetTexture("_BufferData", texture);
    }

    private void LateUpdate()
    {
        FillBuffer();
        spheres.Clear();
    }
}
