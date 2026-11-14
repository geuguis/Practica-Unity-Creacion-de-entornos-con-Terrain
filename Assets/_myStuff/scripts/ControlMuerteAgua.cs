using System.Collections;
using UnityEngine;
using UnityEngine.UI;

// Script para cuando el jugador toca el agua:
// Oscurece la pantalla, muestra el texto de muerte con sonido y lo devuelve al inicio a los 5 segundos.

public class ControlMuerteAgua : MonoBehaviour
{
    [Header("Elementos de la UI")]
    public CanvasGroup grupoFondoNegro;
    public CanvasGroup grupoTextos;

    [Header("Sonido")]
    public AudioSource fuenteAudio;
    public AudioClip sonidoMuerte;

    [Header("Referencias")]
    public Transform jugador;

    // Variables privadas para guardar donde empieza el jugador
	
    private Vector3 posicionInicial;
    private bool estaMuerto = false;

    void Start()
    {
        // Al empezar el juego la pantalla está transparente para que no se vea el cartel
		
        if (grupoFondoNegro != null)
        {
            grupoFondoNegro.alpha = 0f;
        }

        if (grupoTextos != null)
        {
            grupoTextos.alpha = 0f;
        }

        // Se busca al jugador, por su etiqueta Player
		
        if (jugador == null)
        {
            GameObject objJugador = GameObject.FindGameObjectWithTag("Player");
            if (objJugador != null)
            {
                jugador = objJugador.transform;
            }
        }

        // Guardar la posicion inicial del jugador para hacer el respawn luego
        if (jugador != null)
        {
            posicionInicial = jugador.position;
        }
    }

    // Esta funcion la llama el trigger del agua cuando el jugador entra en contacto
	
    public void Morir()
    {
        // Si ya ha muerto no hace nada para que no se spamee el sonido muchas veces
		
        if (estaMuerto)
        {
            return;
        }

        estaMuerto = true;

        // Reproducimos el sonido de muerte
        if (fuenteAudio != null && sonidoMuerte != null)
        {
            fuenteAudio.PlayOneShot(sonidoMuerte);
        }

        // Start de la corutina que oscurece la pantalla y espera 5 segundos
		
        StartCoroutine(SecuenciaMuerte());
    }

    IEnumerator SecuenciaMuerte()
    {
        // 1. Subir el alpha poco a poco para oscurecer la pantalla totalmente y mostrar el texto
		
        float tiempo = 0f;
        float duracion = 0.6f;

        while (tiempo < duracion)
        {
            tiempo += Time.deltaTime;
            float progreso = tiempo / duracion;

            if (grupoFondoNegro != null)
            {
                grupoFondoNegro.alpha = progreso;
            }

            if (grupoTextos != null)
            {
                grupoTextos.alpha = progreso;
            }

            yield return null;
        }

        // Opacidad 100%
		
        if (grupoFondoNegro != null) grupoFondoNegro.alpha = 1f;
        if (grupoTextos != null) grupoTextos.alpha = 1f;

        // 2. Esperar 5 segundos con la pantalla en negro
		
        yield return new WaitForSeconds(5f);

        // 3. Mover al jugador otra vez a su posicion de spawn original
		
        if (jugador != null)
        {
            // Desactivar un momento el CharacterController porque si no Unity no deja teletransportarlo
			
            CharacterController controlador = jugador.GetComponent<CharacterController>();
            if (controlador != null)
            {
                controlador.enabled = false;
            }

            jugador.position = posicionInicial;

            if (controlador != null)
            {
                controlador.enabled = true;
            }
        }

        // 4. Volver a ocultar el fondo negro y el texto para seguir jugando
		
        if (grupoFondoNegro != null) grupoFondoNegro.alpha = 0f;
        if (grupoTextos != null) grupoTextos.alpha = 0f;

        estaMuerto = false;
    }
}