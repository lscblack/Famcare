# **FamCare - Family Healthcare Management App**  

![FamCare Logo](https://github.com/user-attachments/assets/a120c43e-7ecb-4c15-b342-302dc07052d2)
*The **FamCare** app is a family health management platform designed to simplify the coordination of caregiving tasks, medication schedules, and health records. The app utilizes **Flutter** for the frontend, **FastAPI** for the backend, **Firebase** for authentication and database management, and **Machine Learning algorithms** for predictive features, ensuring a seamless user experience for family health management.*  

---

## **📌 Table of Contents**  
1. [Features](#-features)  
2. [Tech Stack](#-tech-stack)  
3. [Prerequisites](#-prerequisites)  
4. [Installation & Setup](#-installation--setup)  
5. [Running the App](#-running-the-app)  
6. [Testing](#-testing)  
7. [Project Structure](#-project-structure)  
8. [Screenshots](#-screenshots)  
9. [Contributing](#-contributing)  

---

## **✨ Features**  
✅ **Shared Medication Management** – Real-time tracking with customizable reminders.  
✅ **Family Collaboration** – In-app chat, task delegation, and shared calendar.  
✅ **Centralized Health Records** – Securely store prescriptions, lab reports, and logs.  
✅ **Emergency SOS** – Instant alerts to family & emergency contacts.  
✅ **Role-Based Access** – Primary caregivers vs. family members.  
✅ **Cross-Platform** – Works on Android, iOS, and web.  

---

## **🛠 Tech Stack**  
- **Frontend**: Flutter (Dart)  
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)  
- **State Management**: BLoC + Cubit  
- **APIs**: Google Maps, OpenRouteServices  
- **Testing**: Unit, Widget, Integration Tests  
- **Tools**: Figma (UI/UX), VS Code, Android Studio  

---

## **📋 Prerequisites**  
Before running the app, ensure you have:  
- **Flutter SDK** (v3.0+)  
- **Firebase Account** (for backend setup)  
- **Google Maps API Key** (optional, for navigation)  
- **Android Studio / Xcode** (for emulators)  

---

## **⚙ Installation & Setup**  

### **1. Clone the Repository**  
```bash
git clone [https://github.com/your-repo/famcare.git](https://github.com/lscblack/Famcare.git)
cd client
```

### **2. Install Dependencies**  
```bash
flutter pub get
```

### **3. Firebase Setup**  
1. **Create a Firebase Project** at [Firebase Console](https://console.firebase.google.com/).  
2. **Enable Authentication** (Email/Password).  
3. **Set Up Firestore Database** with these collections:  
   - `users`, `families`, `medications`, `emergencyAlerts`.  
4. **Download `google-services.json` (Android) & `GoogleService-Info.plist` (iOS)** and place them in:  
   - Android: `android/app/`  
   - iOS: `ios/Runner/`  

### **4. Configure Google Maps (Optional)**  
- Get an API key from [Google Cloud Console](https://cloud.google.com/maps-platform/).  
- Add it in:  
  - Android: `android/app/src/main/AndroidManifest.xml`  
  - iOS: `ios/Runner/AppDelegate.swift`  

---

## **🚀 Running the App**  
### **Android**  
```bash
flutter run -v
```
*(Ensure an emulator is running or a device is connected via USB.)*  

### **iOS**  
```bash
flutter run --release
```
*(Requires Xcode for simulator/device deployment.)*  

### **Web**  
```bash
flutter run -d chrome
```

---

## **🧪 Testing**  
Run tests to ensure functionality:  
```bash
# Unit Tests
flutter test test/unit/

# Widget Tests
flutter test test/widget/

# Integration Tests
flutter test test/integration/
```

---

## **📂 Project Structure**  
```
lib/  
├── Splash/
├── Widgets/
├── models/
├── providers/
├── screens/
├── services/
└── main.dart           # App entry point  
```

---

## **📸 Screenshots**  
| Dashboard | Medication | Emergency SOS |  
|-----------|-------------------|--------------|  
| ![Homepage](https://github.com/user-attachments/assets/1b3d654e-b804-4b22-aa88-7d5775f40215) | ![Medication](https://github.com/user-attachments/assets/5455ba8b-faa1-44ee-b459-07672493fdcf) | ![Emergency Assistance (SOS Feature)](https://github.com/user-attachments/assets/cb59b9d8-476e-4a6b-bbdd-93cab8db5267) |  

---

## **🤝 Contributing**  
We welcome contributions! Follow these steps:  
1. Fork the repository.  
2. Create a new branch (`git checkout -b feature/your-feature`).  
3. Commit changes (`git commit -m 'Add feature'`).  
4. Push to the branch (`git push origin feature/your-feature`).  
5. Open a **Pull Request**.  

---

## **📡 Download APK**  
[🔗 Download FamCare APK](https://drive.google.com/your-apk-link)  

---

**💡 Members**  
##### Alain Muhirwa Michael
##### Loue Sauveur Christian
##### Lesly Ndizeye
##### Pendo Vestine
##### Kosisochukwu Okeke
##### Daniel Iryivuze
--- 

### **🔗 Additional Links**  
- [Figma Prototype](https://www.figma.com/proto/69gRIbFXspRkfTjQeObwWe/FamCare?node-id=2074-5558&p=f&t=zAUpeARgFFfQl2R9-1&scaling=scale-down&content-scaling=fixed&page-id=0%3A1&starting-point-node-id=2074%3A5558&show-proto-sidebar=1)  
- [Firebase Setup Guide](https://firebase.google.com/docs/build?_gl=1*1guxtey*_up*MQ..&gclid=CjwKCAjwwLO_BhB2EiwAx2e-3zHG2wYT-frJ7mlH-WZdJDBPkld-hhylglqV9G4nlEvjgZOWVIfinBoCSSgQAvD_BwE&gclsrc=aw.ds)  
- [Flutter Documentation](https://flutter.dev/docs)  

--- 

## **💡 Why FamCare?**  
> *"My sister and I care for our mom with Alzheimer’s. FamCare cut our missed doses by 80% and eliminated frantic ‘Did you give Mom her pills?’ texts."*  
> — **Sarah K., Primary Caregiver**  

**Build. Test. Empower.** Join us in redefining family caregiving.  

--- 
