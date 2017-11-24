Shader "Custom/particle_vertex_blended" {
	Properties{
		_MainTex("Particle Texutre", 2D) = "white" {}
		_EmisColor("Emissive Color", Color) = (.2, .2, .2, 0)
	}

	SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off ZWrite Off Fog{Color (0, 0, 0, 0)}
		Lighting On

		Material {
			Emission [_EmisColor]
		}

		ColorMaterial AmbientAndDiffuse

		BindChannels{
			bind "Vertex", vertex
			bind "Color", color
			bind "TexCoord", texcoord
		}

		Pass{
			 SetTexture[_MainTex]{
					combine texture * primary
			 }
		}
	}
}
