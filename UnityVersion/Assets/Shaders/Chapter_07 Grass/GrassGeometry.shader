Shader "GPU Gems/Chapter_07 Grass/GrassGeometry"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _AlphaTex("Alpha Clip Texture", 2D) = "white" {}
    }

    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "Queue" = "AlphaTest" "RenderType" = "Opaque" }

            Cull Off

            CGPROGRAM  

            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AlphaTex;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2g
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;                
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2g vert(a2v v)
            {
                v2g o;

                o.vertex = v.vertex;
                o.normal = v.normal;
                o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }
         
            [maxvertexcount(30)]
            void geom(point v2g points[1], inout TriangleStream<g2f> triStream)
            {
                float4 root = points[0].vertex;
                fixed randomAngle = frac(sin(root.x) * 1234.5) * UNITY_HALF_PI;                

                // 随机旋转.
                float4x4 firstransfromMat = float4x4(
                    1.0, 0.0, 0.0, -root.x,
                    0.0, 1.0, 0.0, -root.y,
                    0.0, 0.0, 1.0, -root.z,
                    0.0, 0.0, 0.0, 1.0);

                float4x4 transformationMatrix = float4x4(
                    cos(randomAngle), 0, sin(randomAngle),0,
                    0, 1, 0, 0,
                    -sin(randomAngle), 0, cos(randomAngle),0,
                    0, 0, 0, 1);

                float4x4 lasttransformat = float4x4(
                    1.0, 0.0, 0.0, root.x,
                    0.0, 1.0, 0.0, root.y,
                    0.0, 0.0, 1.0, root.z,
                    0.0, 0.0, 0.0, 1.0);

                float2 windDir = fixed2(1, 1);
				float2 wind = windDir * sin(_Time.x * UNITY_PI * 5 * (root.x * windDir.x + root.z * windDir.y) / 100);

                g2f o[6];
                for (uint i = 0; i < 10; i += 2)
                {
                    float4 pos = points[0].vertex + float4(0, i / 2, 0, 0) * 0.1;
                    pos.xz += float2(sin(_Time.x), sin(_Time.y)) * 0.2 * sin(pos.y);
                    pos = mul(lasttransformat, mul(transformationMatrix, mul(firstransfromMat, pos)));
                    o[0].uv = float2(0.0, i / 10.0);
                    o[0].pos = UnityObjectToClipPos(pos);

                    pos = points[0].vertex + float4(0, (i + 2) / 2, 0, 0) * 0.1;
                    pos.xz += float2(sin(_Time.x), sin(_Time.y)) * 0.2 * sin(pos.y);
                    pos = mul(lasttransformat, mul(transformationMatrix, mul(firstransfromMat, pos)));
                    o[1].uv = float2(0.0, (i + 2) / 10.0);
                    o[1].pos = UnityObjectToClipPos(pos);                    

                    pos = points[0].vertex + float4(0.5, i / 2, 0, 0) * 0.1;
                    pos.xz += float2(sin(_Time.x), sin(_Time.y)) * 0.2 * sin(pos.y);
                    pos = mul(lasttransformat, mul(transformationMatrix, mul(firstransfromMat, pos)));
                    o[2].uv = float2(1.0, i / 10.0);                    
                    o[2].pos = UnityObjectToClipPos(pos);                    

                    o[3].pos = o[1].pos;
                    o[3].uv = o[1].uv;

                    o[4].pos = o[2].pos;
                    o[4].uv = o[2].uv;

                    pos = points[0].vertex + float4(0.5, (i + 2) / 2, 0, 0) * 0.1;
                    pos.xz += float2(sin(_Time.x), sin(_Time.y)) * 0.2 * sin(pos.y);
                    pos = mul(lasttransformat, mul(transformationMatrix, mul(firstransfromMat, pos)));
                    o[5].uv = float2(1.0, (i + 2) / 10.0);
                    o[5].pos = UnityObjectToClipPos(pos);                    

                    triStream.Append(o[0]);
                    triStream.Append(o[1]);
                    triStream.Append(o[2]);

                    triStream.Append(o[3]);
                    triStream.Append(o[4]);
                    triStream.Append(o[5]);

                    triStream.RestartStrip();
                }                
            }

            fixed4 frag(g2f i) : SV_TARGET
            {
                fixed4 alphaColor = tex2D(_AlphaTex, i.uv);
                clip(alphaColor.a - 0.1);

                fixed3 color = tex2D(_MainTex, i.uv).rgb;                
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
