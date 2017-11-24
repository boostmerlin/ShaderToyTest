Shader "Shadertoy/DotLine" { 
    Properties{
        _Pt1 ("Start Point", Vector) = (100, 100, 0, 0)
		_Pt2("End Point", Vector) = (200, 50, 0, 0)
        _Radius("Dot Width", float) = 1
		_LineWidth("Line Width", float) = 1
        _DotColor ("Dot Color", Color) = (1, 0, 0, 0)
		_LineColor ("Line Color", Color) = (1, 0, 0, 0)
		_BgColor("Background Color", Color) = (0, 1, 0, 0)
		_Antialias("Anti alias Value", Range(0, 3)) = 1.5
    }

    CGINCLUDE    
    #include "UnityCG.cginc"   
    #pragma target 3.0      

    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define iGlobalTime _Time.y
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

    #define PI2 6.28318530718
    #define pi 3.14159265358979
    #define halfpi (pi * 0.5)
    #define oneoverpi (1.0 / pi)

    float _Radius;
    float4 _DotColor;
	float4 _LineColor;
	float4 _LineWidth;
	float4 _BgColor;
	float _Antialias;
	fixed4 _Pt1;
	fixed4 _Pt2;

    struct v2f {    
        float4 pos : SV_POSITION;    
        float4 scrPos : TEXCOORD0;  
    };              

    v2f vert(appdata_base v) {  
        v2f o;
        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
        o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }  

    vec4 main(vec2 fragCoord, v2f i);

    fixed4 frag(v2f _iParam) : SV_Target { 
        vec2 fragCoord = gl_FragCoord;
        return main(fragCoord, _iParam);
    }  

	vec4 circle(vec2 pos, vec2 center, float r, vec4 c)
	{
	    float d = distance(pos, center) - r;
		float a = smoothstep(0, _Antialias, d);

		return vec4(c.rgb, 1-a);
	}

	vec4 dline(vec2 pos, vec2 pt1, vec2 pt2, float w, vec4 c)
	{
	    float k = (pt2.y - pt1.y) / (pt2.x - pt1.x);
		float b = pt1.y - k * pt1.x;
		float d = abs(k*pos.x - pos.y + b) / sqrt(k*k + 1);
		float a = smoothstep(w * .5, w * .5 + _Antialias, d);

		return vec4(c.rgb, 1-a);
	}

    vec4 main(vec2 fragCoord, v2f i) {
		vec4 layer1 = _BgColor;

		vec4 layerLine = dline(fragCoord, _Pt1, _Pt2, _LineWidth, _LineColor);

		vec4 layer2 = circle(fragCoord, _Pt1, _Radius, _DotColor);
		vec4 layer3 = circle(fragCoord, _Pt2, _Radius, _DotColor);

		vec4 c = mix(layer1, layerLine, layerLine.a);
		c = mix(c, layer2, layer2.a);
		c = mix(c, layer3, layer3.a);
        return c;
    }

    ENDCG    

    SubShader {    
        Pass {    
            CGPROGRAM    
            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        }    
    }     
    FallBack Off    
}