# Proyecto 01 — Creación de Entornos 3D con Terrain (Unity)

> **Actividad Evaluativa 01** · Diseño de entornos 3D, materiales, iluminación, controlador en tercera persona, programación en C# y Unity Visual Scripting.

---

## Contexto del proyecto

Este repositorio recoge el desarrollo de la práctica **Proyecto 01 - Creación de entornos con Terrain**, cuyo objetivo es combinar el diseño de escenarios 3D en Unity con la configuración de materiales, ambientación, control de personaje en tercera persona y lógica interactiva tanto mediante **scripts en C#** como con **Unity Visual Scripting**.

El escenario sigue una **estética estilizada / fantasía rural** (*hand-painted* y *low-poly*), con zonas de césped, tierra y arena, cielo estilizado, construcciones y vegetación decorativa, además de mecánicas interactivas para el jugador.

---

## Tecnologías y paquetes principales

- **Motor:** Unity `6000.3.19f1` (Unity 6)
- **Render Pipeline:** Universal Render Pipeline (URP `17.3.0`)
- **Control e Input:** Unity Input System (`1.19.0`) & Cinemachine (`3.1.7`)
- **Terreno:** Unity Terrain & Terrain Tools (`5.3.3`)
- **Programación visual:** Unity Visual Scripting (`1.9.11`)
- **Lenguaje:** C#

---

## Características implementadas

### 1. Terreno y Texturizado
- Esculpido de relieve en Unity Terrain (elevaciones, valles y zonas costeras/agua).
- Aplicación de múltiples *Terrain Layers* (`Cesped`, `Tierra`, `Arena` y variantes) combinando texturas externas estilizadas (*Handpainted Grass and Ground Textures* y *Terrain Sample Assets*).

### 2. Ambientación del entorno
- Cielo estilizado mediante **Fantasy Skybox FREE**.
- Decoración con prefabs y modelos 3D estilizados (*CuteMagic DairyFarm FreePack*, *LowPolyFarmLite*, *EmaceArt* y *Stylized NPC - Peasant Nolant*).
- Iluminación y atmósfera configuradas en URP (`Assets/Scenes/SampleScene.unity`).

### 3. Controlador en tercera persona
- Integración del paquete **Starter Assets** (`ThirdPersonController`) con cámara de seguimiento mediante **Cinemachine**.
- Desplazamiento completo por el terreno (caminar, correr y saltar).

### 4. Programación en C# (`Assets/_myStuff/scripts/`)
- **Sistema de detección de agua y respawn (`DetectorAgua.cs` y `ControlMuerteAgua.cs`):**
  - `DetectorAgua` detecta cuando el objeto con etiqueta `Player` entra en el área del agua (`OnTriggerEnter` / `OnCollisionEnter`) y notifica a `ControlMuerteAgua`.
  - `ControlMuerteAgua` reproduce un efecto de sonido (`snake_death.mp3`), realiza un fundido a negro progresivo (`0.6 s`) mostrando la interfaz de muerte (`CanvasMuerte.prefab`), espera `5` segundos, desactiva temporalmente el `CharacterController` para teletransportar al jugador a su posición inicial de aparición y restaura la pantalla.
- **Puente de eventos para Visual Scripting (`ControlEventosVisualScripting.cs`):**
  - Captura la pulsación de la tecla `B` mediante el nuevo `InputSystem` (con fallback a `Input.GetKeyDown`) evitando disparos duplicados en el mismo frame.
  - Emite el evento personalizado `"TeclaB"` hacia el grafo de Visual Scripting (`CustomEvent.Trigger`).
  - Expone el método `CambiarEstadoBaile(bool bailando)` para bloquear/desbloquear el movimiento del jugador, actualizar los parámetros del `Animator` (`Bailando`, `Speed`, `MotionSpeed`, `Jump`, `FreeFall`) y reproducir o detener la música en bucle (`dance-de-rat.mp3`).

### 5. Visual Scripting (`Assets/_myStuff/visualScripting/BaileCapoeira.asset`)
- Grafo **Baile Capoeira (Tecla B)**:
  - Escucha el evento personalizado `TeclaB`.
  - Lee y alterna la variable de objeto booleana `estaBailando` (nodo `Negate`).
  - Evalúa una condición lógica (`If`) y ejecuta `ControlEventosVisualScripting.CambiarEstadoBaile(true/false)` mediante `InvokeMember`, activando o desactivando la animación de Capoeira (`Ch01_nonPBR@Capoeira.fbx`) y su música asociada.

---

## Controles

| Acción | Entrada |
| :--- | :--- |
| Mover personaje | `W` `A` `S` `D` / Flechas |
| Correr | `Shift` izquierdo |
| Saltar | `Espacio` |
| Cámara | Ratón |
| Activar / desactivar baile de Capoeira | `B` |

---

## Estructura del proyecto

```text
Eugui_Guillermo_Actividad_Eva_01/
├── Assets/
│   ├── Scenes/
│   │   └── SampleScene.unity              # Escena principal del proyecto
│   ├── Starter Assets/                    # Controlador de tercera persona y Cinemachine
│   ├── _myStuff/
│   │   ├── animaciones/                   # Animación Capoeira (FBX)
│   │   ├── materials/                     # Skybox y texturas hand-painted
│   │   ├── models/                        # Modelos de personaje/NPC
│   │   ├── prefabs/                       # Packs decorativos del entorno
│   │   ├── scripts/                       # Scripts en C# (agua, respawn, puente VS)
│   │   ├── sounds/                        # Audio de muerte y baile
│   │   ├── terrain/                       # Recursos y demos de terreno
│   │   ├── UI/                            # Prefab CanvasMuerte
│   │   └── visualScripting/               # Grafo BaileCapoeira.asset
│   └── *.terrainlayer                     # Capas de textura del terreno
├── Packages/                              # Dependencias (manifest.json)
└── ProjectSettings/                       # Configuración del proyecto Unity
```

---

## Cómo abrir y ejecutar el proyecto

1. Clona este repositorio en tu equipo:
   ```bash
   git clone <URL-DEL-REPOSITORIO>
   ```
2. Abre **Unity Hub** y selecciona **Add > Add project from disk** apuntando a la carpeta raíz del proyecto.
3. Ábrelo con **Unity `6000.3.19f1`** (o una versión compatible de Unity 6).
4. Carga la escena `Assets/Scenes/SampleScene.unity` y pulsa **Play**.

---

## Assets y recursos utilizados

- **Starter Assets - Third Person Character Controller** (Unity Technologies)
- **Fantasy Skybox FREE** (Render Knight)
- **Handpainted Grass and Ground Textures**
- **CuteMagic DairyFarm FreePack**
- **LowPolyFarmLite** / **EmaceArt**
- **Stylized NPC - Peasant Nolant**
- **Nyxis Grass Interaction System**
- **Terrain Sample Assets** (Unity Technologies)

---

## Autor

**Guillermo Eugui**
