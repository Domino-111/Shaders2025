Shader "Unlit/BLIP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss", range(0, 1)) = 1
        _Color("Color", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "BLIP.cginc"
            
            ENDCG
        }

        //Additional pass
        Pass
        {
            Blend One One
            Tags { "LightMode" = "ForwardAdd" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "BLIP.cginc"
            
            ENDCG 
        }
    }
}
