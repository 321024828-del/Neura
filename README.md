# NEURA 🧠🌱
**Tu compañero digital para el cuidado de la salud mental.**

![Swift](https://img.shields.io/badge/Swift-5.5_or_newer-F05138?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue?style=flat-square&logo=swift)
![iOS](https://img.shields.io/badge/iOS-16.0%2B-black?style=flat-square&logo=apple)

NEURA es una aplicación nativa para iOS construida con SwiftUI, diseñada específicamente para ayudar a los estudiantes universitarios a gestionar su estrés, rastrear sus hábitos de descanso y encontrar un espacio seguro para expresar sus emociones. 

## ✨ Características Principales

* **🔐 Onboarding y Perfiles:** Flujo completo de registro e inicio de sesión con persistencia local.
* **🐶 Compañero Virtual:** Elige un avatar (Perrito o Gatito) que te acompañará. Alimenta y cuida a tu mascota completando hábitos saludables.
* **📊 Tracker de Sueño Avanzado:** Registra tus horas de sueño y visualiza tu tendencia de los últimos 7 días mediante gráficos dinámicos construidos con `Swift Charts`. Incluye alertas reactivas basadas en la calidad de tu descanso.
* **📅 Calendario de Emociones:** Un tracker visual para registrar tu estado de ánimo diario mediante emojis, guardando un historial mensual.
* **✨ Afirmaciones Diarias:** Pantalla con animaciones fluidas (Glassmorphism) que te entrega frases motivacionales aleatorias para empezar bien el día.
* **🤖 Asistente Conversacional Neura:** Un chat interactivo que analiza intenciones clave (ansiedad, estrés, depresión). 
    * *Memoria de contexto:* Capacidad de hilar conversaciones cortas (ej. ofrecer un ejercicio de respiración y esperar respuesta).
    * *Voz integrada:* Lectura de respuestas en voz alta usando `AVSpeechSynthesizer`.
* **🆘 Centro de Ayuda:** Acceso rápido a contactos de emergencia (incluyendo atención psicológica universitaria y el 911) y guías rápidas de relajación.

## 🛠️ Tecnologías Utilizadas

* **SwiftUI:** Para toda la interfaz de usuario, animaciones (springs, gradients) y transiciones.
* **Swift Charts:** Renderizado de la gráfica de barras del historial de sueño.
* **AVFoundation:** Uso de `AVSpeechSynthesizer` para dotar de voz al asistente virtual.
* **@AppStorage & Codable:** Persistencia de datos ligera (JSON) para mantener la sesión del usuario, el historial de sueño, las emociones y los puntos de cuidado del avatar.

## 🚀 Instalación y Ejecución

1. Clona este repositorio:
   ```bash
   git clone [https://github.com/tu-usuario/NEURA.git](https://github.com/tu-usuario/NEURA.git)
Abre el archivo del proyecto en Xcode (requiere Xcode 14 o superior para soportar Charts).

Selecciona un simulador (ej. iPhone 15 Pro) o tu dispositivo físico.

Presiona Cmd + R para compilar y ejecutar.

📱 Capturas de Pantalla
(Nota: Agrega aquí capturas de pantalla de la app corriendo para que tu README sea más visual)

Pantalla de Onboarding | Gráfica de Sueño | Asistente Neura | Cuidado del Avatar

🧠 Arquitectura y Lógica Destacada
El enrutamiento de la aplicación se maneja a nivel raíz en ContentView, reaccionando dinámicamente al estado del StudentProfile guardado en el dispositivo. Esto elimina problemas clásicos de navegación apilada en SwiftUI y permite transiciones asimétricas limpias entre el Onboarding, la selección de Avatar y el Home.

El Asistente utiliza una máquina de estados sencilla (ConversationContext) para recordar el hilo de la conversación y ofrecer intervenciones de crisis o ejercicios de respiración basados en detección de palabras clave.

Desarrollado con 🩵 por JuniorHLovers. Estudiante de Matemáticas Aplicadas y Computación (MAC) - UNAM FES Acatlán.
