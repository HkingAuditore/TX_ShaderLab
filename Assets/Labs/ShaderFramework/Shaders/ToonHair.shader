Shader "ShaderFramework/Toon/ToonHair"
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
        _SpecMap("Spec Map",2D) = "white" {}
        _SpecStrength("Spec Strength",Range(0,1)) = .5
        _SpecSmooth("Spec Smooth",Range(0,1)) = .5
        
        [Space(15)]
        [Header(Anisotropic)]
        _AnisotropicColor("Anisotropic Color",Color) = (1,1,1,1)
        _AnisotropicNoise("Anisotropic Noise",2D) = "black" {}
        _AnisotropicNoiseVector("Anisotropic Noise Vector",Vector) = (0,0,0,0)
        _AnisotropicPow("Anisotropic Pow",Range(-1,1)) = .5
        _AnisotropicIntensity("Anisotropic Intensity",Range(0,1)) = 0
        _TangentOffset("Tangent Offset",float) = 0
        
        [Space(15)]
        [Header(Ambient)]
        _Roughness("Roughness",Range(0,1)) = .5
        _AmbientStrength("Ambient Strength",Range(0,1)) = .5
        
        [Space(15)]
        [Header(Outline)]
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
            #pragma multi_compile_fog
            #pragma multi_compile __ _GPU_INSTANCE
            
            
            #define _TOON_USE_STANDARD
            #define _TOON_BUMP
            #define _TOON_SPECULAR
            #define _TOON_AMBIENT
            #define _TOON_EFFECT
            #define _TOON_RIM
            #define _TOON_ANISOTROPIC 
            #define _TOON_RECEIVE_SHADOW
            #define _GPU_INSTANCE
            
            
            #include "LightingBase/CustomLighting.cginc"
            #include "ToonBase/ToonShaderProperties.cginc"

            
            sampler2D _AnisotropicNoise;
            half4 _AnisotropicNoiseVector;
            
            #define CUSTOM_EFFECT_FUNC GetEffect
            float4 GetEffect(v2f_CustomLighting i)
            {
                #ifndef _GPU_INSTANCE
                    float4 col = float4(0,0,0,0);
                    //各向异性
                    #ifdef _TOON_ANISOTROPIC
                        half noise = tex2D(_AnisotropicNoise,i.uv);
                        half anisotropic = GetKajiyaKay(i, noise,_AnisotropicNoiseVector.x,_AnisotropicNoiseVector.y,_AnisotropicNoiseVector.z,_AnisotropicNoiseVector.w);
                        anisotropic = Contrast(anisotropic, _AnisotropicPow, 10, _AnisotropicIntensity);
                        col = AlphaBlend(col,half4( _AnisotropicColor.rgb, _AnisotropicColor.a * anisotropic));
                    #endif

                    //边缘光
                    #ifdef _TOON_RIM
                        col = AlphaBlend(col,half4(_RimColor.rgb,_RimColor.a * GetFresnel(i.viewDir, i.worldNormal, _RimSize, _RimIntensity)));
                    #endif
                    return col;
                #else
                    float4 col = float4(0,0,0,0);
                    //各向异性
                    #ifdef _TOON_ANISOTROPIC
                        half noise = tex2D(_AnisotropicNoise,i.uv);
                        half anisotropic = GetKajiyaKay(i, noise,_AnisotropicNoiseVector.x,_AnisotropicNoiseVector.y,_AnisotropicNoiseVector.z,_AnisotropicNoiseVector.w);
                        anisotropic = Contrast(anisotropic, GetInstanceProperty(_AnisotropicPow), 8) * GetInstanceProperty(_AnisotropicIntensity);
                        col = AlphaBlend(col,half4( GetInstanceProperty(_AnisotropicColor).rgb, GetInstanceProperty(_AnisotropicColor).a * anisotropic));
                    #endif
    
                    //边缘光
                    #ifdef _TOON_RIM
                        float rim = GetFresnel(i.viewDir, i.worldNormal, GetInstanceProperty(_RimSize), GetInstanceProperty(_RimIntensity));
                        col = AlphaBlend(col,half4(GetInstanceProperty(_RimColor).rgb,GetInstanceProperty(_RimColor).a * saturate(rim)));
                        
                    #endif
                    return col;
                #endif
            }
            #include "ToonBase/ToonShaderLibrary.cginc"
            
            ENDCG
        }
        
        UsePass "ShaderFramework/Toon/ToonBase/OutlinePass"

        UsePass "ShaderFramework/Lighting/ShadowCaster/Shadow CasterPass"
    }
}
