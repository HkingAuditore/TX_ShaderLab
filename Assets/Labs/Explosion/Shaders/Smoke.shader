Shader "Unlit/Smoke"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpIntensity("NormalMap Intensity", Range(-1, 1)) = 0
        _DistortTex ("Distort Texture", 2D) = "white" {}
        _DistortStrengthTex ("Distort Strength Texture", 2D) = "white" {}
        _DistortSpeedTex ("Distort Speed Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent+1"
            "CanUseSpriteAtlas" = "True"
            "IgnoreProjector" = "True"
        }
        LOD 100
        Lighting On
        ZWrite Off
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
	            half3  worldNormal : TEXCOORD2;
	            half3  worldLight : TEXCOORD3;
                half3  viewDir : TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            sampler2D _DistortTex;
            sampler2D _DistortStrengthTex;
            sampler2D _DistortSpeedTex;
            float4 _MainTex_ST;

            half _BumpIntensity;
            half _DistortSpeed;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                o.worldLight = normalize(UnityWorldSpaceLightDir(o.pos));
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.pos));
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float3 FlowUVW (float2 uv, float2 flowVector, float time, bool flowB) {
	            float phaseOffset = flowB ? 0.5 : 0;
	            float progress = frac(time + phaseOffset);
	            float3 uvw;
	            uvw.xy = uv - flowVector * progress;
	            uvw.z = 1 - abs(1 - 2 * progress);
	            return uvw;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //Distort
                fixed3 distort = tex2D(_DistortTex,i.uv);
                distort = distort*.35;
                fixed distortStrength = tex2D(_DistortStrengthTex,i.uv);
                fixed distortSpeed = tex2D(_DistortSpeedTex,i.uv);
                fixed2 distortVec = fixed2(distort.r, distort.g) * distortStrength ;
                float time = _Time.y * .5 + distortSpeed ;

				float3 uvwA = FlowUVW(i.uv, distortVec, time, false);
				float3 uvwB = FlowUVW(i.uv, distortVec, time, true);

				fixed4 tex = tex2D(_MainTex, i.uv);
				fixed4 texA = tex2D(_MainTex, uvwA.xy) * uvwA.z;
				fixed4 texB = tex2D(_MainTex, uvwB.xy) * uvwB.z;

                fixed3 normalA = UnpackNormalWithScale(tex2D(_BumpMap,uvwA.xy),_BumpIntensity)* uvwA.z;
                fixed3 normalB = UnpackNormalWithScale(tex2D(_BumpMap,uvwB.xy),_BumpIntensity)* uvwB.z;

                //Lighting
                half3 N = normalize(normalA + normalB);
                half NdotL = dot(N,i.worldLight);
                half halfLambert = .5 * NdotL + .5;
                //Final
                fixed4 col = (texA + texB) * i.color;
                col.rgb *= halfLambert;
            	col.a *= tex.a;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}