Shader "Explosion/Sphere/FlameSphere"
{
    Properties
    {
        _BaseTex ("Base Tex ", 2D) = "white" {}
        _RampTex ("Ramp Tex ", 2D) = "white" {}
        
        _FlameTex0 ("Flame Tex 0 ", 2D) = "white" {}
        _FlameTex0Speed ("Flame Tex 0 Speed",Range(-10, 10)) = 5
        
        _FlameTex1 ("Flame Tex 1 ", 2D) = "white" {}
        _FlameTex1Speed ("Flame Tex 1 Speed",Range(-10, 10)) = 5

        _FlameTex2 ("Flame Tex 2 ", 2D) = "white" {}
        _FlameTex2Speed ("Flame Tex 2 Speed",Range(-10, 10)) = 5

        _FlameTex3 ("Flame Tex 3 ", 2D) = "white" {}
        _FlameTex3Speed ("Flame Tex 3 Speed",Range(-10, 10)) = 5

        _FlameTex4 ("Flame Tex 4 ", 2D) = "white" {}
        _FlameTex4Speed ("Flame Tex 4 Speed",Range(-10, 10)) = 5

        
        _Cutoff("_Cutoff", Range(0, 1)) = 0.5
        _RotateSpeed("_Rotate Speed", Range(-10, 10)) = 5
        _BurnTex("Burn Tex",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        Cull off
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

            sampler2D _BaseTex;
            float4 _BaseTex_ST;
            
            sampler2D _FlameTex0;
            sampler2D _FlameTex1;
            sampler2D _FlameTex2;
            sampler2D _FlameTex3;
            sampler2D _FlameTex4;
            
            sampler2D _RampTex;

            float4 _FlameTex0_ST;
            float4 _FlameTex1_ST;
            float4 _FlameTex2_ST;
            float4 _FlameTex3_ST;
            float4 _FlameTex4_ST;


            half _FlameTex0Speed;
            half _FlameTex1Speed;
            half _FlameTex2Speed;
            half _FlameTex3Speed;
            half _FlameTex4Speed;
            
            half  _RotateSpeed;
            half _Cutoff;
            
            

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                o.color = v.color;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed2 rotateUV(fixed2 uv, float rotation)
            {
                float mid = 0.5;
                return fixed2(
                    cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
                    cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
                );
            }

            fixed2 centralizeUV(fixed2 uv, float dist)
            {
                fixed2 center = fixed2(.5,.5);
                fixed2 dir = normalize(uv - center);
                fixed newDist = min(dist,distance(uv,center));
                return uv + frac(dir * newDist);
            }
            
            fixed2 transformUpUV(fixed2 uv, float dist)
            {
                return uv - fixed2(0,dist);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 uv = rotateUV(i.uv,_RotateSpeed * _Time.y);
                float3 N = normalize(i.worldNormal);
                fixed NdotV = dot(N,i.viewDir);
                fixed NdotL = dot(N,i.worldLight);

                

                fixed2 flame0uv = transformUpUV(i.uv * _FlameTex0_ST.xy + _FlameTex0_ST.zw,_FlameTex0Speed * _Time.y);
                fixed flame0 = tex2D(_FlameTex0,flame0uv);
                fixed2 flame1uv = transformUpUV(i.uv * _FlameTex1_ST.xy + _FlameTex1_ST.zw,_FlameTex1Speed* _Time.y);
                fixed flame1 = tex2D(_FlameTex1,flame1uv);
                fixed2 flame2uv = transformUpUV(i.uv * _FlameTex2_ST.xy + _FlameTex2_ST.zw,_FlameTex2Speed* _Time.y);
                fixed flame2 = tex2D(_FlameTex2,flame2uv);
                fixed2 flame3uv = transformUpUV(i.uv * _FlameTex3_ST.xy + _FlameTex3_ST.zw,_FlameTex3Speed* _Time.y);
                fixed flame3 = tex2D(_FlameTex3,flame3uv);
                fixed2 flame4uv = transformUpUV(i.uv * _FlameTex4_ST.xy + _FlameTex4_ST.zw,_FlameTex4Speed* _Time.y);
                fixed flame4 = tex2D(_FlameTex4,flame4uv);

                fixed flame = tex2D(_BaseTex,uv);
                flame *= flame0 * flame1 * flame2 * flame3 * flame4;
    
                flame = clamp(flame,0.1,0.99);

                fixed4 fireCol = tex2D(_RampTex,fixed2(1-flame,0));
                
                clip(flame - _Cutoff);
                // fixed4 col = lerp(c0,c1,transition);
                return fireCol;
            }
            ENDCG
        }
    }
}
