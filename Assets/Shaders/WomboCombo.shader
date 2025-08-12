Shader "Unlit/WomboCombo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RotateAngle ("Rotate Angle", Range(-90,90)) = 45
        _Thresholds ("Thresholds", Vector) = (0.2,0.4,0.6,0.8)
    }
    SubShader
    {
        LOD 100


        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float4 screenPos : TEXCOORD2;
                float3 wPos : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _RotateAngle;
            float4 _Thresholds;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                // compute shadows data
                TRANSFER_SHADOW(o);
                o.screenPos = ComputeScreenPos(o.pos);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 colorTex = tex2D(_MainTex, i.uv);
                fixed shadow = SHADOW_ATTENUATION(i);
                // return float4(i.normal,1);
                float3 N = normalize(i.normal);
                
                float3 L = _WorldSpaceLightPos0.xyz; // vector from surface to light source
                float3 lambert = saturate(dot( N, L));
                float3 diff = lambert * _LightColor0.xyz;

                // specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 H = normalize(L + V);
                // float3 R = reflect(-L, N); // used for Phong

                float3 spec = saturate(dot(H,N)) * (lambert > 0); // Blinn-Phong

                float specularExponent = exp2(0.5*8) + 2;
                spec = pow(spec, specularExponent);
                spec *= _LightColor0.rgb;

                float3 ambient = 0.1;

                float3 lighting = (diff * shadow + ambient + spec * shadow);

                float angleRadians = (_RotateAngle / 180)*UNITY_PI;
                float2 screenXY = i.screenPos.xy / i.screenPos.w;
                screenXY -= float2(0.5,0.5);
                float2 rotatedXY = float2(screenXY.x*cos(angleRadians)-screenXY.y*sin(angleRadians), screenXY.x*sin(angleRadians) + screenXY.y*cos(angleRadians));
                rotatedXY += float2(0.5,0.5);
                float gradient = rotatedXY.x;

                if (gradient < _Thresholds[0]) {
                    return float4(i.wPos,1);
                } else if (gradient < _Thresholds[1]) {
                    return float4(N,1);
                } else if (gradient < _Thresholds[2]) {
                    return float4(i.uv,0,1);
                } else if (gradient < _Thresholds[3]) {
                    return float4(lighting,1);
                } else {
                    return float4(colorTex*lighting,1);
                }
            }
            ENDHLSL
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
