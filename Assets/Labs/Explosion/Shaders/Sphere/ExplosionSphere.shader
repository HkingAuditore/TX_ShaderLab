Shader "Explosion/Sphere/ExplosionSphere"
{
    Properties
    {
        _Tex0 ("Tex 0", 2D) = "white" {}
        _Tex0Ramp ("Tex 0 Ramp", 2D) = "white" {}
        [HDR]_Color0("Color 0",Color) = (1,1,1,1)
        _Tex1 ("Tex 1", 2D) = "white" {}
        _Tex1Ramp ("Tex 1 Ramp", 2D) = "white" {}
        [HDR]_Color1("Color 1",Color) = (1,1,1,1)
        
        _Transition("Transition", Range(0, 1)) = 0.5
        _TransitionTex("TransitionTex", 2D) = "white" {}

        
        _FresnelIntensity("Fresnel Intensity", Range(0.01, 3)) = 0.5
        _FresnelSize("Fresnel Size", Range(0.01, 1)) = 0.5
        
        _Cutoff("_Cutoff", Range(0, 1)) = 0.5
        _RotateSpeed("_Rotate Speed", Range(-10, 10)) = 5
        _BurnTex("Burn Tex",2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+1"
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

            sampler2D _Tex0;
            sampler2D _Tex0Ramp;
            fixed4 _Color0;
            sampler2D _Tex1;
            sampler2D _Tex1Ramp;
            fixed4 _Color1;

            
            sampler2D _BurnTex;
            float4 _BurnTex_ST;

            half _FresnelIntensity;
            half  _FresnelSize;
            half  _RotateSpeed;
            half _Cutoff;
            
            half _Transition;
            sampler2D _TransitionTex;
            
            

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

            fixed2 rotateUV(fixed2 uv, float rotation)
            {
                float mid = 0.5;
                return fixed2(
                    cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
                    cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
                );
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 uv = rotateUV(i.uv,_RotateSpeed * _Time.y);
                float3 N = normalize(i.worldNormal);
                fixed NdotV = dot(N,i.viewDir);
                fixed NdotL = dot(N,i.worldLight);

                fixed transition = tex2D(_TransitionTex,uv);
                transition = saturate((transition - (_Transition-0.5) * 2));
                
                //Style 0
                fixed s0 = tex2D(_Tex0,uv);
                fixed4 c0 = tex2D(_Tex0Ramp,fixed2(s0,0));
                c0 *= _Color0;
                
                //Style 1
                fixed s1 = tex2D(_Tex1,uv);
                fixed4 c1 = tex2D(_Tex1Ramp,fixed2(s1,0));
                c1 *= _Color1;

                //Burn
                half burn = tex2D(_BurnTex,uv);

                //Fresnel
                fixed fresnel = 1-saturate(NdotV);
                fresnel = pow(fresnel/_FresnelSize,_FresnelIntensity);


                
                clip(burn - _Cutoff);
                fixed4 col = lerp(c0,c1,transition);
                // return fixed4(smokeValue,smokeValue,smokeValue,1);
                // return fixed4(transition,transition,transition,1);
                return fixed4(col.rgba);
            }
            ENDCG
        }
    }
}
