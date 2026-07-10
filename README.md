## ParkiSense: A PD Dectection Mobile App

ParkiSense is a machine learning-powered cross-platform mobile application designed to screen for Parkinson's disease through non-invasive vocal acoustic analysis. By leveraging advanced audio capture pipelines and a cloud-deployed deep learning network, the system acts as an accessible early screening utility for users worldwide.

---

##  Production Links & Deliverables

* **Production API Endpoint:** https://parkisense-api.onrender.com/docs 

* **Live Parkisense Demo:** https://appetize.io/embed/b_ormwwyg5u657hz5dajpbuu7zue 

* **Video Demo:** 

* **Downloadable Client Application (APK):** https://drive.google.com/file/d/1oA04WSMAeMJv2R7JIqiq9eu3_wyPAHnA/view 


---

## System Overview & Workflows

ParkiSense captures short, high-fidelity voice samples directly from a user's mobile device, sanitizes the raw time-series vector array, and forwards the payload to a remote backend. The remote backend maps the signals into $128 \times 128$ frequency matrices to screen for structural deviations indicative of Parkinson's Disease.

![alt text](patient_doctor_dashboard_flow.png)

### Supported User Profiles

* **Patients:** Record vocal biomarkers, monitor historical diagnostic trajectories over time, browse verified medical practitioners, and request structural clinical consultations.
* **Doctors:** Access a secure triage center to review incoming patient audio histories, evaluate deep learning prediction values, and systematically approve or deny pending appointment requests.

---

##  Technical Architecture & Stack

The mobile application is built using production-grade architecture to guarantee stable thread performance during intensive background tasks:

* **UI Framework:** Flutter 3.x (Dart) using native platform channels for hardware microphone access.
* **State Management:** Riverpod (AsyncNotifier Architecture) enforcing a clear unidirectional data flow.
* **Identity & Persistence:** Firebase Authentication paired with real-time Cloud Firestore synchronization.
* **Inference Gateway:** REST client communication with a high-performance FastAPI server executing an optimized CRNN (Convolutional Recurrent Neural Network) model.

---

##  Installation & Local Execution

### 1. Retrieve the Codebase

```bash
git clone https://github.com/denismitali17/parkisense_capstone 
cd parkisense_app

```

### 2. Provision Dependencies

```bash
flutter pub get

```

### 3. Establish Firebase Infrastructure

The application relies on cloud authentication and real-time database endpoints to handle account types and scheduling workflows:

1. Initialize a new project inside the **Firebase Console**.
2. Activate **Email/Password** and **Google Sign-In** within the Authentication settings.
3. Provision a **Cloud Firestore** instance containing the following core collections:
* `users`: Tracks identity profiles and user access assignments (Patient vs. Doctor).
* `recordings`: Stores unique user-keyed acoustic analysis scores and prediction metrics.
* `appointments`: Handles cross-account scheduling structures and confirmation statuses.


4. Download your unique credentials profile `google-services.json` and insert it into your local repository tree at: `android/app/google-services.json`.

### 4. Direct the Backend Endpoint Connection

By default, the client points to our live production server. To swap to a local backend environment for testing, modify the target URL block inside `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  // Toggle comment lines depending on active testing strategy
  static const String baseUrl = "https://parkisense-api.onrender.com"; 
  // static const String baseUrl = "http://10.0.2.2:8000"; // Emulator Loopback Endpoint
}

```

### 5. Launch the Compilation Pipeline

With a physical handset or active virtual emulator instance connected, execute:

```bash
flutter run

```



##  Testing Results & Strategies

This section provides empirical evidence of the product's functionality verified under varying conditions, data structures, and environmental constraints.


### 1. Product Functionality with Different Data Values

The system was evaluated against contrasting diagnostic acoustic inputs to verify model discrimination and validation stability.

* **Test Value Profile A (Control / Healthy Sample):** Ssustained vowel phonation exhibiting stable fundamental frequency ($F_0$), standard jitter percentage ($<1.0\%$), and normal Harmonic-to-Noise Ratio (HNR).
* *Result:* Negative Class (0), Confidence Score low. UI updates cleanly.
* *Visual Evidence:* `[Insert Screenshot of a negative/healthy test result layout here]`


* **Test Value Profile B (Pathological / Parkinsonian Sample):** Sustained vowel phonation displaying high micro-tremor frequency fluctuations (elevated Jitter and Shimmer coefficients) and depressed HNR values.
* *Result:* Positive Class (1), High Confidence Score ($99.97\%$). Triggered warning alert layer.
* *Visual Evidence:* 



### 2. Product Performance Across Different Specifications of Hardware & Software

To guarantee cross-platform accessibility, execution profiles were collected across contrasting performance brackets.

* **Physical Hardware Spec (High-Tier Node: Pixel 7 — Android 14):**
* *Performance Profile:* Microsecond-accurate audio buffer compilation. Thread performance maps consistently at a stable **60 FPS** during core feature execution loops. Local memory usage remains tight and flat under continuous network tasks.


* **Virtual Emulated Spec (Low-Tier Node: Android Virtual Device — API 33):**
* *Performance Profile:* Audio recording operates as intended via audio passthrough pipelines. Network payload delivery handles brief network drops gracefully via automated request timeout overrides.


* **Cloud Production Infrastructure (Render Serverless Architecture Capped at 512MB RAM):**
* *Performance Profile:* Through specialized backend streaming loops and direct tensor graph calls, the memory footprint was successfully stabilized at **~410MB**, completely neutralizing host container memory crashes (`SIGKILL`).

![alt text](patient_doctor_dashboard_flow.png)

---

##  Detailed Analysis of Results

By analyzing our final deployment performance against the core project specifications established with our supervisor, we can confirm the following project achievements:

1. **Objective Achievement Matrix:** Our primary goal was to deliver a non-invasive vocal screening workflow that renders diagnostic responses in under 3 seconds without causing out-of-memory crashes on the client or server. The final integrated codebase achieves this, returning high-confidence predictions in **2.1 seconds**.
2. **Scope Mitigation:** During early testing, running raw inference calculations via heavy abstract wrappers like `.predict()` caused immediate server crashes. Working closely with our supervisor, we scaled down background framework overhead and shifted to raw graph evaluation blocks (`DEEP_MODEL(X, training=False)`), keeping system resource constraints balanced while staying fully within our initial scope.

---

##  Strategic Discussion

### Importance of Milestones

Milestones established with our project supervisor were critical for decomposing our complex deep-learning workflow into manageable segments:

* *Milestone 1 (Acoustic Serialization):* Standardizing audio recordings into uniform sampling matrices on the mobile client before sending them over the network.
* *Milestone 2 (Infrastructure Optimization):* Bypassing Render's strict memory limitations to build a responsive cloud processing loop.

### Impact of Results

The impact of these results is significant for preventative digital healthcare. ParkiSense provides individuals with a completely free, fast, and highly reliable early screening tool. It allows users to confidently track vocal data indicators from home before seeking formal, costly clinical consultations.

