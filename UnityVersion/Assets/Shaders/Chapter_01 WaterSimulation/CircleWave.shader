Shader "GPU Gems/Chapter_01 WaterSimulation/CircleWave"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white" {}

        // 波长.
        _L("Length", Range(0, 10)) = 2
        // 振幅.
        _A("Amplitude", Range(0, 5)) = 0.8
    }
    
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    
    fixed4 _Color;
    sampler2D _MainTex;
    float4 _MainTex_ST;
    float _L;
    float _A;
    float4 _CenterPos;
    
    struct a2v
    {
        float4 vertex : POSITION;
	    float2 texcoord : TEXCOORD0;
    };

    struct v2f
    {
	    float4 pos : SV_POSITION;
        float3 worldPos : TEXCOORD0;
        float3 worldNormal : TEXCOORD1;
	    float2 uv: TEXCOORD2;	    
    };
	
    /// <sumary>
    /// 用于计算顶点 Y 方向的叠加部分.
    /// </sunmay>
    /// <param name="A">振幅.</param>
    /// <param name="omiga">对应三角函数公式中的频率.</param>
    /// <param name="phi">和 t 一同决定波的运动速度.</param>
    /// <param name="t">和 phi 一同决定波的运动速度.</param>
    /// <param name="p">顶点的世界坐标.</param>
    /// <returns>叠加部分的向量.</returns>
    float CaculatePosY(float A, float omiga, float phi, float t, float3 p, float2 center)
    {        
        float len = length(float2(p.x, p.z) - float2(center.x, center.y));
        float2 dir = (float2(p.x, p.z) - float2(center.x, center.y)) / len;

        float a = max(0, -A * len / 30  + A);
        float y = a * sin(omiga * (p.x * dir.x + p.z * dir.y) - t * phi);

        return y;
    }
	
    float3 CaculateNormal(float A, float omiga, float phi, float t, float3 p, float2 center)
    {
        float len = length(float2(p.x, p.z) - float2(center.x, center.y));
        float2 dir = (float2(p.x, p.z) - float2(center.x, center.y)) / len;

        float a = max(0, -A * len / 30  + A);
        float cosValue = sin(omiga * (p.x * dir.x + p.z * dir.y) - t * phi);

        float normalX = a * dir.x * cosValue;
        float normalZ = a * dir.y * cosValue;

        return float3(-normalX, 0, -normalZ);
    }
	
    v2f vert(a2v v)
    {
        v2f o;

        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        float3 disPos = float3(0, 0, 0);
        float omiga = 1 / _L;
        disPos.y += CaculatePosY(_A, omiga * 2, 1, _Time.x * 60, o.worldPos, float2(0.0, 0.0));
 
        float3 normal = float3(0, 1, 0);
        normal += CaculateNormal(_A, omiga * 2, 1, _Time.x * 60, o.worldPos, float2(0.0, 0.0));
 
        v.vertex.xyz = mul(unity_WorldToObject, float4(o.worldPos + disPos, 1));
        o.pos = UnityObjectToClipPos(v.vertex);

        o.worldNormal = normalize(normal); 
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

        return o;
    }	    
	
    fixed4 frag(v2f i) : SV_Target
    { 
        fixed3 worldNormal = normalize(i.worldNormal);
        fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
        fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_MainTex, i.uv).rgb * max(0, dot(worldNormal, worldLightDir));

        return fixed4(diffuse, _Color.a);
    }   

    ENDCG
    
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
            ENDCG
        }   
    }

    FallBack Off
}