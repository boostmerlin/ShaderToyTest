using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DebugShaderProperty))]
public class DebugShaderPropertyEditor : Editor {
    //SerializedProperty propertyNamesProp;

    //void OnEnable()
    //{
    //    propertyNamesProp = serializedObject.FindProperty("inspectPropertyNames");
    //}

    public override void OnInspectorGUI()
    {
        var dsp = ((DebugShaderProperty)target);

        EditorGUILayout.LabelField("Shader Property Name: ");

        if (dsp.inspectPropertyNames == null) dsp.inspectPropertyNames = new string[0];

        int l = dsp.inspectPropertyNames.Length;
        EditorGUI.BeginChangeCheck();
        l = EditorGUILayout.IntField(l, GUILayout.MaxWidth(60));
        if(EditorGUI.EndChangeCheck())
        {
            l = Mathf.Min(l, 10);
            var temp = new string[l];
            System.Array.Copy(dsp.inspectPropertyNames, temp, Mathf.Min(l, dsp.inspectPropertyNames.Length));
            dsp.inspectPropertyNames = temp;
        }

        EditorGUI.BeginChangeCheck();
        for (int i = 0; i < dsp.inspectPropertyNames.Length; i++)
        {
            dsp.inspectPropertyNames[i] = EditorGUILayout.DelayedTextField(dsp.inspectPropertyNames[i]);
        }

        if (EditorGUI.EndChangeCheck())
        {
            dsp.SetDirty(true);
        }
    }
}
