using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class AddDecal : MonoBehaviour
{
    public GameObject decalProjectorPrefab;
    private new Camera camera;


    void Start()
    {
        

        camera = Camera.main;

    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            Ray ray = camera.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast(ray, out hit))
            {
                Debug.LogFormat("Pos:{0} Normal:{1}", hit.point, hit.normal);
                AddDecalProjector(hit.point, hit.normal);
            }
        }
    }

    void AddDecalProjector(Vector3 pos, Vector3 normal)
    {
        GameObject decalProjectorObject = Instantiate(decalProjectorPrefab);
        DecalProjector decalProjectorComponent = decalProjectorObject.GetComponent<DecalProjector>();

        // Creates a new material instance for the DecalProjector.
        decalProjectorComponent.material = new Material(decalProjectorComponent.material);

        //Move away from surface
        pos += normal * 0.5f;

        Quaternion up = Quaternion.AngleAxis(Random.Range(0, 360), Vector3.left);
        Quaternion rot = Quaternion.LookRotation(-normal, up.eulerAngles);

        decalProjectorObject.transform.SetPositionAndRotation(pos, rot);
    }

}
