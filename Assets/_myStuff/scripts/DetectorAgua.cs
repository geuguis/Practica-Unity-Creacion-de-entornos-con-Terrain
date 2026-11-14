using UnityEngine;

// Este script va puesto en el objeto del agua (WaterPlane) que tiene un BoxCollider con Is Trigger activado

public class DetectorAgua : MonoBehaviour
{
    public ControlMuerteAgua controlMuerte;

    // Evento de Unity que se ejecuta cuando un objeto entra en el trigger del agua
	
    private void OnTriggerEnter(Collider other)
    {
        // Comprobar si el objeto que ha tocado el agua tiene el tag "Player"
		
        if (other.CompareTag("Player"))
        {
            if (controlMuerte != null)
            {
                controlMuerte.Morir();
            }
        }
    }

    // Por si el collider no estuviera en modo trigger, tambien detecta la colision normal
	
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            if (controlMuerte != null)
            {
                controlMuerte.Morir();
            }
        }
    }
}
