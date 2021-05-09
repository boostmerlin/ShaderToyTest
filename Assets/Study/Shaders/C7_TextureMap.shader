Shader "Custom/C7_TextureMap" {
	Properties{
		_SpecularColor("Specular", Color) = (1, 1, 1, 1)
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
		_halfLambert("HalfLambert", Range(0, 0.5)) = 0.5
		_MainTex("MainTexture", 2D) = "white" {}
		_BumpMap("BumpMap",2D) = "bump" {}
		_BumpScale("BumpScale", float) = 1
	}
	SubShader{
		Pass {
			//不设置lightMode，会有问题，移动观察方向会突变。因为forwardbase or forwardadd, _WorldSpaceLightPos0才可使用
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#include "Lighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			//在切线空间下计算光照
			#define COMPUTE_IN_TANGENT_SPACE

			fixed _halfLambert;
			fixed4 _SpecularColor;
			float _Gloss;
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;


			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				fixed2 texcoord : TEXCOORD0;
#ifdef COMPUTE_IN_TANGENT_SPACE
				//切线
				float4 tangent : TANGENT;
#else
#endif
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
#ifdef COMPUTE_IN_TANGENT_SPACE
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
#else           //在世界空间下计算光照
				fixed3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
#endif
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
#ifdef COMPUTE_IN_TANGENT_SPACE
				//副切线,tangent.w 决定了方向
				float3 binormal = normalize(cross(v.normal, v.tangent.xyz) * v.tangent.w);
				//注意切线空间的定义：x 切线方向，z 法线方向，y为计算得到的副切线方向
				//只有旋转，是正交矩阵
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				//UNITY 内置宏
				//TANGENT_SPACE_ROTATION;
				o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
				o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);
#else           //在世界空间下计算光照
				//法线得使用原顶点变换的逆转置矩阵
				//fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
				//fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);//bump 和 main 使用同一组uv
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET{
				fixed4 packedNormal = tex2D(_BumpMap, i.uv);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
#ifdef COMPUTE_IN_TANGENT_SPACE
				fixed3 normal = tangentNormal;
				fixed3 lightDir = i.lightDir;
				fixed3 viewDir = i.viewDir;
#else
				fixed3 normal = i.worldNormal;
				//fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 lightDir = worldLight;
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
#endif
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * (dot(normal, lightDir)*_halfLambert + _halfLambert);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//Specular:
				fixed3 halfDir = normalize(viewDir + lightDir);
				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(halfDir, normal)), _Gloss);

				fixed3 color = ambient + diffuse + specular;
				return fixed4(color, 1);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
