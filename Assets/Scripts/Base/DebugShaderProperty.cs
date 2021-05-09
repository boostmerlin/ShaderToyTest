using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class DebugShaderProperty : MonoBehaviour {
    Material[] mats;

    public string[] inspectPropertyNames;

    bool isDirty;
	// Use this for initialization
    void showDebugInfo()
    {
        Debug.LogFormat("Renderer {0} Use {1} Materials. ", GetComponent<Renderer>().name, mats.Length);

        if (inspectPropertyNames == null) return;

        foreach(var m in mats)
        {
            Shader s = m.shader;
            Debug.Log("<b>Material : </b>" + m.name + " <b>use shader: </b>" + s.name);
            foreach(var name in inspectPropertyNames)
            {
                if(m.HasProperty(name))
                {
                    var v = m.GetVector(name);

                    Debug.LogFormat("Property: {0} Value: {1}", name, v);
                }
            }
        }
    }

	void Start ()
    {
        mats = GetComponent<Renderer>().sharedMaterials;
        SetDirty(true);
    }

    public void SetDirty(bool isDirty)
    {
        this.isDirty = isDirty;
        if (isDirty)
        {
            showDebugInfo();
            isDirty = false;
        }
    }
}
