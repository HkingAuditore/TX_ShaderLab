Shader "Unlit/TerrianPainter"
{
    Properties
    {
        [Header(Ground)]
        _GroundMask ("Ground Mask", 2D) = "white" {}
        _Ground0Color("Ground 0 Color",Color) = (1,1,1,1)
        _Ground1Color("Ground 1 Color",Color) = (1,1,1,1)
        
        [Header(Cliff)]
        _CliffColor("Cliff Color",Color) = (1,1,1,1)
        _CliffThreshold("Cliff Threshold", Range(0, 1)) = 0.5
        
        [Header(Water)]
        _WaterColor("Water Color",Color) = (1,1,1,1)
        _WaterThreshold("Water Threshold", float) = 10
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"

            sampler2D _GroundMask;
            float4 _GroundMask_ST;
            fixed4 _Ground0Color;
            fixed4 _Ground1Color;
            
            float _CliffThreshold;
            fixed4 _CliffColor;

            fixed4 _WaterColor;
            float _WaterThreshold;
            
            struct v2f
            {
                float4 pos : SV_POSITION;	
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) 
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                float4 worldPos : TEXCOORD2;
                float3  worldNormal : TEXCOORD3;
                float3  worldLight : TEXCOORD4;
                float3  viewDir : TEXCOORD5;
            };
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _GroundMask);
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half NdotL = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = NdotL * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(worldNormal,1));
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldLight = normalize(UnityWorldSpaceLightDir(o.pos));
                o.viewDir = normalize(UnityWorldSpaceViewDir(o.pos));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
                return o;
            }

            

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);

                //lighting
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 lighting = i.diff * shadow + i.ambient;

                //ground
                fixed groundMask = tex2D(_GroundMask,i.uv);
                fixed4 groundCol = lerp(_Ground0Color,_Ground1Color,groundMask);

                //cliff
                float cliff =abs(dot(N,float3(0,1,0)));
                cliff = 1 - pow(cliff + _CliffThreshold,10) * _CliffThreshold;
                cliff = 1 - saturate(cliff);

                //water
                float water = i.worldPos.y < _WaterThreshold ? 1 : 0;
                fixed4 waterCol = fixed4(_WaterColor.rgb,water);  

                
                fixed4 col = lerp(_CliffColor,groundCol,cliff);
                col = fixed4(col.rgb * (1-waterCol.a) + waterCol.rgb * waterCol.a,1);
                col.rgb *= lighting;
                
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}