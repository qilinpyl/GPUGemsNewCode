Shader "GPU Gems/Chapter_01 WaterSimulation/RandomAddWave"
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
    /// <param name="dir">几何波的扰动方向.</param>
    /// <param name="p">顶点的世界坐标.</param>
    /// <returns>叠加部分的向量.</returns>
    float CaculatePosY(float A, float omiga, float phi, float t, float2 dir, float3 p)
    {
        dir = normalize(dir);
        float y = A * sin(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);
        
        return y;
    }
	
    float3 CaculateNormal(float A, float omiga, float phi, float t, float2 dir, float3 p)
    {
        dir = normalize(dir);

        float cosValue = cos(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);

        float normalX = A * dir.x * omiga * cosValue;
        float normalZ = A * dir.y * omiga * cosValue;

        return float3(-normalX, 0, -normalZ);
    }
	
    v2f vert(a2v v)
    {
        v2f o;

        o.worldPos = mul(unity_ObjectToWorld, v.vertex);
        float3 disPos = float3(0, 0, 0);
        float omiga = 1 / _L;
	    
        disPos.y += CaculatePosY(_A / 8, omiga * 2, 1, _Time.x * 80, float2(-1, -1), o.worldPos); 
        disPos.y += CaculatePosY(_A, omiga, 1, _Time.x * 60, float2(2, -0.5), o.worldPos);   
        disPos.y += CaculatePosY(_A / 2, omiga / 4, 1, _Time.x * 40, float2(1, 2), o.worldPos); 
        disPos.y += CaculatePosY(2 * _A, omiga / 2, 1, _Time.x * 20, float2(1, -1), o.worldPos); 
 
        float3 normal = float3(0, 1, 0);
        normal += CaculateNormal(_A / 8, omiga * 2, 1, _Time.x * 80, float2(-1, -1), o.worldPos);
        normal += CaculateNormal(_A, omiga, 1, _Time.x * 60, float2(2, -0.5), o.worldPos);
        normal += CaculateNormal(_A / 2, omiga / 4, 1, _Time.x * 40, float2(1, 2), o.worldPos);  
        normal += CaculateNormal(2 * _A, omiga / 2, 1, _Time.x * 20, float2(1, -1), o.worldPos);
 
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