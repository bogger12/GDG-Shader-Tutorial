using Unity.Cinemachine;
using UnityEngine;

public class SpinCameraSpline : MonoBehaviour
{
    private CinemachineSplineDolly splineDolly;
    public float spinSpeed = 0;
    public bool recording = true;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        splineDolly = GetComponent<CinemachineSplineDolly>();
    }

    // Update is called once per frame
    void Update()
    {
        splineDolly.CameraPosition = recording ? (float)(spinSpeed * Time.time) : (float)(spinSpeed * Time.time % 1.0);
        splineDolly.CameraPosition = Mathf.Clamp01(splineDolly.CameraPosition);
        if (splineDolly.CameraPosition>=1) Debug.Break();
    }
}
