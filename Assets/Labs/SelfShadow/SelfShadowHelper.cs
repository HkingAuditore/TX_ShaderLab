using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelfShadowHelper : MonoBehaviour
{
    public Light mainDirectionalLight;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private Vector3 GetShadowPlanePos(Transform obj)
    {
        Ray ray = new Ray(transform.position, mainDirectionalLight.transform.forward);
        RaycastHit hit;
        // Does the ray intersect any objects excluding the player layer
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit, Mathf.Infinity, layerMask))
        {
            Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward) * hit.distance, Color.yellow);
            Debug.Log("Did Hit");
        }
    }
}
