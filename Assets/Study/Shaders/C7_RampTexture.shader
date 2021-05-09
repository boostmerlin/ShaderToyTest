//贴图中可以存储任何信息，比如渐近纹理来控制光照
Shader "Custom/C7_RampTexture" {
	Properties{
		_Color("DiffuseColor", Color) = (0.5, 0.8, 0.5, 1)
		_SpecularColor("Specular", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", float) = 20
		_RampTex("Ramp Texture", 2D) = "white" {}
	}
	SubShader{
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

			fixed3 _Color;
			fixed3 _SpecularColor;
			float _Gloss;
			sampler2D _RampTex;
			half4 _RampTex_ST;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线得使用顶点变换的逆转置矩阵
				fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed halfLambert = (dot(i.worldNormal, worldLight)*0.5 + 0.5);

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;
				//fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_RampTex, i.uv).rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLight);
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);

				fixed3 color = 0.7*(ambient + diffuse + specular);
				return fixed4(color, 1);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
