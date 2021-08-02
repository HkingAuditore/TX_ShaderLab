Shader "Toon/ToonBase"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _RampOffset("Ramp Offset",Range(-1,1)) = 0
        
        [Normal]_NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", float) = 1
        
        _LightSize("Light Size",Range(0,1)) = .5
        _LightIntensity("Light Strength",Range(0,1)) = .5
        
        _SpecMap("Spec Map",2D) = "black" {}
        _SpecStrength("Spec Strength",Range(0,1)) = .5
        _SpecSmooth("Spec Smooth",Range(0,1)) = .5
        
        _AnisotropicColor("Anisotropic Color",Color) = (1,1,1,1)
        _AnisotropicNoise("Anisotropic Noise",2D) = "white" {}
        _AnisotropicNoiseVector("Anisotropic Pow",Vector) = (0,0,0,0)
        _AnisotropicPow("Anisotropic Pow",Range(0,1)) = .5
        _AnisotropicIntensity("Anisotropic Intensity",Range(0,1)) = 0
        
        _TangentOffset("Tangent Offset",float) = 0
        
        _AmbientStrength("Ambient Strength",Range(0,1)) = .5
        
        _OutLineNoise("OutLine Noise",2D) = "black" {}
        _OutLineColor("Outline Color",Color) = (1,1,1,1)
        _OutlineWidth("Outline Width",Range(0,5)) = .5
        
        [HDR]_RimColor("Rim Color",Color) = (1,1,1,1)
        _RimIntensity("Rim Intensity", Range(0, 1)) = 0
        _RimSize("Rim Size", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        

        Pass
        {
            CGPROGRAM
            
            #include "ToonBase/ToonShaderBase.cginc"
            #include "LightingBase/CustomLighting.cginc"
            #include "UnityCG.cginc"

            #pragma vertex vert_base
            #pragma fragment frag
            #pragma multi_compile_fog           

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



            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 bump = UnpackNormalWithScale(tex2D(_NormalMap,i.uv),_NormalIntensity);
                
                float light = HalfLambertToon(i.worldLight,i.worldNormal + bump,_LightSize,_LightIntensity);
                
                float spec = GetSpecular(i.worldLight,i.viewDir,i.worldNormal + bump,1 / _SpecStrength,_SpecSmooth);
                half specMap = tex2D(_SpecMap,i.uv);
                spec = saturate(spec + specMap);
                
                half anisotropicNoise = tex2D(_AnisotropicNoise,i.uv);
                half anisotropic = GetKajiyaKay(i,_TangentOffset,1/_SpecStrength);
                // half anisotropic = GetKajiyaKay(i,anisotropicNoise,_AnisotropicNoiseVector.x,_AnisotropicNoiseVector.y,_AnisotropicNoiseVector.z,_AnisotropicNoiseVector.w);
                anisotropic = pow(saturate(anisotropic + _AnisotropicPow),8) * _AnisotropicIntensity;
                
                float shade = light + spec;
                
                half3 ramp = RampSample(_RampTex,shade,_RampOffset);
                half3 ambient = GetAmbientGradient(i.worldNormal + bump);
                half rim = GetFresnel(i.viewDir,i.worldNormal,_RimSize,_RimIntensity);
                
                
                
                
                float3 r = (ramp + ambient * _AmbientStrength) * col.rgb;
                r = r * (1 - rim) + _RimColor.rgb * rim;
                r = r * (1 - anisotropic) + _AnisotropicColor.rgb * anisotropic;
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(r,1);
            }
            ENDCG
        }
        
        Pass{
            Tags {"LightMode"="ForwardBase"}
            Cull Front
            CGPROGRAM
            #include "ToonBase/Outline.cginc"
            ENDCG
        }

    }
}
