using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class StandardRenderRequest : MonoBehaviour
{
    [SerializeField]
    RenderTexture texture2D;

    private void Start()
    {
        texture2D = new RenderTexture(1920, 1080, 24);
    }

    // When user clicks on GUI button,
    // Render Requests are sent with various output textures to render given frame
    private void OnGUI()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("Render Request"))
        {
            RenderRequest();
        }
        GUILayout.EndVertical();
    }

    void RenderRequest()
    {
        Camera cam = GetComponent<Camera>();

        RenderPipeline.StandardRequest request = new RenderPipeline.StandardRequest();

        if (RenderPipeline.SupportsRenderRequest(cam, request))
        {
            // 2D Texture
            request.destination = texture2D;
            RenderPipeline.SubmitRenderRequest(cam, request);

            SaveTexture(ToTexture2D(texture2D));
        }
    }

    void SaveTexture(Texture2D texture)
    {
        byte[] bytes = texture.EncodeToPNG();
        var dirPath = Application.dataPath + "/RenderOutput";
        if (!System.IO.Directory.Exists(dirPath))
        {
            System.IO.Directory.CreateDirectory(dirPath);
        }
        System.IO.File.WriteAllBytes(dirPath + "/R_" + Random.Range(0, 100000) + ".png", bytes);
        Debug.Log(bytes.Length / 1024 + "Kb was saved as: " + dirPath);
        #if UNITY_EDITOR
                UnityEditor.AssetDatabase.Refresh();
        #endif
    }

    Texture2D ToTexture2D(RenderTexture rTex)
    {
        Texture2D tex = new Texture2D(rTex.width, rTex.height, TextureFormat.RGB24, false);
        RenderTexture.active = rTex;
        tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
        tex.Apply();
        Destroy(tex);//prevents memory leak
        return tex;
    }
}