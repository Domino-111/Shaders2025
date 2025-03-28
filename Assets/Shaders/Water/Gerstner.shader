Shader "Custom/Gerstner"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
        
        _WaterFogColor("Water Fog Color", Color) = (0,0,0,0)
        _WaterFogDensity("Water Fog Density", Range(0, 1)) = 0.5
        _RefractionStrength("Refraction Strength", Range(0, 1)) = 0.25
        
        _WaveA("Wave A (Direction, Steepness, Wavelength)", Vector) = (1, 0, 5, 10)
        _WaveB("Wave B (Direction, Steepness, Wavelength)", Vector) = (0, 1, 0.25, 20)
        _WaveC("Wave C (Direction, Steepness, Wavelength)", Vector) = (1, 1, 0.15, 10)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" "Queue"="Transparent"
        }
        
        GrabPass {"_WaterBackground"}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha vertex:vert finalcolor:ResetAlpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 6.0

        #include "LookingThroughWater.cginc"

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
        float4 _WaveA, _WaveB, _WaveC;

        float3 GerstnerWave(float4 wave, float3 pos, inout float3 tangent, inout float3 binormal)
        {
            float2 direction = normalize(wave.xy);
            float steepness = wave.z;
            float wavelength = UNITY_TWO_PI / wave.w;

            float gravity = sqrt(9.81 / wavelength);
            float f = wavelength * (dot(direction, pos.xz) - gravity * _Time.y);
            float amplitude = steepness / wavelength;

            tangent += float3(-direction.x * direction.x * (steepness * sin(f)), direction.x * (steepness * cos(f)), -direction.x * direction.y * (steepness * sin(f)));
            binormal += float3(-direction.x * direction.y * ( steepness * sin(f)), direction.y * ( steepness * cos(f)), -direction.y * direction.y * ( steepness * sin(f)));
            return float3(direction.x * (amplitude * cos(f)), amplitude * sin(f), direction.y * (amplitude * cos(f)));
        }
        
        void vert (inout appdata_full vertexData)
        {
            float3 vert = vertexData.vertex.xyz;
            float3 tangent = float3(1,0,0);
            float3 binormal = float3(0,0,1);
            float3 pos = vert;
            
            pos += GerstnerWave(_WaveA, vert, tangent, binormal);
            pos += GerstnerWave(_WaveB, vert, tangent, binormal);
            pos += GerstnerWave(_WaveC, vert, tangent, binormal);
            
            vertexData.vertex.xyz = pos;
            vertexData.normal = normalize(cross(binormal, tangent));
        }

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            o.Alpha = c.a;
            o.Emission = ColorBelowWater(IN.screenPos, o.Normal) * (1 - c.a);
        }
        void ResetAlpha(Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            color.a = 1;
        }
        
        ENDCG
    }
}
