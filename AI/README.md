# 🚀 TripTalk-ai  
**Real-time Location-Based AI Guide App**

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)  
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue.svg)](https://github.com/KimGiheung/TripTalk-ai)  

---

## 🎯 Overview  
TripTalk-ai is a mobile + cloud application that delivers an intelligent travel-guide experience by combining real‐time GPS location data, automatic speech recognition (ASR), large language model (LLM) responses, and text-to-speech (TTS) output.  
With TripTalk-ai, users can simply speak about their surroundings and receive **context-aware, conversational guidance** while exploring.



---

## ✨ Key Features  
- **📍 Real-time Location Detection**  
  Continuously monitors user’s GPS and identifies current point of interest (POI).  
- **🎙 Automatic Speech Recognition (ASR)**  
  Users speak freely (e.g., “What’s this building?”), and the system transcribes speech in real time.  
- **🧠 Large Language Model Interaction**  
  The transcribed text + location/context are sent to an LLM (e.g., GPT-4) to generate tailored responses.  
- **🔊 Text-to-Speech (TTS) Output**  
  The LLM response is converted into natural-sounding audio for a hands-free experience.  
- **🔄 Intelligent Dialogue Flow**  
  Supports follow-up questions and dynamic interaction (e.g., “Any cafés nearby?” → “What about dessert?”).  
- **☁️ Cloud-Based Architecture**  
  Back-end handles STT, LLM integration, TTS, and location-based context, front-end optimized for mobile UX.

---

## 🧩 Why TripTalk-ai?  
Most travel apps rely on static content. TripTalk-ai is dynamic, conversational and personalized:  
- Adapts to your exact **location + momentary need**.  
- Enables **natural speech interaction**, not just taps.  
- Delivers **rich contextual responses** via location + LLM knowledge.  
- Supports **hands-free usage**, perfect for walking tours or outdoor travel.

---

## 🏗 Architecture & Workflow  
1. User opens the app & grants **location + microphone permissions**.  
2. Front-end captures geolocation and listens to user speech.  
3. Speech → STT module → text.  
4. Text + location (+ optional POI DB) → LLM module.  
5. LLM generates a response → TTS module.  
6. Audio is played back; UI updates with recommended POIs, map markers, or actions.  
7. User moves or asks follow-up; system loops dynamically.


::contentReference[oaicite:1]{index=1}


---

## 🛠 Technology Stack  
| Component       | Technology / Tool                          |
|----------------|-------------------------------------------|
| Front-end      | Flutter (Android/iOS)                     |
| Back-end       | Python (FastAPI / Flask) or Node.js       |
| STT            | OpenAI Whisper API or Google Speech-to-Text |
| LLM            | OpenAI GPT-4 API                           |
| TTS            | OpenAI `tts-1` model with “alloy” voice   |
| Location/POI   | Google Maps API / OpenStreetMap            |
| Cloud Infra    | Firebase Storage, Cloud Functions, Firestore |

---

## 🚀 Getting Started (Developer)  
