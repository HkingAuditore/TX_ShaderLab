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

        [HDR]_FresnelColor("Fresnel Color",Color) = (1,1,1,1)
        _FresnelIntensity("Fresnel Intensity", Range(0.01, 3)) = 0.5
        _FresnelSize("Fresnel Size", Range(0.01, 1)) = 0.5
        
        _FlowMap("Flow Map", 2D) = "white" {}
        _UJump ("U jump per phase", Range(-0.25, 0.25)) = 0.25
		_VJump ("V jump per phase", Range(-0.25, 0.25)) = 0.25
        
        _Cutoff("_Cutoff", Range(0, 1)) = 0.5
        _Rotation("Rotation", float) = 0
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

            //shader feature
            #pragma shader_feature USE_TRANSITION
            #pragma shader_feature USE_FRESNEL
            #pragma shader_feature USE_FRESNEL
            #pragma shader_feature USE_OFFSET
            #pragma shader_feature USE_FLOWMAP
            
            #include "UnityCG.cginc"
      
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

            sampler2D _Tex0;
            sampler2D _Tex0Ramp;
            float4 _Color0;
            sampler2D _Tex1;
            sampler2D _Tex1Ramp;
            float4 _Color1;

            sampler2D _FlowMap;
            float4 _FlowMap_ST;
            half _UJump;
            half _VJump;
            
            sampler2D _BurnTex;
            float4 _BurnTex_ST;

            float4 _FresnelColor;
            half _FresnelIntensity;
            half  _FresnelSize;
            
            half  _RotateSpeed;
            half _Cutoff;
            
            half _Transition;
            float _Rotation;
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

            float2 rotateUV(float2 uv, float rotation)
            {
                float mid = .5f;
                return float2(
                    cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
                    cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
                );
            }

            float clampNoise(float v)
            {
                return clamp(0.01,0.99,v);
            }
            
            float3 FlowUVW (
	            float2 uv, float2 flowVector, float2 jump,
	            float flowOffset, float tiling, float time, bool flowB
            ) {
	            float phaseOffset = flowB ? 0.5 : 0;
	            float progress = frac(time + phaseOffset);
	            float3 uvw;
	            uvw.xy = uv - flowVector * (progress + flowOffset);
	            uvw.xy *= tiling;
	            uvw.xy += phaseOffset;
	            uvw.xy += (time - progress) * jump;
	            uvw.z = 1 - abs(1 - 2 * progress);
	            return uvw;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                #if USE_FLOWMAP
                float2 flow = tex2D(_FlowMap, i.uv).rg;
                float2 jump = float2(_UJump, _VJump);
                float3 uvw0  = FlowUVW(
				    i.uv, flow.xy, jump,
				    _FlowMap_ST.zw, _FlowMap_ST.xy, _Time.y, false
			    );
                float3 uvw1  = FlowUVW(
				    i.uv, flow.xy, jump,
				    _FlowMap_ST.zw, _FlowMap_ST.xy, _Time.y, true
			    );
                #endif
                
                // float2 uv = rotateUV(i.uv,_Time.y * _RotateSpeed + _Rotation);
                float2 uv = i.uv + float2(_Time.y * _RotateSpeed + _Rotation,0);
                float3 N = normalize(i.worldNormal);
                half NdotV = dot(N,i.viewDir);
                half NdotL = dot(N,i.worldLight);

                //Fresnel
                #if USE_FRESNEL
                float fresnel = 1-saturate(NdotV);
                fresnel = pow(fresnel/_FresnelSize,_FresnelIntensity);
                fresnel = saturate(fresnel);
                float4 fresnelColor = float4(_FresnelColor.rgb,fresnel);
                #endif


                
                //Style 0
                float s0 = clampNoise(tex2D(_Tex0,uv));
                float4 c0 = tex2D(_Tex0Ramp,float2(s0,0));
                c0 *= _Color0;
                
                //Style 1
                #if USE_TRANSITION
                float s1 = clampNoise(tex2D(_Tex1,uv));
                float4 c1 = tex2D(_Tex1Ramp,float2(s1,0));
                c1 *= _Color1;
                fixed transition = tex2D(_TransitionTex,uv);
                transition = 1 - saturate((transition - (_Transition-0.5) * 2));
                #endif
                

                //Burn
                half burn =tex2D(_BurnTex,uv);
                


                
                fixed4 col = c0;
                
                #if USE_TRANSITION
                col = lerp(c0,c1,transition);
                #endif

                #if USE_FRESNEL
                col.rgb = col.rgb * (1 - fresnelColor.a) + fresnelColor.rgb * fresnelColor.a;
                #endif

                float alpha =  saturate(pow(saturate(1 + (burn - _Cutoff * .25 - _Cutoff)),10));
                alpha *= col.a;
                return fixed4(col.rgb,alpha);
            }
            ENDCG
        }
    }
    CustomEditor "ExplosionSphereShaderGUI"
}
