Shader "ShaderFramework/Toon/ToonBase"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutLineNoise("OutLine Noise",2D) = "black" {}
        _OutLineColor("Outline Color",Color) = (1,1,1,1)
        _OutlineWidth("Outline Width",Range(0,5)) = .5

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100
        
        Pass
        {
            Name "ToonPass"
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            
            #include "../ToonBase/ToonShaderLibrary.cginc"
            #include "../LightingBase/CustomLighting.cginc"
            #include "UnityCG.cginc"

            #pragma vertex vert_CustomLighting
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _TOON_BUMP
            #pragma multi_compile _TOON_SPECULAR 
            #pragma multi_compile _TOON_ANISOTROPIC 
            #pragma multi_compile _TOON_RIM 

            sampler2D _RampTex;

            sampler2D _SpecMap;
            half _SpecStrength;
            half _SpecSmooth;

            sampler2D _AnisotropicNoise;
            half _AnisotropicPow;
            half _AnisotropicIntensity;
            half4 _AnisotropicNoiseVector;
            half _TangentOffset;

            half3 _AnisotropicColor;
            half _AmbientStrength;
            
            half _RampOffset;
            half4 _OutLineColor;

            sampler2D _NormalMap;
            half _NormalIntensity;

            half _LightSize;
            half _LightIntensity;

            half4 _RimColor;
            half _RimIntensity;
            half _RimSize;


            fixed4 frag (v2f_CustomLighting i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                half3 normal = i.worldNormal;
                
                #if defined(_TOON_BUMP)
                float3 bump = UnpackNormalWithScale(tex2D(_NormalMap,i.uv),_NormalIntensity);
                normal += bump;
                #endif
                
                float light = HalfLambertToon(i.worldLight,normal,_LightSize,_LightIntensity);

                #if defined(_TOON_SPECULAR)
                float spec = GetSpecular(i.worldLight,i.viewDir,normal,1 / _SpecStrength,_SpecSmooth);
                half specMap = tex2D(_SpecMap,i.uv);
                spec = saturate(spec + specMap);
                light += spec;
                #endif            
                
                float shade = light * (GetShadow(i) + _LightIntensity);
                half3 ramp = RampSample(_RampTex,shade,_RampOffset);
                half3 ambient = GetAmbientGradient(normal);
                
                col.rgb *= (ramp + ambient * _AmbientStrength);

                #if defined(_TOON_ANISOTROPIC)
                half anisotropicNoise = tex2D(_AnisotropicNoise,i.uv);
                half anisotropic = GetKajiyaKay(i,_TangentOffset,1/_SpecStrength);
                anisotropic = pow(saturate(anisotropic + _AnisotropicPow),8) * _AnisotropicIntensity;
                col.rgb = col.rgb * (1 - anisotropic) + _AnisotropicColor.rgb * anisotropic;
                #endif

                #if defined(_TOON_RIM)
                half rim = GetFresnel(i.viewDir,i.worldNormal,_RimSize,_RimIntensity);
                col.rgb = col.rgb * (1 - rim) + _RimColor.rgb * rim;
                #endif
               
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(col.rgb,1);
            }
            ENDCG
        }


        Pass
        {
            Name "OutLinePass"
            Tags
            {
                "LightMode"="ForwardBase"
            }
            Cull Front
            ZWrite Off
            ZTest LEqual
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _OutLineNoise;
            float4 _MainTex_ST;
            half _OutlineWidth;
            half4 _OutLineColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 vertColor : COLOR;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };


            v2f vert(a2v v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 pos = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
                float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;
                float4 nearUpperRight = mul(unity_CameraInvProjection,
                float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
                //将近裁剪面右上角位置的顶点变换到观察空间
                float aspect = abs(nearUpperRight.y / nearUpperRight.x);
                ndcNormal.x *= aspect;
                half noise = tex2Dlod(_OutLineNoise, float4(o.uv, 0, 0)).r;
                pos.xy += 0.01 * (_OutlineWidth * (1 + noise * .5)) * ndcNormal.xy;
                o.pos = pos;
                o.color = v.vertColor;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                half4 col = tex2D(_MainTex, i.uv);
                return col * _OutLineColor;
            }
            ENDCG
        }
    }
}