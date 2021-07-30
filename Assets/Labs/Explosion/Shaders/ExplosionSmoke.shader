Shader "Explosion/ExplosionSmoke"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _RampPower("Ramp Power", Range(1, 30)) = 0
        _RampOffset("Ramp Offset", Range(-1, 1)) = 0
        _RampSize("Ramp Size", Range(0, 1)) = .5
        
        _FresnelThreshold("Fresnel Threshold", Range(0.01, 1)) = 0.5
        _FresnelIntensity("Fresnel Intensity", Range(0, 1)) = .5
        
        _LightIntensity("Light Intensity", Range(0.01, 1)) = .5

        [Normal]_SmokeNormal ("Smoke Normal Map", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", float) = 1
        
        _Cutoff("Cut off", Range(0, 1)) = 0.5
        _BurnTex("Burn Tex",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "AlphaTest"
            "Queue" = "AlphaTest"
        }
        LOD 100
        Lighting On
        Blend SrcAlpha OneMinusSrcAlpha
        Pass{
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

             //shader feature=
            #pragma shader_feature USE_LIGHTING


            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                fixed4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID

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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            
            sampler2D _RampTex;
            half _RampSize;
            half _RampOffset;
            half _RampPower;
            
            half _FresnelThreshold;
            half _FresnelIntensity;
            
            half _LightIntensity;
            
            sampler2D _BurnTex;
            float4 _BurnTex_ST;
            half _Cutoff;
            
            sampler2D _SmokeNormal;
            half _NormalIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
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
                UNITY_SETUP_INSTANCE_ID(i);
                float3 normal = UnpackNormalWithScale(tex2D(_SmokeNormal,i.uv),_NormalIntensity);
                float3 N = normalize(i.worldNormal);
                half NdotV = dot(N,i.viewDir);
                half NdotL = dot(N+normal,i.worldLight);

                //菲涅尔
                float shade =  1 - saturate(NdotV);
                shade = pow(1+(shade-_FresnelThreshold),_FresnelIntensity);
                shade = saturate(shade-_FresnelThreshold);

                //光照
                #if USE_LIGHTING
                half light = ((NdotL*.5)+.5);
                shade -= _LightIntensity * light;
                #endif

                //重散布
                shade = saturate(shade + _RampSize);
                shade = saturate(pow(shade,_RampPower));
                shade = saturate(shade + _RampOffset);
                
                float4 col =tex2D(_RampTex,fixed2(shade,0));

                //溶解与边缘模糊
                half burn = tex2D(_BurnTex,i.uv);
                half alpha =  saturate(pow(saturate(1 + (burn - _Cutoff * .25 - _Cutoff)),10)) ;
               
                col *= i.color;
                clip(burn - _Cutoff*1.01);
                return UNITY_ACCESS_INSTANCED_PROP(Props,  fixed4(col.rgb,alpha*i.color.a));
            }
            ENDCG
        }
        
    }
    CustomEditor "ExplosionSmokeShaderGUI"
}