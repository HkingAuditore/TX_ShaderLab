Shader "Explosion/Explosion"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _FresnelIntensity("Fresnel Intensity", Range(0.01, 3)) = 0.5
        
        _SmokeTex ("Smoke Ramp Texture", 2D) = "white" {}
        _SmokeNormal ("Smoke Normal Map", 2D) = "bump" {}
        _SmokeIntensity("Smoke Intensity", Range(0, 1)) = 0.5
        _SmokeTransTex("Smoke Trans Tex",2D) = "white" {}
        
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
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
            sampler2D _RampTex;
            sampler2D _SmokeTex;
            sampler2D _SmokeNormal;
            sampler2D _SmokeTransTex;
            float4 _BurnTex_ST;

            half _FresnelIntensity;
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

                half burn = tex2D(_BurnTex,i.uv);
                float3 N = normalize(i.worldNormal);
                fixed NdotV = dot(N,i.viewDir);
                fixed NdotL = dot(N+normal,i.worldLight);
                
                fixed fresnel =  1 - saturate(NdotV);
                fresnel = pow(fresnel,_FresnelIntensity);
                fresnel *= (1+burn*.5);
                fresnel = clamp(fresnel,0.05,0.95);
                fixed4 col =tex2D(_RampTex,fixed2(fresnel,0));

                fixed4 smokeCol =tex2D(_SmokeTex,fixed2(( .5 * NdotL + .5),0));
                
                fixed transition = tex2D(_SmokeTransTex,i.uv);
                transition = saturate((transition - (_SmokeIntensity-0.5) * 2));
                fixed alpha =  saturate(pow(1 + (burn - _Cutoff * .25 - _Cutoff),10));
                
                col.rgb= lerp(col.rgb,smokeCol.rgb,transition);
                col *= i.color;
                
                
                clip(burn - _Cutoff*1.01);
                // return fixed4(smokeValue,smokeValue,smokeValue,1);
                return fixed4(col.rgb,alpha);
            }
            ENDCG
        }
    }
}