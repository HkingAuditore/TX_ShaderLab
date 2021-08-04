Shader "ShaderFramework/Toon/ToonTest"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        
        [Space(15)]
        [Header(Ramp)]
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _RampOffset("Ramp Offset",Range(-1,1)) = 0
        [Space(15)]
        [Header(Lighting)]
        _LightSize("Light Size",Range(0,1)) = .5
        _LightIntensity("Light Intensity",Range(0,1)) = .5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            Cull Off
            CGPROGRAM

            #define _TOON_USE_STANDARD
            #pragma shader_feature _GPU_INSTANCE
            #include "LightingBase/CustomLighting.cginc"
            #include "ToonBase/ToonShaderLibrary.cginc"
            
            ENDCG
        }
    }
}
