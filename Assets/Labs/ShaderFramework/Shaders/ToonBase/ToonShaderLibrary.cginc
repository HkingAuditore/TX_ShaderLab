#ifndef TOON_SHADE
    #define TOON_SHADE

    #include "../CustomBase.cginc"
    #include "../LightingBase/CustomLighting.cginc"
    #include "UnityCG.cginc"
    /**********************************************/
    /**************        描边        *************/
    /**********************************************/
    half _OutlineWidth;
    half4 _OutLineColor;
    struct a2v_outline
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
        float4 color : COLOR;
        float4 tangent : TANGENT;
    };
    struct v2f_outline
    {
        float4 pos : SV_POSITION;
        float4 color : COLOR;
        float2 uv : TEXCOORD0;
        float4 worldPos : TEXCOORD1;
        float3 worldNormal : TEXCOORD2;
        float3 viewDir : TEXCOORD3;
        float3 bitangent : TEXCOORD4;
    };
    /**********************************************/

    /**********************************************/
    /**************        Ramp        *************/
    /**********************************************/
    float3 RampSample(sampler2D rampTex, half shade)
    {
        return tex2D(rampTex, float2(shade, 0));
    }

    float3 RampSample(sampler2D rampTex, half shade, half offset)
    {
        return tex2D(rampTex, float2(shade + offset, 0));
    }

    /**********************************************/



    /**********************************************/


    /**********************************************/
    /**************        光照        *************/
    /**********************************************/
    float HalfLambertToon(float3 lightDir, float3 normal, half size, half intensity)
    {
        float NdotL = GetLighting(lightDir, normal);
        float light = saturate(NdotL);
        light = pow(saturate(light - (1 - size)), 1 - clamp(intensity, 0.00001, 0.99999));
        light = saturate(light);
        return light;
    }

    //无高光
    float GetToonLight(float3 normal, float3 lightDir, half lightSize, half lightIntensity)
    {
        return HalfLambertToon(lightDir, normal, lightSize, lightIntensity);
    }

    //有高光
    float GetToonLight(float3 normal, float3 lightDir, float3 viewDir, half lightSize, half lightIntensity, half specNoise,
                       half specStrength, half specSmooth)
    {
        float light = HalfLambertToon(lightDir, normal, lightSize, lightIntensity);
        light += GetNoisySpec(normal, lightDir, viewDir, specNoise, specStrength, specSmooth);
        return light;
    }

    /**********************************************/


#if defined(_TOON_USE_STANDARD)
    #include "ToonLightModel.cginc"
#endif


#endif
