Shader "Unlit/Explosion"
{
    Properties
    {
        [HDR]_Color0("Color 0",Color) = (1,1,1,1)
        [HDR]_Color1("Color 1",Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _FresnelIntensity("Fresnel Intensity", Range(0.01, 3)) = 0.5
        _Cutoff("_Cutoff", Range(0, 1)) = 0.5
        _BurnTex("Burn Tex",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "AlphaTest"
            "Queue" = "AlphaTest+1"
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

            fixed4 _Color0;
            fixed4 _Color1;
            sampler2D _BurnTex;
            sampler2D _RampTex;
            float4 _BurnTex_ST;

            half _FresnelIntensity;
            half _Cutoff;

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
                half burn = tex2D(_BurnTex,i.uv);
                float3 N = normalize(i.worldNormal);
                fixed NdotV = dot(N,i.viewDir);
                
                fixed fresnel =  1 - saturate(NdotV);
                fresnel = pow(fresnel,_FresnelIntensity);
                fresnel *= (1+burn*.5);
                fresnel = clamp(fresnel,0.01,0.99);
                fixed4 col =tex2D(_RampTex,fixed2(fresnel,0));
                col *= i.color;

                
                clip(fresnel - _Cutoff);
                return fixed4(col.rgb,col.a);
            }
            ENDCG
        }
    }
}