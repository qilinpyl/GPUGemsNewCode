///***********************************************************************************
/// 波浪运动着色器.
///***********************************************************************************

#include "Common.hlsl"

/// 顶点着色器输入.
struct VertexIn
{
	float3 PosL	   : POSITION;
	float3 NormalL : NORMAL;
	float2 TexC    : TEXCOORD0;
};

/// 顶点着色器输出, 像素着色器输入.
struct VertexOut
{
	float4 PosH	   : SV_POSITION;
	float4 PosW    : POSITION;
	float3 NormalW : NORMAL;
	float2 TexC    : TEXCOORD0;
};

// 用于控制波的抖动程度.
static const float Q = 1.0f;

/// 波长.
static const float WaveLength = 8.0f;

/// 振幅.
static const float Amplitude = 3.5f;

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
float3 CaculatePos(float A, float omiga, float phi, float t, float2 dir, float4 p)
{
	dir = normalize(dir);

	float y = A * sin(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);
	float x = Q * A * dir.x * cos(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);
	float z = Q * A * dir.y * cos(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);
	float3 pos = float3(x, y, z);

	return pos;
}

float3 CaculateNormal(float A, float omiga, float phi, float t, float2 dir, float4 p)
{
	dir = normalize(dir);

	// 通过对 x 方向和 z 方向分别求偏导叉积计算得到法线.
	float S = sin(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);
	float C = cos(omiga * (p.x * dir.x + p.z * dir.y) + t * phi);
	float WA = omiga * A;
	float x = -dir.x * WA * C;
	float y = -Q * WA * S;
	float z = -dir.y * WA * C;
	float3 normal = float3(x, y, z);

	return normal;
}

/// 顶点着色器.
VertexOut VS (VertexIn vin)
{
	VertexOut vout;

	vout.PosW = mul(float4(vin.PosL, 1.0), gObjectConstants.gWorld);
    float4 disPos = float4(0, 0, 0, 0);
    float omiga = 1 / WaveLength;
    
    disPos.xyz += CaculatePos(Amplitude / 8, omiga * 2, 1, gPassConstants.gTotalTime * 8, float2(-1, -1), vout.PosW); 
    disPos.xyz += CaculatePos(Amplitude, omiga, 1, gPassConstants.gTotalTime * 6, float2(2, -0.5), vout.PosW);
    disPos.xyz += CaculatePos(Amplitude / 2, omiga / 4, 1, gPassConstants.gTotalTime * 4, float2(1, 2), vout.PosW);
    disPos.xyz += CaculatePos(2 * Amplitude, omiga / 2, 1, gPassConstants.gTotalTime * 2, float2(1, -1), vout.PosW);

    float3 normal = float3(0, 1, 0);
    normal += CaculateNormal(Amplitude / 8, omiga * 2, 1, gPassConstants.gTotalTime * 8, float2(-1, -1), vout.PosW);
    normal += CaculateNormal(Amplitude, omiga, 1, gPassConstants.gTotalTime * 6, float2(2, -0.5), vout.PosW);
    normal += CaculateNormal(Amplitude / 2, omiga / 4, 1, gPassConstants.gTotalTime * 4, float2(1, 2), vout.PosW);  
    normal += CaculateNormal(2 * Amplitude, omiga / 2, 1, gPassConstants.gTotalTime * 2, float2(1, -1), vout.PosW);

    vout.PosW = vout.PosW + disPos;
    vout.PosH = mul(vout.PosW, gPassConstants.gViewProj);

	vout.NormalW = normal;

	float4 texC = mul(float4(vin.TexC, 0.0, 1.0), gObjectConstants.gTexTransform);
	vout.TexC = mul(texC, gMaterialConstants.gMatTransform).xy;

	return vout;
}

/// 像素着色器.
float4 PS (VertexOut pin) : SV_Target
{
	// 纹理采样.
	float4 diffuseAlbedo = gDiffuseMap.Sample(gsamAnisotropicWrap, pin.TexC) *
		gMaterialConstants.gDiffsueAlbedo;

	// 获取环境光.
	float4 ambient = gPassConstants.gAmbientLight * diffuseAlbedo;

	// 光照计算必需.
	pin.NormalW = normalize(pin.NormalW);
	float3 toEyeW = normalize(gPassConstants.gEyePosW - pin.PosW.xyz);

	// 光照计算.
	const float gShininess = 1 - gMaterialConstants.gRoughness;
	Material mat = { diffuseAlbedo, gMaterialConstants.gFresnelR0, gShininess };
	float4 dirLight = ComputeLighting(gPassConstants.gLights, mat, pin.PosW.xyz, pin.NormalW, toEyeW, 1.0);

	float4 finalColor = ambient + dirLight;
	finalColor.a = diffuseAlbedo.a;

	return finalColor;
}
