//半兰博特的像素光照
Shader "Custom/C6_DiffusePixelLit_HalfLambert" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_halfLambert("_halfLambert", Range(0, 0.5)) = 0.5
	}
	SubShader{
		Pass {
			//Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag

			uniform fixed3 _Diffuse;
			fixed _halfLambert;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线得使用顶点变换的逆转置矩阵
				fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				//fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				o.worldNormal = worldNormal;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal, worldLight)*_halfLambert + _halfLambert);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 color = ambient + diffuse;
				return fixed4(color, 1);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
