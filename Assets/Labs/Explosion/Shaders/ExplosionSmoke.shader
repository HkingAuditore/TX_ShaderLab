Shader "Explosion/ExplosionSmoke"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _RampPower("Ramp Power", Range(1, 10)) = 0
        _RampOffset("Ramp Offset", Range(-1, 1)) = 0
        _Noise("Noise Texture", 2D) = "white" {}
        
        _FresnelThreshold("Fresnel Threshold", Range(0.01, 1)) = 0.5
        _RampSize("Ramp Size", Range(0, 1)) = .5
        _FresnelIntensity("Fresnel Intensity", Range(0, 1)) = .5
        _LightIntensity("Light Intensity", Range(0.01, 1)) = .5
        
        
        
        _SmokeNormal ("Smoke Normal Map", 2D) = "bump" {}
        _SmokeIntensity("Smoke Intensity", Range(0, 1)) = 0.5
        
        
        _Cutoff("_Cutoff", Range(0, 1)) = 0.5
        _BurnTex("Burn Tex",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+1"
        }
        LOD 100
        Lighting On
        Blend SrcAlpha OneMinusSrcAlpha
        Pass{
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                fixed4 color : COLOR;
               
            };

            struct v2f
            {
	            float4 pos : SV_POSITION;				
	            fixed4 color : COLOR;
	            float2 uv : TEXCOORD0;
	            float4 worldPos : TEXCOORD1;
	            float3  worldNormal : TEXCOORD2;
	            float3  worldLight : TEXCOORD3;
                float3  viewDir : TEXCOORD4;
            };

            sampler2D _BurnTex;
            sampler2D _Noise;
            sampler2D _RampTex;
            sampler2D _SmokeNormal;
            float4 _BurnTex_ST;

            half _RampOffset;
            half _RampPower;
            half _FresnelThreshold;
            half _FresnelIntensity;
            half _LightIntensity;
            half _RampSize;
            half _Cutoff;
            half _SmokeIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BurnTex);
                o.color = v.color;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal = UnpackNormalWithScale(tex2D(_SmokeNormal,i.uv),1);
                fixed3 noise = tex2D(_Noise,i.uv);

                half burn = tex2D(_BurnTex,i.uv).g;
                float3 N = normalize(i.worldNormal);
                fixed NdotV = dot(N,i.viewDir);
                fixed NdotL = dot(N+normal,i.worldLight);
                
                float fresnel =  1 - saturate(NdotV);
                fresnel = pow(1+(fresnel-_FresnelThreshold),_FresnelIntensity);
                fresnel = saturate(fresnel-_FresnelThreshold);
                // fresnel = fresnel*.5+.5;
                fresnel = lerp(fresnel,1-((NdotL*.5)+.5)*_LightIntensity,.5);
                // fresnel *= (1-((NdotL*.5)+.5))*_LightIntensity;
                fresnel = saturate((fresnel - (_RampSize- .5) * 2));
                fresnel *= noise.g;
                fresnel = saturate(pow(fresnel,_RampPower));
                fresnel = saturate(fresnel + _RampOffset);
                
                fixed4 col =tex2D(_RampTex,fixed2(fresnel,0));

                fixed alpha =  saturate(pow(1 + (burn - _Cutoff * .25 - _Cutoff),10)) * i.color.a;
                
                // col.rgb *= i.color;
                col *= i.color;
                
                
                clip(burn - _Cutoff*1.01);
                // return fixed4(shadow,shadow,shadow,1);
                return fixed4(col.rgb,alpha);
            }
            ENDCG
        }
        
    }
}