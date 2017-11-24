Shader "Custom/Bump Spec" {
	Properties{
		_Shininess("Shiness", Range(0, 1))=0.078134
		_MainTex("Base RGB Gloss(A)", 2D)="white"{}
		[NoScaleOffset] _BumpMap("NormalMap", 2D)="bump"{}
	}	

	SubShader{
		Tags {"RenderType"="Opaque"}
		LOD 200
		CGPROGRAM
		#pragma surface surf MobileBlinnPhong exclude_path:prepass noforwardadd interpolateview halfasview novertexlights

		inline fixed4 LightingMobileBlinnPhong(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{
			fixed nh = max(0, dot(s.Normal, halfDir));
			fixed spec = pow(nh, s.Specular*128) * s.Gloss;
			fixed diff = max(0, dot(s.Normal, lightDir));

			float4 v =  lit(dot(s.Normal, lightDir), dot(s.Normal, halfDir), s.Specular*128);

			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten;
			c.a = 1.0;

			return c;
		}

		uniform sampler2D _MainTex;
		uniform fixed _Shininess;
		uniform sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o)
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

			o.Albedo = c.rgb;
			o.Specular = _Shininess;
			o.Gloss = c.a;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
		}

		ENDCG
	}

	FallBack "Diffuse"
}