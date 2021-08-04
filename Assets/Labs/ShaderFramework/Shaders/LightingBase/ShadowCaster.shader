Shader "ShaderFramework/Lighting/ShadowCaster"
{
    Properties
    {
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
            Name "ShadowCasterPass"
			Tags{ "LightMode" = "ShadowCaster" }		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
	
			float4 vert (float4 vertex:POSITION) : SV_POSITION
			{
				// vertex.xyz-=(sin(_Time.g)*0.5+0.5)*normal*hash(float(id));
				return UnityObjectToClipPos(vertex);								
			}

			float4 frag() : COLOR
			{
				return 0;
			}
			ENDCG
        }
    }
}