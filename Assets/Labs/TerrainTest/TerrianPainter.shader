Shader "Unlit/TerrianPainter"
{
    Properties
    {
        [Header(Ground)]
        _GroundMask ("Ground Mask", 2D) = "white" {}
        [Header(Low Altitude)]
        _Ground0Color("Ground 0 Color",Color) = (1,1,1,1)
        [NoScaleOffset]_Ground0Tex("Ground 0 Texture", 2D) = "white" {}
        [Header(High Altitude)]
        _Ground1Color("Ground 1 Color",Color) = (1,1,1,1)
        [NoScaleOffset]_Ground1Tex("Ground 1 Texture", 2D) = "white" {}
        _Ground1Height("Ground 1 Height", float) = 10
        
        

        [Space(25)]
        [Header(Cliff)]
        _CliffColor("Cliff Color",Color) = (1,1,1,1)
        [NoScaleOffset]_CliffTex("Cliff Texture", 2D) = "white" {}
        _CliffThreshold("Cliff Threshold", Range(0, 1)) = 0.5
    	
	    [Space(25)]
        [Header(Water)]
        _WaterColor("Water Color",Color) = (1,1,1,1)
        _WaterThreshold("Water Threshold", float) = 10
        
	    [Space(25)]
    	[Header(Others)]
	    _Tiling("Tiling", Range(0.001, .1)) = 0.5
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

            half _Tiling;

            sampler2D _GroundMask;
            float4 _GroundMask_ST;
            
            fixed4 _Ground0Color;
            sampler2D _Ground0Tex;

            half _Ground1Height;
            fixed4 _Ground1Color;
            sampler2D _Ground1Tex;

            sampler2D _CliffTex;
            half _CliffThreshold;
            fixed4 _CliffColor;

            fixed4 _WaterColor;
            half _WaterThreshold;

            
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

            fixed4 hash4(fixed2 p ) { return frac(sin(fixed4( 1.0+dot(p,fixed2(37.0,17.0)), 
                                              2.0+dot(p,fixed2(11.0,47.0)),
                                              3.0+dot(p,fixed2(41.0,29.0)),
                                              4.0+dot(p,fixed2(23.0,31.0))))*103.0); }

            fixed4 texNoTileTech1(sampler2D tex, float2 uv) {
				float2 iuv = floor(uv);
				float2 fuv = frac(uv);

				// Generate per-tile transformation
				float4 ofa = hash4(iuv + float2(0, 0));
				float4 ofb = hash4(iuv + float2(1, 0));
				float4 ofc = hash4(iuv + float2(0, 1));
				float4 ofd = hash4(iuv + float2(1, 1));


				// Compute the correct derivatives
				float2 dx = ddx(uv);
				float2 dy = ddy(uv);

				// Mirror per-tile uvs
				ofa.zw = sign(ofa.zw - 0.5);
				ofb.zw = sign(ofb.zw - 0.5);
				ofc.zw = sign(ofc.zw - 0.5);
				ofd.zw = sign(ofd.zw - 0.5);

				float2 uva = uv * ofa.zw + ofa.xy, dxa = dx * ofa.zw, dya = dy * ofa.zw;
				float2 uvb = uv * ofb.zw + ofb.xy, dxb = dx * ofb.zw, dyb = dy * ofb.zw;
				float2 uvc = uv * ofc.zw + ofc.xy, dxc = dx * ofc.zw, dyc = dy * ofc.zw;
				float2 uvd = uv * ofd.zw + ofd.xy, dxd = dx * ofd.zw, dyd = dy * ofd.zw;

				// Fetch and blend
				float2 b = smoothstep(.7, 1.0 - .7, fuv);

				return lerp(	lerp(tex2D(tex, uva, dxa, dya), tex2D(tex, uvb, dxb, dyb), b.x),
								lerp(tex2D(tex, uvc, dxc, dyc), tex2D(tex, uvd, dxd, dyd), b.x), b.y);
			}

            

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);

                //lighting
                half shadow = SHADOW_ATTENUATION(i);
                float3 lighting = i.diff * shadow + i.ambient;

                //ground
                half groundMask = tex2D(_GroundMask,i.uv);
                half heightMask = clamp(_Ground1Height - i.worldPos.y,-2,2) *.5 + 1;
                heightMask = saturate(pow(heightMask,.95) * .5);
                groundMask *= heightMask;
                float4 col0 = _Ground0Color * texNoTileTech1(_Ground0Tex,float2(i.worldPos.x,i.worldPos.z) * _Tiling);
                float4 col1 = _Ground1Color * texNoTileTech1(_Ground1Tex,float2(i.worldPos.x,i.worldPos.z) * _Tiling);
                float4 groundCol = lerp(col0,col1,1 - groundMask);

                //cliff
                float cliff =abs(dot(N,float3(0,1,0)));
                cliff = 1 - pow(cliff + _CliffThreshold,10) * _CliffThreshold;
                cliff = 1 - saturate(cliff);
                float4 cliffCol = _CliffColor * tex2D(_CliffTex,float2(i.worldPos.x,i.worldPos.z) * _Tiling);

                //water
                half water = i.worldPos.y < _WaterThreshold ? 1 : 0;
                float4 waterCol = fixed4(_WaterColor.rgb,water);  

                
                float4 col = lerp(cliffCol,groundCol,cliff);
                col = float4(col.rgb * (1-waterCol.a) + waterCol.rgb * waterCol.a,1);
                col.rgb *= lighting;
                
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}