Shader "Custom/mobileDiffuse" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		[NoScaleOffset] [Normal] _BumpMap("Normal", 2D) = "bump"{}
	}

	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 150

		CGPROGRAM
		#pragma surface surf Lambert noforwardadd  

		uniform sampler2D _MainTex;
		uniform sampler2D _BumpMap;
		struct Input{
		     float2 uv_MainTex;
		} ;

		void surf(Input IN, inout SurfaceOutput o)
		{
		    fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
		}

		ENDCG
	}
}
