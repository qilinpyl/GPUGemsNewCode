using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassVerts : MonoBehaviour
{
    private MeshFilter m_MeshFilter;

    private const int area = 1000;

    private void Awake()
    {
        m_MeshFilter = gameObject.GetComponent<MeshFilter>();

        CreateVerts();
    }

    /// <summary>
    /// 草地的顶点, 在这里是用几何着色器拓展顶点.
    /// </summary>
    private void CreateVerts()
    {
        m_MeshFilter.mesh = new Mesh();

        Vector3[] verts = new Vector3[area * area];
        int[] indices = new int[area * area];
        for (int i = 0; i < area; ++i)
        {
            for (int j = 0; j < area; ++j)
            {
                Vector3 pos = new Vector3(Random.Range(-area / 2.0F, area / 2.0f) * 0.05f, 0, Random.Range(-area / 2.0f, area / 2.0f) * 0.05f);
                pos = new Vector3(pos.x, GetHillsHeight(pos.x, pos.z), pos.z);
                verts[i * area + j].Set(pos.x, pos.y, pos.z);
                indices[i * area + j] = i * area + j;
            }
        }

        m_MeshFilter.mesh.vertices = verts;
        m_MeshFilter.mesh.SetIndices(indices, MeshTopology.Points, 0);
    }

    /// <summary>
    /// 获取高度.
    /// </summary>
    private float GetHillsHeight(float x, float z)
    {
        return 0.3f * (z * Mathf.Sin(0.1f * x) + x * Mathf.Cos(0.1f * z));
    }

}
