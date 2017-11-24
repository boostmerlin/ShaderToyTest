using UnityEngine;
using System.Collections;

public class RenderWithShader : MonoBehaviour {
    public  Material mat;
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(null, null, mat);
    }
}
