#ifndef TOON_SHADE
    #define TOON_SHADE
    #include "LightingBase/CustomLighting.cginc"


    float3 RampSample(sampler2D rampTex,half shade)
    {
        return tex2D(rampTex,float2(shade,0));
    }

    float3 RampSample(sampler2D rampTex,half shade,half offset)
    {
        return tex2D(rampTex,float2(shade + offset,0));
    }

    float HalfLambertToon(float3 lightDir,float3 normal,half size,half intensity)
    {
        float NdotL = GetLighting(lightDir,normal);
        float light = saturate(NdotL);
        light = pow(saturate(light - (1 - size)),1 -clamp(intensity,0.00001,0.99999));
        light = saturate(light);
        return light;
    }

#endif
