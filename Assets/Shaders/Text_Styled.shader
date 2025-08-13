Shader "Unlit/Normals"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ColorVSNormal ("Color VS Normal", Range(0,1)) = 0.5
        _OutlineColor ("OutlineColor", Color) = (1,0,0,1)
        _OutlineWidth ("OutlineWidth", Range(0,1)) = 1.0
        _NormalVSWorldSpace ("NormalVSWorldSpace", Range(0,1)) = 0.0
        _ColorChangeSpeed ("ColorChangeSpeed", Float) = 1.0
        _XAffectColor ("XAffectColor", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // All components are in the range [0…1], including hue.
            float3 rgb2hsv(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            // All components are in the range [0…1], including hue.
            float3 hsv2rgb(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 wPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Color;
            float _ColorVSNormal;
            float _ColorChangeSpeed;
            float _XAffectColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld,v.vertex );
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Rotate colour around HSV using Time
                float3 colorRGB = _Color;
                float3 colorHSV = rgb2hsv(colorRGB);
                // Add world X position offset and color change over time 
                colorHSV.x += (i.wPos.x*_XAffectColor) +_Time.y * _ColorChangeSpeed;
                colorRGB = hsv2rgb(colorHSV);
                
                // return float4(lerp(i.normal, _Color, _ColorVSNormal), 1);
                return float4(((i.normal*_ColorVSNormal))+ (colorRGB/_ColorVSNormal), 1);
            }
            ENDCG
        }

        // Outline Pass
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float _OutlineWidth;
            float4 _OutlineColor;
            float _NormalVSWorldSpace;

            v2f vert (appdata v)
            {
                v2f o;
                float4 objectPos = (v.vertex + v.vertex * _OutlineWidth)*(_NormalVSWorldSpace) + (v.vertex + float4(normalize(v.normal) * _OutlineWidth, 1)) * (1-_NormalVSWorldSpace);
                o.pos = UnityObjectToClipPos(objectPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
