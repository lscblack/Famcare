---

# **FamCare – Family Healthcare Management**  

![FamCare Logo](https://github.com/user-attachments/assets/a120c43e-7ecb-4c15-b342-302dc07052d2)  
*The **FamCare** app is a family health management platform designed to simplify the coordination of caregiving tasks, medication schedules, and health records. The app utilizes **Flutter** for the frontend, **FastAPI** for the backend, **Firebase** for authentication and database management, and **Machine Learning algorithms** for predictive features, ensuring a seamless user experience for family health management.*  

---

## **📌 Table of Contents**  
1. [Features](#-features)  
2. [Tech Stack](#-tech-stack)  
3. [Prerequisites](#-prerequisites)  
4. [Installation](#-installation)  
5. [Firebase Setup](#-firebase-setup)  
6. [Google Maps](#-google-maps-optional)  
7. [Running the App](#-running-the-app)  
8. [Testing](#-testing)  
9. [Project Structure](#-project-structure)  
10. [Screenshots](#-screenshots)  
11. [Contributing](#-contributing)  
12. [Team](#-team)  

---

## **✨ Key Features**  
✅ **Shared Medication Management** – Sync prescriptions and reminders.  
✅ **Role-Based Access** – Primary caregivers vs. family members.  
✅ **Emergency SOS** – Instant alerts with location sharing.  
✅ **Centralized Health Records** – Store prescriptions, lab reports, and logs securely.  
✅ **Cross-Platform** – Android, iOS, and web support.  

---

## **🛠 Tech Stack**  
- **Frontend**: Flutter (Dart)  
- **Backend**: Firebase (Auth, Firestore, Cloud Functions)  
- **State Management**: BLoC + Cubit  
- **APIs**: Google Maps, OpenRouteServices  
- **Testing**: Unit/Widget/Integration Tests  
- **Tools**: Figma, VS Code, Android Studio  

---

## **📋 Prerequisites**  
- Flutter SDK (v3.0+)  
- Firebase account ([sign up here](https://console.firebase.google.com/))  
- Google Maps API key (optional)  

---

## **⚙ Installation**  
```bash
git clone https://github.com/lscblack/Famcare.git
cd client
flutter pub get
```

---

## **🔥 Firebase Setup**  
1. Enable **Email/Password Auth** in [Firebase Console](https://console.firebase.google.com/).  
2. Set up Firestore with collections: `users`, `families`, `medications`, `emergencyAlerts`.  
3. Download config files:  
   - Android: [`google-services.json`](https://firebase.google.com/docs/android/setup) → Place in `android/app/`  
   - iOS: [`GoogleService-Info.plist`](https://firebase.google.com/docs/ios/setup) → Place in `ios/Runner/`  

---

## **🗺 Google Maps (Optional)**  
1. Get an API key from [Google Cloud Console](https://cloud.google.com/maps-platform/).  
2. Add it to:  
   - Android: `android/app/src/main/AndroidManifest.xml`  
   - iOS: `ios/Runner/AppDelegate.swift`  

---

## **🚀 Running the App**  
```bash
# Android
flutter run -v

# iOS (requires Xcode)
flutter run --release

# Web
flutter run -d chrome
```

---

## **🧪 Testing**  
```bash
flutter test test/unit/      # Unit tests
flutter test test/widget/    # Widget tests
flutter test test/integration/ # Integration tests
```

---

## **📂 Project Structure**  
```
lib/  
├── models/          # Data models
├── Splash           # Splash screens
├── providers        # Calendar and state providers
├── utils            # Utils screens
├── screens/         # UI pages  
├── services/        # Firebase/APIs  
├── widgets/         # Reusable components  
└── main.dart        # Entry point  
```

---

## **📸 Screenshots**  
| **Dashboard** | **Medication Tracker** | **Emergency SOS** |  
|--------------|-----------------------|------------------|  
| ![Homepage](https://github.com/user-attachments/assets/1b3d654e-b804-4b22-aa88-7d5775f40215) | ![Medication](https://github.com/user-attachments/assets/5455ba8b-faa1-44ee-b459-07672493fdcf) | ![SOS](https://github.com/user-attachments/assets/cb59b9d8-476e-4a6b-bbdd-93cab8db5267) |  

---

## **🤝 Contributing**  
1. Fork the repository.  
2. Create a branch (`git checkout -b feature/your-feature`).  
3. Commit changes (`git commit -m 'Add feature'`).  
4. Push to the branch (`git push origin feature/your-feature`).  
5. Open a **Pull Request**.  

---

## **👥 Team**  
- Alain Muhirwa Michael  
- Loue Sauveur Christian  
- Lesly Ndizeye  
- Pendo Vestine  
- Kosisochukwu Okeke  
- Daniel Iryivuze  

---

## **🔗 Resources**  
- [Figma Prototype](https://www.figma.com/proto/69gRIbFXspRkfTjQeObwWe/FamCare?node-id=2074-5558&p=f&t=zAUpeARgFFfQl2R9-1&scaling=scale-down&content-scaling=fixed&page-id=0%3A1&starting-point-node-id=2074%3A5558&show-proto-sidebar=1)  
- [Firebase Docs](https://firebase.google.com/docs)  
- [Flutter Docs](https://flutter.dev/docs)  

--- 

### **Key Improvements**:  
1. **Kept all original links** (Firebase, screenshots, Figma).  
2. **Added direct links** to Firebase setup guides.  
3. **Streamlined sections** while preserving all critical details.  
4. **Maintained testimonials and team credits**.  
