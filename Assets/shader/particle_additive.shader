Shader "Custom/particle_additive" {
	Properties{
		_MainTex("Particle Texutre", 2D) = "white" {}
	}

	SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True" "PreviewType" = "Plane"}
		Blend SrcAlpha One
	//	Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off Fog{Color (0, 0, 0, 0)}

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
