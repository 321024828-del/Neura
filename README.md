# NEURA
**Tu compañero digital para el cuidado de la salud mental.**

![Swift](https://img.shields.io/badge/Swift-5.5_or_newer-F05138?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?style=flat-square&logo=swift)
![iOS](https://img.shields.io/badge/iOS-16.0%2B-black?style=flat-square&logo=appledar) 
Los estudiantes universitarios a gestionar su estrés, rastrear sus hábitos de descanso y encontrar un espacio seguro para expresar sus emociones. 

## Características Principales

* ** Gamificación con Avatar Virtual:** Al registrarse, el usuario elige un compañero (Perrito o Gatito). Completar actividades saludables permite cuidar y darle regalos al avatar.
* ** Tracker de Sueño Inteligente:** Permite registrar la calidad y horas de sueño diarias. Incluye una visualización de tendencias de los últimos 7 días usando `Swift Charts` y alertas reactivas si el descanso es deficiente.
* **Calendario de Emociones:** Un registro visual del estado de ánimo diario mediante una interfaz limpia y persistencia mensual.
* **Asistente "Neura" Integrado:** Un diario conversacional que utiliza una máquina de estados para mantener el contexto. Detecta palabras clave (estrés, ansiedad, crisis) para ofrecer ejercicios de respiración, técnicas de estudio o contactos de emergencia. Integra `AVSpeechSynthesizer` para leer las respuestas en voz alta.
* ** Afirmaciones Diarias:** Generador de frases motivacionales con un diseño inmersivo (Glassmorphism) y fondos animados.
* **Centro de Emergencia:** Acceso directo mediante esquemas de URL (`tel://`) a líneas de ayuda, incluyendo atención psicológica.

---

## Tecnologías y Frameworks Utilizados

* **Interfaz de Usuario:** `SwiftUI` (uso intensivo de animaciones fluidas, `springs`, `LinearGradient` dinámicos y modificadores personalizados como `BounceButtonStyle`).
* **Visualización de Datos:** `Charts` (Framework nativo de Apple) para generar gráficas de barras con `BarMark` y líneas de meta con `RuleMark`.
* **Síntesis de Voz:** `AVFoundation` implementado en el asistente para accesibilidad auditiva.
* **Persistencia Local:** `@AppStorage` combinado con el protocolo `Codable` y `JSONEncoder/JSONDecoder` para guardar modelos complejos (Perfil, Historial de Sueño, Emociones) directamente en `UserDefaults` de forma ligera.

---

##  Arquitectura y Documentación del Código

El proyecto sigue una arquitectura reactiva basada en los paradigmas de SwiftUI:

### Enrutamiento Raíz (`ContentView`)
La aplicación no utiliza el típico apilamiento infinito de vistas. En su lugar, `ContentView` actúa como un enrutador de estado (State-driven routing):
1. Si no hay perfil en memoria ➔ Muestra el flujo de **Onboarding/Registro**.
2. Si hay perfil pero no tiene avatar ➔ Muestra **AvatarSelectionView**.
3. Si el perfil está completo ➔ Muestra el dashboard principal (**HomeAfterProfileView**).

### Modelos de Datos (`Models`)
* `StudentProfile`: Estructura principal del usuario.
* `SleepEntry` & `Mood`: Modelos identificables (`Identifiable`) para alimentar las listas y gráficas.
* `AvatarChoice`: Enum autodescriptivo que maneja la lógica visual del compañero (íconos de SF Symbols y títulos).

### Máquina de Estados del Asistente
El `AssistantJournalView` utiliza un enumerador `ConversationContext` (`.neutral`, `.offeredBreathing`, `.offeredCrisisHelp`) para "recordar" la intención anterior del sistema y poder procesar respuestas afirmativas o negativas de manera natural antes de seguir analizando nuevas palabras clave.

---

El Asistente utiliza una máquina de estados sencilla (ConversationContext) para recordar el hilo de la conversación y ofrecer intervenciones de crisis o ejercicios de respiración basados en detección de palabras clave.

Desarrollado con 🩵 por JuniorHLovers. Estudiante de Matemáticas Aplicadas y Computación (MAC) - UNAM FES Acatlán.
