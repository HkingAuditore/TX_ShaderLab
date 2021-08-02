#ifndef CUSTOM_LIGHTING
    #define CUSTOM_LIGHTING
    #include "UnityCG.cginc"
    sampler2D _MainTex;
    float4 _MainTex_ST;

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
        float3  tangent : TEXCOORD5;
        float3  bitangent : TEXCOORD6;
    };

    v2f vert_base(appdata v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);

        o.color = v.color;
        o.worldPos = mul(unity_ObjectToWorld,v.vertex);
        o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
        o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.tangent = mul(unity_ObjectToWorld, v.tangent);
        o.bitangent = mul(unity_ObjectToWorld, cross(v.normal, v.tangent));;
        UNITY_TRANSFER_FOG(o, o.vertex);
        return o;
    }

    float GetLighting(float3 lightDir,float3 normal)
    {
        float3 N = normalize(normal);
        float NdotL = dot(N,lightDir);
        return NdotL;
    }


    float HalfLambert(float3 lightDir,float3 normal)
    {
        float NdotL = GetLighting(lightDir,normal);
        return .5 * NdotL + .5;
    }


    float GetSpecular(float3 lightDir,float3 viewDir,float3 normal,float specularStrength,float specularSmooth)
    {
        float3 N = normalize(normal);
        float3 L = normalize(lightDir);
        float3 V = normalize(viewDir);
        float3 H = normalize(L + V);
        float3 R = normalize(2 * dot(N,L) * N - L);
        float3 re = reflect(-lightDir,N);
        half NdotH = saturate(dot(N,H));
        float spec = pow(NdotH,specularStrength);
        // return spec;
        spec = smoothstep(.5,.5+specularSmooth,spec);
        // float spec = pow(max(dot(viewDir,re),0.0),32);
        return spec;
    }

    float3 GetAmbientGradient(float3 normal)
    {
        float up = saturate(normal.y);
        float middle = 1-abs(normal.y);
        float down = saturate(-normal.y);

        return unity_AmbientSky * up + unity_AmbientEquator * middle + unity_AmbientGround * down;
    }

    half GetFresnel(float3 viewDir,float3 normal,half fresnelSize,half fresnelIntensity)
    {
        float3 N = normalize(normal);
        half NdotV = dot(N,viewDir);
        float fresnel = 1-saturate(NdotV);
        fresnel = pow(saturate(fresnel - (1 - fresnelSize)),1 -clamp(fresnelIntensity,0.00001,0.99999));
        fresnel = saturate(fresnel);
        return fresnel;
    }

    float StrandSpecular(float3 B,float3 V,float3 L,float exponent)
    {
        float3 H = normalize(L+V);
        float TdotH = dot(B,H);
        float TsinH = sqrt(1.0-TdotH*TdotH);
        float dirAtten = smoothstep(-1,0,dot(B,H));
        return dirAtten*pow(TsinH,exponent);
    }

    half GetKajiyaKay(v2f i,half offset,half gloss)
    {
        half3 L = normalize(i.worldLight);
        half3 N = normalize(i.worldNormal);
        half3 B = normalize(i.bitangent);
        half3 V = normalize(i.viewDir);
        half3 H = normalize(L+V);
        half Lambert = max(0,dot(N,L)*0.5+0.5);
        half3 lerpNormal = normalize(lerp(N + B, B, offset));

        return StrandSpecular(lerpNormal ,V,L,gloss);

    }

    half GetKajiyaKay(v2f i,half noise,half s0,half s1,half gloss0,half gloss1)
    {
        half3 L = normalize(i.worldLight);
        half3 N = normalize(i.worldNormal);
        half3 B = normalize(i.bitangent);
        half3 V = normalize(i.viewDir);
        half3 H = normalize(L+V);

        half shift1 = noise - s0;
        half shift2 = noise - s1;
        half3 B1 = normalize(B + shift1 * N);//利用噪声图来控制偏移
        half3 B2 = normalize(B + shift2 * N);
        half spec1 = StrandSpecular(B1,V,L,gloss0);
        half spec2 = StrandSpecular(B2,V,L,gloss1);
        
        return spec1+spec2;
    }

#endif
