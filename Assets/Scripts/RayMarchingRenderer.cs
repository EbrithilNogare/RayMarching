using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RayMarchingRenderer : MonoBehaviour
{
    public int maxSpheres;
    public Material rayMarchingMaterial;
    ComputeBuffer textureBuffer;

    private const int WIDTH = 8;
    private const int HEIGHT = 512;

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
        int stride = System.Runtime.InteropServices.Marshal.SizeOf(typeof(Vector4));
        textureBuffer = new ComputeBuffer(WIDTH * HEIGHT, stride, ComputeBufferType.Default);
    }

    private void FillBuffer()
    {
        Vector4[] buffer = new Vector4[WIDTH * HEIGHT];

        for (int i = 0; i < spheres.Count; i++)
        {
            buffer[0 + i * WIDTH] = new Vector4(spheres[i].position.x, spheres[i].position.y, spheres[i].position.z, 0);
            buffer[1 + i * WIDTH] = new Vector4(spheres[i].rotation.x, spheres[i].rotation.y, spheres[i].rotation.z, 0);
            buffer[2 + i * WIDTH] = new Vector4(spheres[i].size.x, spheres[i].size.y, spheres[i].size.z, 0);
            buffer[3 + i * WIDTH] = new Vector4(spheres[i].color.x, spheres[i].color.y, spheres[i].color.z, spheres[i].color.w);
        }
        textureBuffer.SetData(buffer);

        rayMarchingMaterial.SetBuffer("_BufferData", textureBuffer);
        rayMarchingMaterial.SetVector("_CameraPosition", Camera.main.transform.position);
    }

    private void LateUpdate()
    {
        FillBuffer();
        spheres.Clear();
    }
}
