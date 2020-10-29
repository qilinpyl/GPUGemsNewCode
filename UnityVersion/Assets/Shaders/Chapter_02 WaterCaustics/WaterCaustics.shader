Shader "GPU Gems/Chapter_02 WaterCaustics/WaterCaustics"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _SunTex("Sun Texture", 2D) = "white" {}
        _Caustic("Caustic", Range(0, 5)) = 1.0

        // 波长.
        _L("Length", Range(0, 10)) = 2
        // 振幅.
        _A("Amplitude", Range(0, 5)) = 0.8
    }

    SubShader
    {
        CGINCLUDE

        #include "Lighting.cginc"
        #include "UnityCG.cginc"

        fixed4 _Color;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _SunTex;
        half _Caustic;
        float _L;
        float _A;

        struct a2v
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD1;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 worldPos : TEXCOORD0;
            float3 worldNormal : TEXCOORD1;
            float2 uv : TEXCOORD2;
        };

        v2f vert(a2v v)
        {
            v2f o;

            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            o.pos = UnityWorldToClipPos(o.worldPos);
            o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

            return o;
        }

        fixed4 frag(v2f i) : SV_TARGET
        {
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

            fixed3 worldNormal = normalize(i.worldNormal);
            fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
            fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_MainTex, i.uv).rgb * max(0, dot(worldNormal, worldLightDir));

            return fixed4(ambient + diffuse, 1.0);
        }

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

        // 书中的方法和这里使用的方法都不是真正意义上的物理上的焦散效果, 在这里只是一种近似效果.
        float2 CaculateIntercept(float3 wavePos, float3 waveNormal)
        {
            float dis = abs(5 - wavePos.y);
            return float2(dis, dis);
        }

        v2f vertWater(a2v v)
        {
            v2f o;

            o.worldPos = mul(unity_ObjectToWorld, v.vertex) + float4(0, 5, 0, 0);
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
    
            o.worldPos += float4(disPos, 1);
            o.pos = UnityObjectToClipPos(v.vertex);

            o.worldNormal = normalize(normal); 
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

            return o;
        }	    
        
        fixed4 fragWater(v2f i) : SV_Target
        { 
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

            float2 intercept = CaculateIntercept(i.worldPos, i.worldNormal);
            float caustic = tex2D(_SunTex, intercept.xy * _Caustic).r;

            fixed3 worldNormal = normalize(i.worldNormal);
            fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
            fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_MainTex, i.uv).rgb * max(0, dot(worldNormal, worldLightDir));

            return fixed4(ambient + diffuse * caustic, _Color.a);
        }   

        ENDCG

        Pass
        {
            Tags { "LightMode" = "ForwardBase" "Queue" = "Opaque" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" "Queue" = "Transparent" }

            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vertWater
            #pragma fragment fragWater

            ENDCG
        }
        
    }

    FallBack "Diffuse"
}
