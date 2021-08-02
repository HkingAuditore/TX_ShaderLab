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


v2f vert (a2v v) 
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f, o);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    float4 pos = UnityObjectToClipPos(v.vertex);
    float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
    float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;
    float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));//将近裁剪面右上角位置的顶点变换到观察空间
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
    half4 col = tex2D(_MainTex,i.uv);
    return col * _OutLineColor;
}