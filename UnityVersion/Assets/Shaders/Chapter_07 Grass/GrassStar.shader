Shader "GPU Gems/Chapter_07 Grass/GrassStar"
{
    Properties
    {
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                if (o.uv.y > 0.5)
                {
                    float4 translationPos = float4(sin(_Time.x), 0, sin(_Time.y), 0) * 0.1; 
                    v.vertex += translationPos;
                }
                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 diffuse = tex2D(_MainTex, i.uv);
                clip(diffuse.a - 0.1);

                return diffuse;
            }


            ENDCG
        }
    }
    FallBack "Diffuse"
}
