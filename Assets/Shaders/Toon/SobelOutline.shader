Shader "Unlit/SobelOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            float _Step;
            float _EdgeStrength;

            float depth(float4 pos)
            {
                return length(tex2Dproj(_CameraDepthTexture, pos).rgb) * 20;
            }

            float3 sobel(float stepx, float stepy, float4 center)
            {
                float tleft = depth(center + float4(-stepx, stepy, 0, 0));
                float left = depth(center + float4(-stepx, 0, 0, 0));
                float bleft = depth(center + float4(-stepx, -stepy, 0, 0));
                float top = depth(center + float4(0, stepy, 0, 0));
                float bottom = depth(center + float4(0, -stepy, 0, 0));
                float tright = depth(center + float4(stepx, stepy, 0, 0));
                float right = depth(center + float4(stepx, 0, 0, 0));
                float bright = depth(center + float4(stepx, -stepy, 0, 0));

                float x = tleft + 2.0 * left + bleft - tright - 2.0 * right - bright;
                float y = -tleft - 2.0 * top - tright + bleft + 2.0 * bottom + bright;
                float edge = sqrt(x * x + y * y);
                return float3(edge, edge, edge) * _EdgeStrength;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
