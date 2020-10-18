using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreatePlaneMesh : MonoBehaviour
{
    private MeshFilter m_MeshFilter;

    public float width;             // 平面宽度.
    public float depth;             // 平面深度.
    public int subX;                // X 轴细分次数.       
    public int subZ;                // Z 轴方向细分次数.

    void Start()
    {
        m_MeshFilter = gameObject.GetComponent<MeshFilter>();

        CreatePlane();
    }

    /// <summary>
    /// 创建Mesh数据.
    /// </summary>
    private void CreatePlane()
    {
        int vertexCount = subX * subZ;
        int faceCount = (subX - 1) * (subZ - 1) * 2;

        // 创建顶点.
        float halfWidth = 0.5f * width;
        float halfDepth = 0.5f * depth;

        float dx = width / (subZ - 1);
        float dz = depth / (subX - 1);

        float du = 1.0f / (subZ - 1);
        float dv = 1.0f / (subX - 1);

        Vector3[] vertices = new Vector3[vertexCount];
        Vector2[] uvs = new Vector2[vertexCount];
        for (int i = 0; i < subX; ++i)
        {
            float z = halfDepth - i * dz;
            for (int j = 0; j < subZ; ++j)
            {
                float x = -halfWidth + j * dx;

                vertices[i * subZ + j] = new Vector3(x, 0.0f, z);

                // UV 坐标对应.
                uvs[i * subZ + j].x = j * du;
                uvs[i * subZ + j].y = i * dv;
            }
        }

        // 创建索引.
        int[] indices = new int[faceCount * 3];
        int k = 0;
        for (int i = 0; i < subX - 1; ++i)
        {
            for (int j = 0; j < subZ - 1; ++j)
            {
                indices[k++] = i * subZ + j;
                indices[k++] = i * subZ + j + 1;
                indices[k++] = (i + 1) * subZ + j;

                indices[k++] = (i + 1) * subZ + j;
                indices[k++] = i * subZ + j + 1;
                indices[k++] = (i + 1) * subZ + j + 1;
            }
        }

        m_MeshFilter.mesh.vertices = vertices;
        m_MeshFilter.mesh.uv = uvs;
        m_MeshFilter.mesh.triangles = indices;
    }
}
