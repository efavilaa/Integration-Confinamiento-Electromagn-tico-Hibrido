# Confinamiento de Partículas en un Toroide

## Descripción

Este proyecto simula el confinamiento de una partícula cargada dentro de un reactor toroidal utilizando tres mecanismos físicos complementarios:

* **Atrapamiento eléctrico (Ley de Coulomb)** mediante cargas distribuidas alrededor del toroide.
* **Confinamiento magnético pasivo (Radio de Larmor)** mediante un campo magnético uniforme.
* **Control activo (Ley de Ampère y Biot-Savart)** que detecta cuando la partícula se aproxima a los límites de seguridad y aumenta la corriente en cables cercanos para redirigirla hacia el centro.

La simulación permite comparar diferentes métodos de integración numérica y visualizar en tiempo real la trayectoria de la partícula.

---

## Métodos de integración disponibles

1. Euler
2. Runge-Kutta de segundo orden (RK2)
3. Runge-Kutta de cuarto orden (RK4)

---

## Características principales

* Simulación bidimensional de una partícula cargada.
* Distribución circular de cargas eléctricas para generar fuerzas de repulsión.
* Campo magnético uniforme para producir movimiento ciclotrón.
* Sistema de contención activa basado en múltiples cables con corrientes alternadas.
* Activación automática del sistema de rescate cuando la partícula supera un radio de seguridad.
* Visualización animada de la trayectoria.
* Indicadores visuales de los cables que participan en la contención activa.

---

## Conceptos físicos implementados

* Ley de Coulomb
* Fuerza de Lorentz
* Radio de Larmor
* Ley de Ampère
* Ley de Biot-Savart
* Métodos numéricos de integración para ecuaciones diferenciales

---

## Ejecución

Al iniciar el programa se solicitará seleccionar un método de integración:

```matlab
Métodos de integración:
  1. Euler
  2. Runge-Kutta 2do orden
  3. Runge-Kutta 4do orden
```

Después de la selección, la simulación comenzará automáticamente mostrando la trayectoria de la partícula y el comportamiento del sistema de confinamiento.


