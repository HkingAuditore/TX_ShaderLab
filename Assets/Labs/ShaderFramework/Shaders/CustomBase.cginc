#ifndef CUSTOM_BASE
    #define CUSTOM_BASE
    #include "UnityCG.cginc"
    #ifdef _GPU_INSTANCE
        #pragma multi_compile_instancing
    #endif

    //对比度
    float Contrast(float value,float offset,float power)
    {
        return pow(saturate(value + offset),power);
    }

    //混合
    float3 Blend(float3 ori,float3 target,float blendValue)
    {
        return ori * (1 - blendValue) + target * blendValue;
    }

    //透明度混合
    float4 AlphaBlend(float4 ori,float4 target)
    {
        return ori * (1 - target.a) + target * target.a;
    }



#endif
