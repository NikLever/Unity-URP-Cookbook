using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(NavMeshAgent))]
[RequireComponent(typeof(Animator))]

public class GhoulController : MonoBehaviour
{
    public float patrolTime = 15.0f;
    public float seekDistance = 10.0f;
    public Transform player;

    Animator anim;
    NavMeshAgent agent;
    float speed, maxSpeed;
    Vector3 waypoint;

    public Transform waypoints;

    // Start is called before the first frame update
    void Start()
    {
        anim = GetComponent<Animator>();
        agent = GetComponent<NavMeshAgent>();

        InvokeRepeating("Tick", 0, 0.5f);
        if (waypoints != null && waypoints.childCount > 0) InvokeRepeating("Patrol", 0, patrolTime);
        maxSpeed = agent.speed;

    }

    void Patrol()
    {
        int index = (int)Random.Range(0, waypoints.childCount);
        waypoint = waypoints.GetChild(index).position;
        agent.destination = waypoint;
    }

    // Update is called once per frame
    void Update()
    {
        anim.SetFloat("Speed", agent.velocity.magnitude);
    }

    void Tick()
    {
        agent.destination = waypoint;
        agent.speed = maxSpeed / 2.0f;

        if (player!=null && Vector3.Distance(transform.position, player.position) < seekDistance)
        {
            agent.speed = maxSpeed;
            agent.destination = player.position;
        }
    }

}
