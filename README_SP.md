![AwakeBuddy Logo](Assets/app.png)

# AwakeBuddy

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/montesito/awake-buddy)](https://github.com/montesito/awake-buddy/releases)
[![GitHub license](https://img.shields.io/github/license/montesito/awake-buddy)](https://github.com/montesito/awake-buddy/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/montesito/awake-buddy)](https://github.com/montesito/awake-buddy/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/montesito/awake-buddy)](https://github.com/montesito/awake-buddy/network)


**Versión 1.0** | [🇺🇸 Read in English](README.md)

> [!NOTA]
> Esta aplicación está diseñada exclusivamente para **entornos Windows**. Ha sido ampliamente probada en **Windows 11**.

*Evita que tu computadora entre en suspensión... con estilo.*

---

**Una utilidad de nivel profesional diseñada para mantener la actividad del sistema durante flujos de trabajo críticos.**

AwakeBuddy aprovecha una **Arquitectura Nativa de Windows**, construida completamente en PowerShell y Windows Presentation Foundation (WPF). Este enfoque limpio elimina la necesidad de frameworks externos pesados (como Electron), resultando en una aplicación que es:

- **Ultra-Ligera**: Mínimo consumo de memoria y CPU.
- **Libre de Dependencias**: Se ejecuta nativamente en cualquier entorno moderno de Windows 10/11.
- **Segura**: Código fuente transparente sin binarios ocultos.

![Demo de la Aplicación](Media/Images/awakeBuddy-Off.png)
*Figura 1: OFF La interfaz minimalista de tema oscuro.*

![Demo de la Aplicación](Media/Images/awakeBuddy-On.png)
*Figura 2: ON La interfaz minimalista de tema oscuro.*

## Capacidades Principales
*   **Mantenimiento Inteligente de Estado**: Simula eventos de entrada `ScrollLock` para prevenir los temporizadores de suspensión del sistema operativo sin interferir con el flujo de trabajo del usuario.
*   **Ejecución Asíncrona**: La lógica central opera en un hilo de CPU aislado (Job), asegurando que la interfaz de usuario permanezca perfectamente receptiva.
*   **Interfaz Nativa WPF**: Una interfaz de usuario totalmente basada en vectores y consciente de altos DPI que escala perfectamente en cualquier pantalla.
*   **Núcleo Puro de PowerShell**: Toda la lógica de la aplicación es abierta e inspeccionable, demostrando el poder de la automatización nativa de Windows.

## Instalación y Uso

### Opción 1: Ejecutable (Recomendado)
**`AwakeBuddy.exe`**
- Icono Personalizado.
- Se ejecuta silenciosamente (sin ventana de terminal).
- Solamente hacer doble click en el archivo AwakeBuddy.exe

### Opción 2: Script Lanzador (Alternativa)
**`Launch.vbs`**
- Ejecuta el script de PowerShell silenciosamente.
- Útil si deseas modificar el código fuente.

### Opción 3: Inicio Manual
Ejecutar a través de terminal PowerShell:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\AwakeBuddy.ps1
```

## Estructura del Proyecto
La solución está modularizada para facilitar el mantenimiento:

*   **`AwakeBuddy.ps1`**: Inicializador y punto de entrada.
*   **`Src/UI/`**: Definiciones XAML para `MainWindow` (Diseño) y `Styles` (Temas).
*   **`Src/Logic/`**: Lógica de trabajo en segundo plano para la simulación de actividad.
*   **`Assets/`**: Recursos estáticos.

## Desarrollo
Este proyecto utiliza una estructura modular de PowerShell + XAML.
- **Compilación**: No se requiere compilación para los scripts. Para regenerar el envoltorio ejecutable, usa el compilador de C# (`csc.exe`).

## Descarga
**Obtén la última versión:**
[**Descargar AwakeBuddy.exe**](Bin/AwakeBuddy.exe)
*(Este ejecutable se encuentra en la carpeta `Bin/` y ejecuta la utilidad sin instalación.)*

> [!WARNING]
> **Alerta de Seguridad de Descarga**: Debido a que este es un archivo `.exe` sin firmar, su sistema o navegador puede marcarlo como "sospechoso".
> **Es seguro.** Si decide descargarlo, por favor confíe en el archivo, siga los pasos para "Conservar" o "Ejecutar de todas formas", y **permita que su antivirus lo escanee** para verificar su seguridad.

## Colaboración
**¿Te gusta esta herramienta?**
¡Las contribuciones, problemas y solicitudes de características son bienvenidas!
Siéntete libre de revisar el [repositorio](https://github.com/montesito/awake-buddy) si quieres contribuir.
*¡Dale una ⭐️ si este proyecto te ayudó!*

## Licencia
**Licencia MIT**
Copyright (c) 2025 Montesito.
Por la presente se otorga permiso, sin cargo, a cualquier persona que obtenga una copia de este software y los archivos de documentación asociados.
Consulta el archivo [LICENSE](LICENSE) para más detalles.

## seguridad y Descargo de Responsabilidad
**Construido con Recursos Nativos.**
Este software está diseñado para ser lo más seguro y discreto posible. Depende completamente de protocolos nativos de Windows (PowerShell, .NET Framework) y **no contiene binarios externos, controladores ni dependencias ocultas**. El código fuente es transparente y abierto para inspección.

**Responsabilidad del Usuario**
Sin embargo, al usar este software, reconoces que:
1.  Prevenir el modo de suspensión puede agotar la batería rápidamente en computadoras portátiles.
2.  Prevenir la suspensión mientras un dispositivo está en un espacio cerrado (como una bolsa) puede causar sobrecalentamiento.
3.  **El Desarrollador NO es responsable** de ningún daño de hardware, pérdida de datos u otros problemas resultantes del uso o mal uso de esta herramienta. Úsalo estrictamente bajo tu propia discreción.

## Antivirus y Seguridad
Esta aplicación está construida completamente con **Recursos Nativos de Windows** (PowerShell y .NET), haciéndola transparente y segura.

**Te animamos a dejar que tu Antivirus escanee el archivo.**
Debido a que esta herramienta es una utilidad personalizada y no firmada que simula presiones de teclas, algún software de seguridad puede marcarla inicialmente como "Desconocida".
1.  **Deja que Escanee**: Permite que tu Antivirus realice un escaneo profundo. Verificará que no hay código malicioso.
2.  **Código Abierto**: Puedes revisar el código fuente completo en este repositorio para ver exactamente cómo funciona.
3.  **Falsos Positivos**: Si aparece una advertencia genérica (común con software nuevo y no firmado), puedes proceder con confianza sabiendo que el código es transparente.

---
© 2025 Montesito
