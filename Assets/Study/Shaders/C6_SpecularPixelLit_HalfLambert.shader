Shader "Custom/C6_SpecularPixelLit_HalfLambert" {
	Properties{
		_Diffuse("Diffuse", Color) = (0.5, 0.8, 0.5, 1)
		_SpecularColor("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", float) = 20
		_halfLambert("_halfLambert", Range(0, 0.5)) = 0.5
	}
	SubShader{
		Pass {
			//不设置lightMode，会有问题，移动观察方向会突变。
			//Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#define BLINN_PHONG

			uniform fixed3 _Diffuse;
			fixed _halfLambert;
			fixed3 _SpecularColor;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线得使用顶点变换的逆转置矩阵(非统一缩放)
				fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				//fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal, worldLight)*_halfLambert + _halfLambert);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//Specular:
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
#ifdef BLINN_PHONG
				fixed3 halfDir = normalize(viewDir + worldLight);
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(halfDir, i.worldNormal)), _Gloss);
#else
				fixed3 reflectDir = normalize(reflect(-worldLight, i.worldNormal));
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
#endif

				fixed3 color = ambient + diffuse + specular;
				return fixed4(color, 1);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
