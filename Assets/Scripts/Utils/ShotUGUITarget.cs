using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// 对指定的ui截图
/// </summary>
public class ShotUGUITarget : MonoBehaviour
{
    public static Texture2D ShotGameObject(GameObject go, string pngPath, int[] exceptHashs = null, string canvatag = "")
    {
        GameObject camObj = null;
        if (!string.IsNullOrEmpty(canvatag))
        {
            camObj = GameObject.FindGameObjectWithTag(canvatag);
        }
        Canvas canvas;
        if (!camObj)
        {
            canvas = camObj.GetComponent<Canvas>();
        }
        else
        {
            canvas = FindObjectOfType<Canvas>();
        }
        if (canvas == null) return null;
        Canvas cvs = camObj.GetComponentInParent<Canvas>();
        if (!cvs.isRootCanvas)
        {
            Debug.LogError("not right canvas.");
            return Texture2D.blackTexture;
        }
        //screen overlay???
        Camera guiCam = canvas.worldCamera;

        bool formerState = true;
        var statebacks = toggleVisible(cvs.gameObject, false, null, null);
        //let self ok 

        toggleVisible(go, true, exceptHashs, statebacks, true);
        CanvasScaler cvsscalar = cvs.GetComponent<CanvasScaler>();
        Vector2 dr = cvsscalar.referenceResolution;

        var rt = go.GetComponent<RectTransform>();

        float pw = cvs.pixelRect.width / dr.x;
        float ph = cvs.pixelRect.height / dr.y;

        float left = (dr.x * rt.pivot.x + rt.rect.x + rt.anchoredPosition.x) * pw;
        float top = (dr.y - (dr.y * rt.pivot.y + rt.anchoredPosition.y - rt.rect.y)) * ph;

        Texture2D t = ShotCamera(guiCam, cvs.pixelRect,
            new Rect(left, top, rt.rect.width * pw, rt.rect.height * ph),
            pngPath + ".png");

        GameObject temp;
        foreach (var cr in statebacks)
        {
            temp = cr.Key as GameObject;
            if (temp && temp.activeSelf != formerState)
            {
                temp.SetActive(formerState);
            }
        }
        return t;
    }

    static bool check(GameObject go, bool visible, int[] exceptHashs, Dictionary<GameObject, bool> lastStates)
    {
        bool hasExcept = exceptHashs != null;
        bool checkLastStat = lastStates != null;
        bool included = true;
        if(hasExcept)
        {
            foreach(int id in exceptHashs)
            {
                if(id == go.GetHashCode())
                {
                    included = false;
                    break;
                }
            }
        }
        return (go.activeSelf != visible
                && (!hasExcept || included)
                && (!checkLastStat || lastStates.ContainsKey(go) && lastStates[go] == visible));
    }

    static Dictionary<GameObject, bool> toggleVisible(GameObject root, bool visible, int[] exceptHashs, Dictionary<GameObject, bool> lastStates, bool includeinactive = false)
    {
        Dictionary<GameObject, bool> activeObjects = new Dictionary<GameObject, bool>();

        CanvasRenderer com = root.GetComponent<CanvasRenderer>();
        if (com)
        {
            if (check(com.gameObject, visible, exceptHashs, lastStates))
            {
                activeObjects.Add(com.gameObject, !visible);
                com.gameObject.SetActive(visible);
            }
        }

        var crs = root.GetComponentsInChildren<CanvasRenderer>(includeinactive);
        foreach (var cr in crs)
        {
            if (check(cr.gameObject, visible, exceptHashs, lastStates))
            {
                activeObjects.Add(cr.gameObject, !visible);
                cr.gameObject.SetActive(visible);
            }

        }

        Renderer com2 = root.GetComponent<Renderer>();
        if (com2)
        {
            if (check(com2.gameObject, visible, exceptHashs, lastStates))
            {
                activeObjects.Add(com2.gameObject, !visible);
                com2.gameObject.SetActive(visible);
            }
        }

        var renders = root.GetComponentsInChildren<Renderer>(includeinactive);
        foreach (var cr in renders)
        {
            if (check(cr.gameObject, visible, exceptHashs, lastStates))
            {
                activeObjects.Add(cr.gameObject, !visible);
                cr.gameObject.SetActive(visible);
            }
        }

        return activeObjects;
    }

    public static Texture2D ShotCamera(Camera camera, Rect rect, Rect cut, string path)
    {
        Camera mycam = camera;
        RenderTexture rt = new RenderTexture((int)rect.width, (int)rect.height, 0);
        mycam.targetTexture = rt;
        mycam.Render();
        var backup = RenderTexture.active;
        RenderTexture.active = rt;
        Texture2D screenShot = new Texture2D((int)cut.width, (int)cut.height, TextureFormat.ARGB32, false);
        screenShot.ReadPixels(cut, 0, 0);
        screenShot.Apply();

        mycam.targetTexture = null;
        RenderTexture.active = backup;
        GameObject.Destroy(rt);
#if UNITY_EDITOR
        if (!string.IsNullOrEmpty(path))
        {
            byte[] bytes = screenShot.EncodeToPNG();
            try
            {
                System.IO.File.WriteAllBytes(path, bytes);
            }
            catch (System.IO.IOException)
            {
                Debug.LogWarning("Check Path, save file failed.");
            }
        }
#endif

        return screenShot;
    }

    void OnGUI()
    {
        if (GUILayout.Button("ShotTest"))
        {
            ShotGameObject(gameObject, "testShot");
        }
    }
}
