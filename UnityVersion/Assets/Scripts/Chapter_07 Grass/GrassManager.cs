using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassManager : MonoBehaviour
{
    private GameObject prefab_Grass01;
    private GameObject prefab_Grass02;
    
    private void Start()
    {
        Init();
        CreateGrass();
    }

    private void Init()
    {
        prefab_Grass01 = Resources.Load<GameObject>("Chapter_07 Grass/Grass_01");
        prefab_Grass02 = Resources.Load<GameObject>("Chapter_07 Grass/Grass_02");
    }

    private void CreateGrass()
    {
        for (int i = 0; i < 100; ++i)
        {
            for (int j = 0; j < 100; ++j)
            {
                Vector3 pos = new Vector3(Random.Range(-50f, 50f), 0, Random.Range(-50f, 50f));
                pos = new Vector3(pos.x, GetHillsHeight(pos.x, pos.z), pos.z);
                Quaternion rot = Quaternion.Euler(new Vector3(0, Random.Range(-180f, 180f), 0));

                GameObject grass = null;
                if (Random.Range(0, 100) % 2 == 0)
                {
                    grass = Instantiate<GameObject>(prefab_Grass01, pos, rot, transform);
                }
                else
                {
                    grass = Instantiate<GameObject>(prefab_Grass02, pos, rot, transform);
                }
            }
        }
    }

    private float GetHillsHeight(float x, float z)
    {
        return 0.3f * (z * Mathf.Sin(0.1f * x) + x * Mathf.Cos(0.1f * z));
    }
}
