# Paradigmas-Haski: Dungeon Crawler en Haskell
**INFO188 - Tarea 1: Programación Funcional**

## Tabla de Contenidos
- [Descripción del Proyecto](#descripción-del-proyecto)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación y Compilación](#instalación-y-compilación)
- [Arquitectura del Código](#arquitectura-del-código)
- [Uso de la Mónada State](#uso-de-la-mónada-state)
- [Conceptos de Programación Funcional](#conceptos-de-programación-funcional)
- [Estructura de Archivos](#estructura-de-archivos)

---

## Descripción del Proyecto

Este proyecto es un juego de tipo **Dungeon Crawler** desarrollado completamente en **Haskell**, utilizando el paradigma de **programación funcional**. El juego demuestra el uso extensivo de la **mónada State** para gestionar el estado mutable del jugador y los enemigos de manera funcional y pura.

### Características Principales
- **Sistema de combate por turnos** inspirado en Dungeons & Dragons
- **Progresión de 11 niveles** (pisos 0-10) con un boss final
- **3 clases jugables** con estadísticas únicas
- **Sistema de bendiciones** para mejorar al personaje entre niveles
- **Mecánica de dados** (d20 y d8) para determinar acierto y daño
- **Interfaz gráfica interactiva** usando la biblioteca Gloss

### Objetivo del Proyecto
Demostrar el dominio de conceptos de programación funcional, especialmente:
- Uso de la **mónada State** para transformaciones de estado
- **Funciones puras** y composición de funciones
- **Tipos algebraicos de datos** (ADTs)
- **Inmutabilidad** y manejo de estado sin mutación directa
- **Pattern matching** y funciones de orden superior

---

## Requisitos del Sistema

### Dependencias Necesarias
- **GHC** (Glasgow Haskell Compiler) 8.10 o superior
- **Cabal** 3.0 o superior
- **Bibliotecas de Haskell:**
  - `gloss` - Para gráficos y renderizado
  - `mtl` - Para la mónada State
  - `random` - Para generación de números aleatorios
- **FreeGLUT** - Para renderizado OpenGL

### Instalación de Dependencias

```bash
# Actualizar e instalar las dependencias del sistema
sudo apt-get update
sudo apt-get install -y freeglut3-dev

# Instalar Cabal y actualizar el índice de paquetes
sudo apt install cabal-install
cabal update

# Instalar las bibliotecas de Haskell necesarias
cabal install --lib gloss
cabal install --lib mtl
cabal install --lib random
```

---

## Instalación y Compilación

### Pasos para Ejecutar el Proyecto

1. **Clonar el repositorio**
```bash
git clone https://github.com/BenjaUribe/paradigmas-haski.git
cd paradigmas-haski
```

2. **Compilar el proyecto**
```bash
make
```

3. **Ejecutar el juego**
```bash
./game
```

### Makefile
El proyecto incluye un Makefile que automatiza la compilación:
```makefile
ghc -package gloss -o game Main.hs Game.hs
```

---

## Arquitectura del Código

El proyecto está organizado en dos módulos principales:

### `Game.hs` - Lógica del Juego
Contiene toda la lógica central del juego:
- **Tipos de datos:** `Player`, `Enemy`, `CharacterClass`, `EnemyClass`
- **Funciones State:** `doAttack`, `takeDamage`, `takeHeal`, `powerUpDamage`
- **Constructores:** `createPlayer`, `createEnemy`
- **Configuración de pisos:** `floorConfigurations`, `getFloorData`
- **Carga de recursos:** `loadGameImages`, `getPlayerSprite`, `getEnemySprite`

### `Main.hs` - Interfaz Gráfica y Control
Maneja toda la interacción con el usuario:
- **Renderizado:** Funciones para dibujar cada escena del juego
- **Manejo de eventos:** Input del teclado y navegación entre escenas
- **Game loop:** Actualización del estado y renderizado continuo
- **Sistema de combate:** Integración con las funciones State de Game.hs

---

## Uso de la Mónada State

La **mónada State** es el corazón de la gestión del estado en este proyecto. Permite modificar el estado de jugadores y enemigos de manera funcional, sin mutación directa.

### Definición de State en el Proyecto

```haskell
-- Función que modifica el estado de un Enemy
doAttack :: Player -> State Enemy String
doAttack player = do
    modify (\enemy -> enemy { enemyHealth = enemyHealth enemy - round (playerDamage player) })
    return ("El enemigo ha recibido " ++ show (round (playerDamage player)) ++ " de daño")

-- Función que modifica el estado de un Player
takeDamage :: Enemy -> State Player String
takeDamage enemy = do
    modify (\player -> player { playerHealth = playerHealth player - round (enemyDamage enemy) })
    return ("Ha recibido " ++ show (enemyDamage enemy) ++ " de daño")
```

### Ventajas de Usar State

- **Inmutabilidad:** No se modifica directamente el estado, se crean nuevas versiones
- **Composición:** Se pueden encadenar múltiples operaciones State
- **Pureza:** Las funciones siguen siendo puras, el estado se pasa explícitamente
- **Testabilidad:** Fácil de probar al ser determinista

---

### Clases de Personajes

El jugador puede elegir entre tres clases, cada una con estadísticas balanceadas:

| Clase   | Vida (HP) | Daño Base | Descripción |
|---------|-----------|-----------|-------------|
| Warrior | 100       | 5.0       | Equilibrado en ataque y defensa |
| Tank    | 150       | 1.5       | Alta resistencia, bajo daño |
| Rogue   | 80        | 3.5       | Ágil con daño moderado |

### Sistema de Pisos

El juego consta de **11 pisos** (0-10):
- **Piso 0:** Nivel inicial sin enemigos
- **Pisos 1-3:** Niveles básicos sin pasillo de bendiciones
- **Pisos 4-9:** Niveles intermedios con pasillo de bendiciones
- **Piso 10:** Boss final (Warlock)

### Progresión de Niveles

```
         [10] BOSS
        /  |  \
      [7] [8] [9]
       |/  |   |
      [4][5] [6]
       |  |  \|
      [1][2][3]
        \ | /
         [0]
```

### Sistema de Combate

#### Dados
- **d20 (Acierto):** Si el resultado es < 5, el ataque falla
- **d8 (Daño):** Se suma al daño base del atacante

#### Acciones Disponibles
1. **Atacar:** Inflige daño al primer enemigo
   - Lanza d20 para acierto y d8 para daño adicional
   
2. **Bloquear:** Reduce el daño recibido en 50% durante ese turno
   - Los enemigos atacan con daño reducido
   
3. **Escapar:** Intento fallido que resulta en un castigo
   - Los enemigos atacan sin reducción de daño

### Sistema de Bendiciones

A partir del **piso 4**, el jugador entra a un **pasillo con moáis** antes del combate:

1. **Movimiento:** El jugador debe moverse hacia arriba usando WASD o flechas
2. **Zona de bendición:** Al alcanzar la parte superior, aparece el menú
3. **Opciones de mejora:**
   - **Mejorar Vida:** +20 HP
   - **Mejorar Ataque:** +5.0 de daño
4. **Aplicación:** La mejora se aplica inmediatamente al iniciar el combate

### Tipos de Enemigos

| Enemigo  | Vida (HP) | Daño  | Descripción |
|----------|-----------|-------|-------------|
| Slime    | 30        | 2.5   | Enemigo básico |
| Skeleton | 60        | 6.0   | Enemigo ágil |
| Reaper   | 150       | 8.5   | Enemigo tanque |
| Warlock  | 200       | 12.0  | Boss final |

### Condiciones de Victoria/Derrota

- **Victoria:** Derrotar al Warlock en el piso 10
- **Derrota:** HP del jugador llega a 0 o menos
- **Progresión:** Derrotar todos los enemigos de un piso desbloquea los siguientes

---

## Conceptos de Programación Funcional

### 1. Funciones Puras
La mayoría de las funciones del juego son puras:
```haskell
createPlayer :: CharacterClass -> Player
createEnemy :: EnemyClass -> Enemy
getPlayerSprite :: GameImages -> CharacterClass -> Picture
```

### 2. Inmutabilidad
Los datos nunca se modifican directamente:
```haskell
-- En lugar de: player.health = player.health - 10
-- Se hace:
player { playerHealth = playerHealth player - 10 }
```

### 3. Pattern Matching
Usado extensivamente para control de flujo:
```haskell
createPlayer Warrior = Player { playerClass = Warrior, playerHealth = 100, playerDamage = 5.0 }
createPlayer Tank = Player { playerClass = Tank, playerHealth = 150, playerDamage = 1.5 }
createPlayer Rogue = Player { playerClass = Rogue, playerHealth = 80, playerDamage = 3.5 }
```

### 4. Tipos Algebraicos de Datos (ADTs)
```haskell
data CharacterClass = Warrior | Tank | Rogue
data EnemyClass = Slime | Reaper | Skeleton | Warlock
data GameScene = MainMenu | ClassSelection | InGame | SelectLevel | ...
```

### 5. Funciones de Orden Superior
```haskell
-- Usando zipWith para renderizar múltiples elementos
zipWith (\i option -> renderOption i option) [0..] options

-- Usando foldl para aplicar daño de múltiples enemigos
updatedPlayer = foldl applyEnemyDamage player enemies

-- Usando filter para remover enemigos muertos
aliveEnemies = filter (\e -> enemyHealth e > 0) enemies
```

### 6. Composición de Funciones
```haskell
-- Composición de transformaciones
translate x y $ scale s s $ color c $ sprite
```

### 7. Evaluación Lazy
Haskell solo evalúa lo necesario, permitiendo estructuras infinitas:
```haskell
-- Lista infinita de posiciones (solo se evalúan las necesarias)
positions = [(x, y) | x <- [0..], y <- [0..]]
```

---

## Estructura de Archivos

```
paradigmas-haski/
├── Main.hs                 # Módulo principal (interfaz gráfica)
├── Game.hs                 # Módulo de lógica del juego
├── Makefile                # Script de compilación
├── README.md               # Este archivo
└── img/                    # Recursos gráficos
    ├── entry.bmp           # Fondo del menú principal
    ├── niveles.bmp         # Fondo de selección de niveles
    ├── arena.bmp           # Fondo de combate
    ├── moai.bmp            # Fondo del pasillo de bendiciones
    ├── fondo_final.bmp     # Fondo de victoria/derrota
    ├── Warrior.bmp         # Sprite del Warrior
    ├── tank.bmp            # Sprite del Tank
    ├── Rogue.bmp           # Sprite del Rogue
    ├── slime.bmp           # Sprite del Slime
    ├── skeleton.bmp        # Sprite del Skeleton
    ├── reaper.bmp          # Sprite del Reaper
    └── warlock.bmp         # Sprite del Warlock (Boss)
```

---

## Controles del Juego

### Navegación en Menús
- **Flechas Arriba/Abajo:** Navegar opciones
- **Enter:** Confirmar selección
- **ESC:** Volver al menú anterior

### En el Pasillo (Corridor)
- **WASD / Flechas:** Mover al personaje
- **Enter:** Activar bendición / Confirmar mejora

### En Combate
- **Flechas Arriba/Abajo:** Seleccionar acción
- **Enter:** Ejecutar acción seleccionada

---

## Autores

- **Benjamin Uribe**
- **Marcelo Rojas**
- **Elias Ojeda**
- **Leonardo Moreno**
- **Alann Kahler**

---

## Conclusiones

Este proyecto demuestra cómo los conceptos de **programación funcional** pueden aplicarse para crear un juego interactivo completo. El uso de la **mónada State** permite gestionar el estado mutable de forma elegante y funcional, manteniendo la pureza de las funciones y facilitando el razonamiento sobre el código.

Las principales lecciones aprendidas incluyen:
1. La mónada State simplifica la gestión de estado en programas funcionales
2. La inmutabilidad y funciones puras hacen el código más predecible y testeable
3. Los tipos algebraicos y pattern matching proporcionan código seguro y expresivo
4. La composición de funciones permite construir sistemas complejos desde piezas simples

---

**Universidad Austral de Chile**  
**INFO188 - Programación en paradigmas funcional y paralelo**  
**2025**



