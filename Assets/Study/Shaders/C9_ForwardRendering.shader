//多光源 UNITY_SHADER_NO_UPGRADE
Shader "Custom/C9_ForwardRendering" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", float) = 25
	}
	SubShader{
		Pass {
		    //只处理了环境光，像素光，没有处理顶点光，SH光
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			uniform fixed3 _Diffuse;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
				//让物理接收阴影的计算在basspass中
				SHADOW_COORDS(2) //TEXCOORD2
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线得使用顶点变换的逆转置矩阵
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//计算shadow coords
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//UnityWorldSpaceLightDir 该函数有光源类型判断
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal, worldLight)*0.5f + 0.5f);
				fixed3 viewDir = UnityWorldSpaceViewDir(i.worldPos);
				fixed3 halfDir = normalize(worldLight + viewDir);
				fixed3 specular = _LightColor0.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);
				fixed3 color = ambient + (specular + diffuse) * 1;
				fixed shadow = SHADOW_ATTENUATION(i);
				return fixed4(color * shadow, 1);
			}
			ENDCG
		}
		Pass{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend SrcAlpha One
			CGPROGRAM
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			uniform fixed3 _Diffuse;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线得使用顶点变换的逆转置矩阵
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				o.worldNormal = worldNormal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
#ifdef DIRECTIONAL
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed atten = 1.0;
#else
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				//spot 中lightTexture采样是0？？？
				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				//距离计算
				float dis = length(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				atten = 1.0 / dis;
#endif
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal, worldLight)*0.5f + 0.5f);
				fixed3 viewDir = UnityWorldSpaceViewDir(i.worldPos);
				fixed3 halfDir = normalize(worldLight + viewDir);
				fixed3 specular = _LightColor0.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);
				fixed3 color = 0.94f*((specular + diffuse) * atten);
				return fixed4(color, 1);
			}
			ENDCG
		}
		//投射阴影的pass，
		Pass{
			Name "MyShadowCaster"
			Tags {"LightMode" = "ShadowCaster"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v) {
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
				return o;
			}

			float4 frag(v2f i) : SV_TARGET{
				SHADOW_CASTER_FRAGMENT(i);
			}

			ENDCG
		}
	}
	//FallBack "VertexLit"
}
