Shader "Unlit/MyFirstShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (0,0,0,1)
        _Scale("Scale UV", float) = 1
        _Offset("Offset UV", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define HALF_TAU UNITY_TWO_PI * 0.5
            #define TAU UNITY_TWO_PI

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tanegnt : TANGENT;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Scale;
            

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
                fixed4 col = float4(i.uv,0,1); //tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
