using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeLightLayer : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Renderer renderer = GetComponent<Renderer>();

        int layerID = 1;// LayerMask.NameToLayer("Highlight");
        Debug.Log("LayerID = " + layerID);
        int mask = 1 << layerID;
        Debug.Log("mask = " + mask);
        renderer.renderingLayerMask = (uint)mask;
    }
}
