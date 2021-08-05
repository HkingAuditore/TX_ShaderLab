#pragma vertex vert_outline
#pragma fragment frag_outline
#include "UnityCG.cginc"
#include "ToonShaderLibrary.cginc"


float4 OUTLINE_POS(a2v_outline v, v2f_outline o)
{
    #ifdef CUSTOM_OUTLINE_POS_FUNC
        return CUSTOM_OUTLINE_POS_FUNC(v,o);
    #else
        float4 pos = UnityObjectToClipPos(v.vertex);
        float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
        float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;
        float4 nearUpperRight = mul(unity_CameraInvProjection,
        float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
        //将近裁剪面右上角位置的顶点变换到观察空间
        float aspect = abs(nearUpperRight.y / nearUpperRight.x);
        ndcNormal.x *= aspect;
        pos.xy += 0.01 * (_OutlineWidth) * ndcNormal.xy;
        return pos;
    #endif
}

float4 OUTLINE_COLOR(v2f_outline i)
{
    #ifdef CUSTOM_OUTLINE_COLOR_FUNC
        return CUSTOM_OUTLINE_COLOR_FUNC(i);
    #else
        half4 col = tex2D(_MainTex, i.uv);
        return col * _OutLineColor;
    #endif
}


v2f_outline vert_outline(a2v_outline v)
{
    v2f_outline o;
    UNITY_INITIALIZE_OUTPUT(v2f_outline, o);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.bitangent = mul(unity_ObjectToWorld, cross(v.normal, v.tangent));;

    o.pos = OUTLINE_POS(v, o);
    o.color = v.color;
    return o;
}

half4 frag_outline(v2f_outline i) : SV_TARGET
{
    return OUTLINE_COLOR(i);
}
