#ifndef TOON_LIGHT_MODEL
    #define TOON_LIGHT_MODEL

    #pragma vertex vert_CustomLighting
    #pragma fragment frag
    #include "ToonShaderProperties.cginc"
    #pragma multi_compile __ _GPU_INSTANCE



    /**********************************************/
    /**************     光照模型       *************/
    /**********************************************/

    //光照明暗
    float GET_LIGHT(v2f_CustomLighting i)
    {
        #ifdef CUSTOM_LIGHT_FUNC
            return CUSTOM_LIGHT_FUNC(i);
        #else
            #ifndef _GPU_INSTANCE
                //法线贴图   
                #ifdef _TOON_BUMP
                    half3 normal = NormalMap(i.worldNormal, _NormalMap, i.uv, _NormalIntensity);          
                #else
                    half3 normal = normalize(i.worldNormal);
                #endif
                
                #ifdef _TOON_SPECULAR
                    half specMap = tex2D(_SpecMap, i.uv);
                    float light = GetToonLight(i.worldLight, normal, i.viewDir,
                                               _LightSize, _LightIntensity,
                                               specMap, 1 / _SpecStrength, _SpecSmooth);
                #else
                    float light = GetToonLight(i.worldLight,normal,_LightSize,_LightIntensity);
                #endif
            #else
                //法线贴图   
                #ifdef _TOON_BUMP
                    half3 normal = NormalMap(i.worldNormal, _NormalMap, i.uv, GetInstanceProperty(_NormalIntensity));          
                #else
                    half3 normal = normalize(i.worldNormal);
                #endif
                #ifdef _TOON_SPECULAR
                    half specMap = tex2D(_SpecMap, i.uv);
                    float light = GetToonLight(i.worldLight, normal, i.viewDir,
                                               GetInstanceProperty(_LightSize), GetInstanceProperty(_LightIntensity),
                                               specMap, 1 / GetInstanceProperty(_SpecStrength), GetInstanceProperty(_SpecSmooth));
                #else
                    float light = GetToonLight(i.worldLight,normal,GetInstanceProperty(_LightSize),GetInstanceProperty(_LightIntensity));
                #endif
            #endif
            return light;
        #endif
    }
    //阴影
    ///light : 上文光照处理结果
    float GET_SHADE(v2f_CustomLighting i,float light)
    {
        #ifdef _TOON_SHADOW_RECEIVE
             #ifdef CUSTOM_SHADE_FUNC
                return CUSTOM_SHADE_FUNC(i,light);
             #else
                #ifndef _GPU_INSTANCE
                    return light - (1 - GetShadow(i)) * _ShadowReceivedIntensity;
                #else
                    return light * (GetShadow(i) + GetInstanceProperty(_LightIntensity));
                #endif
                
             #endif
        #else
            return light;
        #endif
    }

    //环境光
    float3 GET_AMBIENT(v2f_CustomLighting i)
    {
        #ifdef _TOON_AMBIENT
            #ifdef CUSTOM_AMBIENT_FUNC
                return CUSTOM_AMBIENT_FUNC(i);
            #else
                return (GetAmbientGradient(i.worldNormal) + GetReflectionProbe(i,.5)) * _AmbientStrength;
            #endif
        #else
            return float3(0,0,0);
        #endif
        
    }

    //其他效果
    float4 GET_EFFECT(v2f_CustomLighting i)
    {
        #ifdef _TOON_EFFECT
            #ifdef CUSTOM_EFFECT_FUNC
                return CUSTOM_EFFECT_FUNC(i);
            #else
                float4 col = float4(0,0,0,0);
                //各向异性
                #ifdef _TOON_ANISOTROPIC
                    half anisotropic = GetKajiyaKay(i, GetInstanceProperty(_TangentOffset), 1 / GetInstanceProperty(_SpecStrength));
                    anisotropic = Contrast(anisotropic, GetInstanceProperty(_AnisotropicPow), 8, GetInstanceProperty(_AnisotropicIntensity));
                    col = AlphaBlend(col,half4( GetInstanceProperty(_AnisotropicColor).rgb, GetInstanceProperty(_AnisotropicColor).a * anisotropic));
                #endif

                //边缘光
                #ifdef _TOON_RIM
                    col = AlphaBlend(col,half4(GetInstanceProperty(_RimColor).rgb,GetInstanceProperty(_RimColor).a * GetFresnel(i.viewDir, i.worldNormal, GetInstanceProperty(_RimSize), GetInstanceProperty(_RimIntensity))));
                    return col;
                #endif
            #endif  
        #else
            return float4(0,0,0,0);
        #endif
    }



    //完整模型
    float4 ToonLightModel(v2f_CustomLighting i)
    {
        half4 col = tex2D(_MainTex, i.uv);

        float light = GET_LIGHT(i);
        float shade = GET_SHADE(i,light);
        
        //颜色渐变
        #ifndef _GPU_INSTANCE
            half3 ramp = RampSample(_RampTex, shade, _RampOffset);
        #else
            half3 ramp = RampSample(_RampTex, shade, GetInstanceProperty(_RampOffset));
        #endif
        
        half3 ambient = GET_AMBIENT(i);
        ramp +=  ambient;

        col.rgb *= ramp;
        
        col.rgb = AlphaBlend(col,GET_EFFECT(i));

        return float4(col.rgb, 1);
    }

    /**********************************************/

    fixed4 frag(v2f_CustomLighting i) : SV_Target
    {
        #ifdef _GPU_INSTANCE
            UNITY_SETUP_INSTANCE_ID(i);
        #endif
        
        #ifdef CUSTOM_LIGHT_MODEL
            half4 col = CUSTOM_LIGHT_MODEL(i);
        #else
            half4 col = ToonLightModel(i);
            UNITY_APPLY_FOG(i.fogCoord, col);
        #endif
        
        #ifdef _GPU_INSTANCE
            return col;
        #else
            return col;
        #endif
        
    }

    

#endif