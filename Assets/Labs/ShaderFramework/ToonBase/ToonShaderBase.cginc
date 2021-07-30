#ifndef TOON_SHADE
    #define TOON_SHADE
    struct appdata
    {
        float4 vertex : POSITION;
        float4 tangent : TANGENT;
        float3 normal : NORMAL;
        float4 uv : TEXCOORD0;
        float4 color : COLOR;
                   
    };

    struct v2f
    {
        float4 pos : SV_POSITION;				
        float4 color : COLOR;
        float2 uv : TEXCOORD0;
        float4 worldPos : TEXCOORD1;
        float3  worldNormal : TEXCOORD2;
        float3  worldLight : TEXCOORD3;
        float3  viewDir : TEXCOORD4;
    };

    float3 RampSample(sampler2D rampTex,half shade)
    {
        return tex2D(rampTex,float2(shade,0));
    }
#endif
