Shader "GPU Gems/Chapter_07 Grass/GrassStar"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" }

            Cull Off

            CGPROGRAM  

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
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
                
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float4 translationPos = float4(sin(_Time.x), 0, sin(_Time.y), 0) * 0.1; 
                v.vertex += translationPos * o.uv.y;            // 优化代码, 去掉 if 语句.

                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = float3(0, 1, 0);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 diffuse = tex2D(_MainTex, i.uv);
                clip(diffuse.a - 0.1);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                diffuse.rgb *= _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));

                return fixed4(ambient + diffuse.rgb, 1.0);
            }


            ENDCG
        }
    }
    FallBack "Diffuse"
}
