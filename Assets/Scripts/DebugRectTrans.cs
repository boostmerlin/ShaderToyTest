using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DebugRectTrans : MonoBehaviour {
    RectTransform rectTransform;
    // Use this for initialization
    public Vector2 sizeDelta;
    public Vector2 anchoredPosition;

    public struct TestStruct
    {
        public TestStruct(int a)
        {
            this.a = a;
            action = null;
        }
        public int a;
        public System.Action action;
    }

    Dictionary<int, TestStruct> dict = new Dictionary<int, TestStruct>();

    void Start () {
        rectTransform = GetComponent<RectTransform>();
        Debug.Log("Sizedelta: " + rectTransform.sizeDelta);
        Debug.Log("anchoredPosition: " + rectTransform.anchoredPosition);
        sizeDelta = rectTransform.sizeDelta;
        var teststruct = new TestStruct(2);
        dict.Add(1, teststruct);

        teststruct.action = delegate ()
        {
            Debug.Log(teststruct.a);
        };
        int b = 1;
    }

    private void OnGUI()
    {
        if (GUILayout.Button("xxx"))
        {
            var s = dict[1];
            s.a = 3;
        }
    }

    // Update is called once per frame
    void Update () {
		if(sizeDelta != rectTransform.sizeDelta)
        {
            rectTransform.sizeDelta = sizeDelta;
        }

        if (anchoredPosition != rectTransform.anchoredPosition)
        {
            rectTransform.anchoredPosition = anchoredPosition;
        }
        var t  = dict[1].action;
        if(t == null)
        {
            Debug.Log("null");
        }
        else
        {
            t();
        }
    }
}
