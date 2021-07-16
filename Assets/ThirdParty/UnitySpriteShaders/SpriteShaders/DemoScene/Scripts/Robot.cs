using UnityEngine;

public class Robot : MonoBehaviour
{
	void Start () 
	{
		Animator animator = GetComponent<Animator>();
		animator.SetFloat("Offset", Random.Range(0f, 1.0f));
	}
}
