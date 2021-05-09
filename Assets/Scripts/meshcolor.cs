using UnityEngine;

public class meshcolor : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Mesh mesh = GetComponent<MeshFilter>().mesh;
        Color[] colors = new Color[mesh.vertexCount];
        colors[0] = Color.red;
        colors[1] = Color.green;
        colors[2] = Color.cyan;
        colors[3] = Color.blue;
        mesh.colors = colors;
  
    }
	
	// Update is called once per frame
	void Update () {
	
	}
}
