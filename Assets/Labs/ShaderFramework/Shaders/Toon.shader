Shader "ShaderFramework/Toon/Toon"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        
        [Space(15)]
        [Header(Ramp)]
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _RampOffset("Ramp Offset",Range(-1,1)) = 0
        
        [Space(15)]
        [Header(Normal)]
        [Normal]_NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", float) = 1
        
        [Space(15)]
        [Header(Lighting)]
        _LightSize("Light Size",Range(0,1)) = .5
        _LightIntensity("Light Intensity",Range(0,1)) = .5
        _ShadowReceivedIntensity("Shadow Received Intensity",Range(0,1)) = .5
        
        [Space(15)]
        [Header(Spec)]
        _SpecMap("Spec Map",2D) = "black" {}
        _SpecStrength("Spec Strength",Range(0,1)) = .5
        _SpecSmooth("Spec Smooth",Range(0,1)) = .5
        
        [Space(15)]
        [Header(Anisotropic)]
        _AnisotropicColor("Anisotropic Color",Color) = (1,1,1,1)
        _AnisotropicNoise("Anisotropic Noise",2D) = "white" {}
        _AnisotropicNoiseVector("Anisotropic Pow",Vector) = (0,0,0,0)
        _AnisotropicPow("Anisotropic Pow",Range(0,1)) = .5
        _AnisotropicIntensity("Anisotropic Intensity",Range(0,1)) = 0
        _TangentOffset("Tangent Offset",float) = 0
        
        [Space(15)]
        [Header(Ambient)]
        _Roughness("Roughness",Range(0,1)) = .5
        _AmbientStrength("Ambient Strength",Range(0,1)) = .5
        
        [Space(15)]
        [Header(Outline)]
        _OutLineNoise("OutLine Noise",2D) = "black" {}
        _OutLineColor("Outline Color",Color) = (1,1,1,1)
        _OutlineWidth("Outline Width",Range(0,5)) = .5
        
        [Space(15)]
        [Header(Rim)]
        [HDR]_RimColor("Rim Color",Color) = (1,1,1,1)
        _RimIntensity("Rim Intensity", Range(0, 1)) = 0
        _RimSize("Rim Size", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            
            #include "UnityCG.cginc"
            
            
            #pragma multi_compile_instancing

            #include "LightingBase/CustomLighting.cginc"

            #pragma multi_compile_fog
            
            #define _TOON_USE_STANDARD_MODEL
            #define _TOON_BUMP
            #define _TOON_SPECULAR
            #define _TOON_AMBIENT
            #define _TOON_EFFECT
            #define _TOON_RIM
            #define _TOON_ANISOTROPIC 
            #define _TOON_SHADOW_RECEIVE
            
            

            #include "ToonBase/ToonShaderProperties.cginc"
            
            
            #define CUSTOM_AMBIENT_FUNC GetAmbient
            
            half _Roughness;
            float3 GetAmbient(v2f_CustomLighting i)
            {
                #ifdef _GPU_INSTANCE
                    return (GetAmbientGradient(i.worldNormal) + GetReflectionProbe(i, _Roughness)) * GetInstanceProperty(_AmbientStrength);
                #else
                    return (GetAmbientGradient(i.worldNormal) + GetReflectionProbe(i, _Roughness)) * _AmbientStrength;
                #endif
            }

            sampler2D _AnisotropicNoise;
            
            #include "ToonBase/ToonShaderLibrary.cginc"
            
            ENDCG
        }
        
        UsePass "ShaderFramework/Toon/ToonBase/OutlinePass"

        UsePass "ShaderFramework/Lighting/ShadowCaster/ShadowCasterPass"
    }
}
