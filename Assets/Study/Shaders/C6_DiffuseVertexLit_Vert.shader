// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/C6_DiffuseVertexLit_Vert" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
		SubShader{
			Pass {
				Tags {"LightMode" = "ForwardBase"}
				CGPROGRAM
				#include "Lighting.cginc"
				#pragma vertex vert
				#pragma fragment frag
				/*
				uniform
				uniform变量 外部程序传递给shader的变量.
				函数glUniform**（）函数赋值的.
				shader 中是只读变量,不能被 shader 修改.
				unity 中可以省略
				*/
				uniform fixed3 _Diffuse;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 color : COLOR;//把顶点中计算光照的颜色信息传递给片段
				};

				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					//法线得使用顶点变换的逆转置矩阵
					fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
					//fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLight));

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					o.color = ambient + diffuse;
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET{
					return fixed4(i.color, 1);
				}

				ENDCG
		}
	}

	FallBack "Diffuse"
}
