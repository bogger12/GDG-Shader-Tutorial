using Unity.Cinemachine;
using UnityEngine;

public class SpinCamera : MonoBehaviour
{
    public CinemachineOrbitalFollow orbitalFollow;
    public float spinSpeed = 0;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        orbitalFollow = GetComponent<CinemachineOrbitalFollow>();
    }

    // Update is called once per frame
    void Update()
    {
        orbitalFollow.HorizontalAxis.Value = -180 + spinSpeed * Time.time;
    }
}
