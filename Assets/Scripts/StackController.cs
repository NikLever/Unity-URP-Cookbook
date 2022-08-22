using UnityEngine;
using UnityEngine.Rendering.Universal;

public class StackController : MonoBehaviour
{
    public Camera overlayCamera;

    // Start is called before the first frame update
    void Start()
    {
        Camera camera = GetComponent<Camera>();
        var cameraData = camera.GetUniversalAdditionalCameraData();
        cameraData.cameraStack.Remove(overlayCamera);
    }
}
