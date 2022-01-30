using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Butterfly : MonoBehaviour
{
    Animator anim;

    void Awake()
    {
        anim = GetComponent<Animator>();
        anim.SetFloat("FlySpeed", Random.Range(0.8f, 1.8f));
        anim.SetFloat("FlyOffset", Random.Range(0, 20));
    }
}
