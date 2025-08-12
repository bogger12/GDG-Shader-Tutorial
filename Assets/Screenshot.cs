    using UnityEngine;

    public class Screenshot : MonoBehaviour
    {
        public string screenshotFileName = "Assets/Screenshot.png";
        public int screenshotScale = 1; // 1 for exact resolution, 2 for scaled up

        void Update()
        {
            if (Input.GetKeyDown(KeyCode.Space)) // Example: Capture on Spacebar press
            {
                ScreenCapture.CaptureScreenshot(screenshotFileName, screenshotScale);
                Debug.Log("Screenshot captured: " + screenshotFileName);
            }
        }
    }