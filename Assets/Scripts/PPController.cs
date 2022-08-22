using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PPController : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Volume volume = GetComponent<Volume>();
        Bloom bloom;
        if (volume.profile.TryGet<Bloom>(out bloom))
        {
            bloom.intensity.value = 0;
        }
    }
}
