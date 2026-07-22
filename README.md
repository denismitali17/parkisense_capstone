<div align="center">

#  ParkiSense
### Parkinson's Disease Screening Through Voice

*A cross-platform mobile app that screens for Parkinson's disease using non-invasive vocal acoustic analysis.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Firebase](https://img.shields.io/badge/Auth%20%26%20DB-Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Render](https://img.shields.io/badge/Deployed%20on-Render-46E3B7?logo=render&logoColor=white)](https://render.com)
[![License](https://img.shields.io/badge/License-MIT-blue)](#)

[**Try the Live Demo**](https://appetize.io/embed/b_ormwwyg5u657hz5dajpbuu7zue) · [**API Docs**](https://parkisense-api.onrender.com/docs) · [**Download APK**](https://drive.google.com/file/d/1oA04WSMAeMJv2R7JIqiq9eu3_wyPAHnA/view)

</div>

---

ParkiSense captures a short, sustained vowel recording from the user's phone, sends it to a cloud-hosted deep learning model (Hybrid CRNN), and returns a Parkinson's risk screening result in about 2 seconds — no lab equipment or clinical visit required.

## Contents

- [Production Links](#-production-links--deliverables)
- [System Overview](#-system-overview)
- [Technical Architecture](#-technical-architecture--stack)
- [Getting Started](#-getting-started)
- [Testing Results](#-testing-results--strategies)
- [Analysis of Results](#-analysis-of-results)
- [Strategic Discussion](#-strategic-discussion)

---

##  Production Links & Deliverables

| Resource | Link |
|---|---|
|  Deployed web application| https://parkisens.netlify.app/ |
|  Production API (docs) | https://parkisense-api.onrender.com/docs |
|  Live demo (Appetize, no install needed) | https://appetize.io/embed/b_ormwwyg5u657hz5dajpbuu7zue |
|  Video  | https://www.youtube.com/watch?v=A1xcYNQBxTs |
|  Downloadable APK | https://drive.google.com/file/d/1oA04WSMAeMJv2R7JIqiq9eu3_wyPAHnA/view?usp=sharing |
|  Hugging Face Public Link | https://huggingface.co/spaces/denismitali/parkisense_space |


---

##  System Overview

ParkiSense captures a short, sustained vowel phonation directly from the user's device microphone, converts the raw waveform into a time-series vector, and sends it to a remote inference backend. The backend transforms the signal into a 128×128 log-mel spectrogram and feeds it through a CRNN classifier trained to detect acoustic biomarkers associated with Parkinson's disease.

<div align="center">
<img src="parkinsons-api/patient_doctor_dashboard_flow.png" alt="Patient/Doctor dashboard flow" width="700"/>
</div>

### User Roles

|  Patients |  Doctors |
|---|---|
| Record vocal samples for screening | Review incoming patient audio and prediction histories |
| View historical prediction trends over time | Approve or decline pending appointment requests |
| Browse verified medical practitioners | |
| Request clinical consultations | |

---

##  Technical Architecture & Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x (Dart), native platform channels for microphone access |
| State Management | Riverpod (`AsyncNotifier`), unidirectional data flow |
| Auth & Persistence | Firebase Authentication + Cloud Firestore (real-time sync) |
| Inference Gateway | FastAPI REST backend serving a CRNN model |
| Model Format | ONNX export for optimized inference |
| Deployment | Render (backend), 512MB RAM tier |

###  Predictive Model — M7CRNN

The core predictive engine is **M7CRNN (Model 7, Convolutional Recurrent Neural Network)**, the model currently deployed to the production API on Render.

| Metric | Score |
|---|---|
| Accuracy (validation) | **83.78%** |
| ROC-AUC (validation) | **86.01%** |

Evaluated against held-out validation data, M7CRNN generalizes well across both the spatial patterns (spectrogram structure) and temporal patterns (frame-to-frame variation) present in vocal biomarkers.

---

##  Getting Started

There are four ways to try ParkiSense, from zero setup to a full local build. Pick whichever fits what you need.

### Option A: Try it instantly in the browser (fastest, no install)

No emulator, no APK, nothing to configure. Just open the live demo:

 **https://appetize.io/embed/b_ormwwyg5u657hz5dajpbuu7zue**

This streams a real Android instance running ParkiSense straight from your browser. Best option for a quick look, or for a supervisor who just wants to click through the app without installing anything.

### Option B: Install the APK using BlueStacks (no physical Android device needed)

1. Download and install [BlueStacks](https://www.bluestacks.com/) on your Windows or macOS machine.
2. Open BlueStacks and let it finish setting up (first launch takes a minute or two).
3. Download the ParkiSense APK from the [Google Drive link](https://drive.google.com/file/d/1oA04WSMAeMJv2R7JIqiq9eu3_wyPAHnA/view).
4. Drag and drop the downloaded APK file onto the BlueStacks window, it installs automatically.
   - Alternatively, click the APK icon in the BlueStacks sidebar and browse to the downloaded file.
5. Launch **ParkiSense** from the BlueStacks home screen and sign up or log in.

### Option C: Install the APK on a physical Android device

1. Download the APK from the [Google Drive link](https://drive.google.com/file/d/1oA04WSMAeMJv2R7JIqiq9eu3_wyPAHnA/view?usp=sharing) onto your Android phone.
2. Open the downloaded file. If Android blocks the install, go to **Settings → Apps → Special app access → Install unknown apps**, select the app you downloaded with (e.g. Chrome or Files), and enable **Allow from this source**.
3. Return to the downloaded file and tap **Install**.
4. Open **ParkiSense** and sign up or log in.

> Both APK install paths (B and C) connect to the live production API by default, so no backend setup is required.

### Option D: Build and run from source

For development, or if you want to point the app at your own backend.

**1. Clone the repository**

```bash
git clone https://github.com/denismitali17/parkisense_capstone
cd parkisense_capstone/parkisense_app
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Set up Firebase**

The app relies on Firebase for authentication and real-time data sync.

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password** and **Google Sign-In** under Authentication.
3. Create a **Cloud Firestore** database with these collections:
   - `users` — identity profiles and role assignment (patient vs. doctor)
   - `recordings` — per-user acoustic scores and prediction metrics
   - `appointments` — scheduling and confirmation status between patients and doctors
4. Download `google-services.json` and place it at:
   ```
   android/app/google-services.json
   ```

**4. Point the app at a backend**

By default, the client points to the production API. To use a local backend during development, edit `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = "https://parkisense-api.onrender.com";
  // static const String baseUrl = "http://10.0.2.2:8000"; // Android emulator loopback
}
```

**5. Run the app**

Connect a physical device or start an emulator, then:

```bash
flutter run
```

---

##  Testing Results & Strategies

### Model behavior across contrasting inputs

| Sample Type | Description | Result |
|---|---|---|
|  Control / healthy | Sustained vowel phonation with stable fundamental frequency (F₀), jitter < 1.0%, normal HNR | Negative class (0), low confidence score |
|  Pathological / Parkinsonian | Elevated jitter and shimmer, depressed HNR, micro-tremor fluctuations | Positive class (1), 99.97% confidence, alert layer triggered |

*(Insert screenshots of both result screens here.)*

### Performance across hardware and infrastructure

| Environment | Observations |
|---|---|
|  Physical device — Pixel 7, Android 14 | Stable audio buffer capture; UI holds ~60 FPS during recording; memory usage stays flat under network load |
|  Emulator — AVD, API 33 | Audio passthrough works correctly; brief network drops handled gracefully via request timeouts |
|  Cloud backend — Render, 512MB RAM cap | Memory stabilized at ~410MB through streaming inference and direct tensor graph calls, avoiding container OOM kills (`SIGKILL`) |

---

##  Analysis of Results

Measured against the goals set with our supervisor:

1. **Latency & stability target.** Goal: return a diagnostic result in under 3 seconds without OOM crashes on client or server.  Achieved — end-to-end prediction latency is **2.1 seconds**.
2. **Memory-constrained inference.** Early versions using high-level `.predict()` calls crashed the Render instance under its 512MB limit. Switching to direct graph evaluation (`model(X, training=False)`) reduced overhead enough to stay within the memory budget while keeping the original model architecture intact.

---

##  Strategic Discussion

### Why milestones mattered

Breaking the project into supervised milestones kept a complex ML + mobile integration manageable:

- **Milestone 1: Acoustic serialization:** Standardize raw audio recordings into uniform sampling matrices on-device before transmission.
- **Milestone 2: Infrastructure optimization:** Work within Render's memory constraints to keep inference responsive.

### Impact

ParkiSense gives users a free, fast, and reliable early-screening tool they can use at home, a way to start monitoring vocal biomarkers before deciding whether a formal, in-person clinical evaluation is warranted.
