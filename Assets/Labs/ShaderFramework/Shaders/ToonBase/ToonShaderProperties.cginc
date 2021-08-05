#ifndef TOON_SHADER_PROPERTIES
    #define TOON_SHADER_PROPERTIES

    #ifndef _GPU_INSTANCE
        //Ramp
        sampler2D _RampTex;
        half _RampOffset;

        //Ambient
        #if defined(_TOON_AMBIENT)
            half _AmbientStrength;
        #endif

        //Light
        half _LightSize;
        half _LightIntensity;
        half _ShadowReceivedIntensity;

        #if defined(_TOON_SPECULAR)
            sampler2D _SpecMap;
            half _SpecStrength;
            half _SpecSmooth;
            half _Roughness;
        #endif

        #if defined(_TOON_ANISOTROPIC)
            half _AnisotropicPow;
            half _AnisotropicIntensity;
            half4 _AnisotropicColor;
            half _TangentOffset;
        #endif

        #if defined(_TOON_BUMP)
            sampler2D _NormalMap;
            half _NormalIntensity;
        #endif

        #if defined(_TOON_RIM)
            half4 _RimColor;
            half _RimIntensity;
            half _RimSize;
        #endif

    #else
        UNITY_INSTANCING_BUFFER_START(Props)
        // UNITY_DEFINE_INSTANCED_PROP(sampler2D, _RampTex)
        UNITY_DEFINE_INSTANCED_PROP(half,_RampOffset)
        
        #if defined(_TOON_AMBIENT)
            UNITY_DEFINE_INSTANCED_PROP(half,_AmbientStrength)
        #endif
        
        UNITY_DEFINE_INSTANCED_PROP(half,_LightSize)
        UNITY_DEFINE_INSTANCED_PROP(half,_LightIntensity)
        UNITY_DEFINE_INSTANCED_PROP(half,_ShadowReceivedIntensityy)
        
        #if defined(_TOON_SPECULAR)
            // UNITY_DEFINE_INSTANCED_PROP(sampler2D,_SpecMap)
            UNITY_DEFINE_INSTANCED_PROP(half,_SpecStrength)
            UNITY_DEFINE_INSTANCED_PROP(half,_SpecSmooth)
            UNITY_DEFINE_INSTANCED_PROP(half,_Roughness)
        #endif
        
        #if defined(_TOON_ANISOTROPIC)
            UNITY_DEFINE_INSTANCED_PROP(half,_AnisotropicPow)
            UNITY_DEFINE_INSTANCED_PROP(half,_AnisotropicIntensity)
            UNITY_DEFINE_INSTANCED_PROP(half4,_AnisotropicColor)
            UNITY_DEFINE_INSTANCED_PROP(half,_TangentOffset)
        #endif
        
        #if defined(_TOON_BUMP)
            // UNITY_DEFINE_INSTANCED_PROP(sampler2D,_NormalMap)
            UNITY_DEFINE_INSTANCED_PROP(half,_NormalIntensity)
        #endif
        
        #if defined(_TOON_RIM)
            UNITY_DEFINE_INSTANCED_PROP(half4,_RimColor)
            UNITY_DEFINE_INSTANCED_PROP(half,_RimIntensity)
            UNITY_DEFINE_INSTANCED_PROP(half,_RimSize)
        #endif

        #if defined(_TOON_RECEIVE_SHADOW)
            UNITY_DEFINE_INSTANCED_PROP(half,_ShadowReceivedIntensity)
        #endif
        UNITY_INSTANCING_BUFFER_END(Props)
            // //Ramp
            sampler2D _RampTex;
            // half _RampOffset;
            //
            // //Ambient
            // #if defined(_TOON_AMBIENT)
            //     half _AmbientStrength;
            // #endif
            //
            // //Light
            // half _LightSize;
            // half _LightIntensity;
            //
            // #if defined(_TOON_SPECULAR)
            sampler2D _SpecMap;
            //     half _SpecStrength;
            //     half _SpecSmooth;
            // #endif
            //
            // #if defined(_TOON_ANISOTROPIC)
            //     half _AnisotropicPow;
            //     half _AnisotropicIntensity;
            //     half4 _AnisotropicColor;
            //     half _TangentOffset;
            // #endif
            //
            // #if defined(_TOON_BUMP)
            sampler2D _NormalMap;
            //     half _NormalIntensity;
            // #endif
            //
            // #if defined(_TOON_RIM)
            //     half4 _RimColor;
            //     half _RimIntensity;
            //     half _RimSize;
            // #endif

        #define GetInstanceProperty(i) UNITY_ACCESS_INSTANCED_PROP(Props,i) 
        

    #endif

#endif
