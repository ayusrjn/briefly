# Briefly

The Private, On-Device AI News Summarizer.

Briefly reads, cleans, and summarizes news articles entirely on-device using the Gemma-3 model. No cloud APIs, no subscriptions, and no data egress.

![Briefly App Screenshots](https://raw.githubusercontent.com/ayusrjn/briefly/refs/heads/main/assets/readme.png)

Contents
- Features
- Architecture
- Installation
- Model configuration
- Project structure
- Troubleshooting

---

## Features

- Local inference: on-device model execution via the Cactus SDK (NPU/GPU/Metal/Vulkan).
- Privacy: no telemetry or content leaves the device.
- Polished UI: glassmorphism, gradients, and reactive animations.
- System integration: deep links and Android Share Sheet support.
- Text-to-speech: integrated neural TTS for audio briefings.
- Smart scraping: strips ads, trackers, and irrelevant HTML before summarization.

---

## Architecture

Briefly uses a service-oriented architecture focused on performance and predictable state management.

### Stack
- Framework: Flutter (Dart 3.0+)
- State management: Provider
- Inference engine: Cactus SDK
- UI: Custom glassmorphism components
- Build: Gradle (Java 17)

### Data flow
1. Input: user pastes a URL or shares it to the app.  
2. Scraping: `ScraperService` fetches HTML and sanitizes (removes `<script>`, `<nav>`, `<footer>`, etc.).  
3. Orchestration: `SummaryProvider` state machine (Idle → Scraping → Thinking → Success).  
4. Inference: `CactusAIService` loads the Gemma-3 model (if needed) and streams prompts locally.  
5. Rendering: parsed markdown is displayed in a summary card; TTS is available.

---
## Inference Engine

I have used Cactus SDK to run the language model on the mobile. Visit them here [Cactus](https://cactuscompute.com/)
Cactus Github Repo [Cactus SDK](https://github.com/cactus-compute/cactus)

## Installation

### Prerequisites
- Flutter SDK (latest stable, 3.22+ recommended)
- Android Studio with Java 17 support
- Physical Android device recommended for NPU/GPU access

### Steps
1. Clone the repository
```bash
git clone https://github.com/ayusrjn/briefly.git
cd briefly
```

2. Install dependencies
```bash
flutter pub get
```

3. Verify environment
```bash
flutter doctor -v
# Confirm Java 17 under Android toolchain
```

4. Run on device
```bash
flutter run
```

Note: On first launch the app downloads the Gemma-3 model (approximately 178 MB). Keep the app open until the download completes.

---

## Model configuration

Models and quantizations are configured in `lib/services/ai_service.dart`.

Example options:
- `gemma3-270m` — ~200 MB, faster, lower quality — suitable for older devices or testing  
- `gemma3-1b-it` — ~850 MB, balanced speed and quality — recommended for modern phones

To change the model, update the `_modelSlug` constant:
```dart
static const String _modelSlug = "gemma3-270m";   // speed
// or
static const String _modelSlug = "gemma3-1b"; // quality
```
Reinstall the app to trigger a fresh model download.

---

## Project structure

lib/
```
├── main.dart                  # App entry & theme
├── providers/
│   └── summary_provider.dart  # State & business logic
├── screens/
│   ├── download_screen.dart   # First-run downloader UI
│   └── home_screen.dart       # Main dashboard
├── services/
│   ├── ai_service.dart        # Cactus/Gemma interface
│   └── scraper_service.dart   # HTTP scraping & sanitization
└── widgets/
    ├── article_skeleton.dart  # Loading animation
    └── summary_card.dart      # Markdown renderer & TTS
```

---

