using UnityEngine;

public class MenuController : MonoBehaviour
{
    public Material rayMarchingMaterial;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void SetFast()
    {
        rayMarchingMaterial.EnableKeyword("_STEPS_FAST");
        rayMarchingMaterial.DisableKeyword("_STEPS_NORMAL");
        rayMarchingMaterial.DisableKeyword("_STEPS_GOOD");
        rayMarchingMaterial.DisableKeyword("_STEPS_BEST");
    }

    public void SetNormal()
    {
        rayMarchingMaterial.DisableKeyword("_STEPS_FAST");
        rayMarchingMaterial.EnableKeyword("_STEPS_NORMAL");
        rayMarchingMaterial.DisableKeyword("_STEPS_GOOD");
        rayMarchingMaterial.DisableKeyword("_STEPS_BEST");
    }

    public void SetGood()
    {
        rayMarchingMaterial.DisableKeyword("_STEPS_FAST");
        rayMarchingMaterial.DisableKeyword("_STEPS_NORMAL");
        rayMarchingMaterial.EnableKeyword("_STEPS_GOOD");
        rayMarchingMaterial.DisableKeyword("_STEPS_BEST");
    }

    public void SetBest()
    {
        rayMarchingMaterial.DisableKeyword("_STEPS_FAST");
        rayMarchingMaterial.DisableKeyword("_STEPS_NORMAL");
        rayMarchingMaterial.DisableKeyword("_STEPS_GOOD");
        rayMarchingMaterial.EnableKeyword("_STEPS_BEST");
    }
}
