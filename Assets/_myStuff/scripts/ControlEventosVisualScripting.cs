using UnityEngine;
using Unity.VisualScripting;
#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif

// Este script conecta la tecla B con el grafo de Visual Scripting  y activa o desactiva la animacion de baile y la musica en bucle
public class ControlEventosVisualScripting : MonoBehaviour
{
    [Header("Componentes del Baile (Tecla B)")]
    public Animator animadorJugador;
    public AudioSource musicaBaile;
    public MonoBehaviour controlMovimiento;

    // Guarda el ultimo frame en el que se pulso la B para evitar que se dispare dos veces
    private static int ultimoFrameTeclaB = -1;

    private void Start()
    {
        if (animadorJugador == null)
        {
            animadorJugador = GetComponent<Animator>();
        }
    }

    private void Update()
    {
        // Comprobar si el jugador ha pulsado la tecla B en este frame
        bool pulsadaB = false;

#if ENABLE_INPUT_SYSTEM
        if (Keyboard.current != null && Keyboard.current.bKey.wasPressedThisFrame)
        {
            pulsadaB = true;
        }
#else
        if (Input.GetKeyDown(KeyCode.B))
        {
            pulsadaB = true;
        }
#endif

        // Si se ha pulsado B, envia el evento "TeclaB" al grafo de Visual Scripting
        if (pulsadaB && Time.frameCount != ultimoFrameTeclaB)
        {
            ultimoFrameTeclaB = Time.frameCount;
            CustomEvent.Trigger(gameObject, "TeclaB");
        }
    }

    // Este metodo lo llama el nodo Invoke Member del grafo de Visual Scripting 
    public void CambiarEstadoBaile(bool bailando)
    {
        if (animadorJugador == null)
        {
            animadorJugador = GetComponent<Animator>();
        }

        if (controlMovimiento != null)
        {
            controlMovimiento.enabled = !bailando;
        }

        if (animadorJugador != null)
        {
            if (bailando)
            {
                // Velocidad a 0 para que quede quieto en el sitio bailando
                animadorJugador.SetFloat("Speed", 0f);
                animadorJugador.SetFloat("MotionSpeed", 1f);
                animadorJugador.SetBool("Jump", false);
                animadorJugador.SetBool("FreeFall", false);
            }

            // Activar o desactivar el parametro "Bailando" del Animator
            animadorJugador.SetBool("Bailando", bailando);
        }

        // Enciende o apagamos la musica en bucle
        if (musicaBaile != null)
        {
            musicaBaile.loop = true;

            if (bailando)
            {
                musicaBaile.Play();
            }
            else
            {
                musicaBaile.Stop();
            }
        }
    }
}