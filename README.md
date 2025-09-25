# HackAthlone Event Management App

## App Preview

<div align="center">

<a href="https://res.cloudinary.com/dcpkkvqs6/video/upload/v1758803698/feature_stacked_pphoyr.mp4">
  <img src="https://res.cloudinary.com/dcpkkvqs6/image/upload/v1758804209/appUI.png" alt="HackAthlone App Demo" width="400" />
</a>

**Click on the image above to view demo video**

_See the app in action: Authentication, meal tracking, QR scanning, and event timeline features_

</div>

<div align="left">

[![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)

</div>

<!-- TODO: Add app demo video/gif here -->

## App Preview

<div align="center">

[![HackAthlone App Demo](https://res.cloudinary.com/dcpkkvqs6/image/upload/v1758804209/appUI.png)](https://res.cloudinary.com/dcpkkvqs6/video/upload/v1758803698/feature_stacked_pphoyr.mp4)

</div>

> Flutter mobile application for hackathon event management, featuring QR code meal tracking, real-time notifications, and seamless offline-first architecture.

## Download

<div align="center">

| Platform    | Download                                                                                                                                                             | Status      |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| **Android** | [![Get it on Google Play](https://img.shields.io/badge/Google_Play-414141?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps) | Coming Soon |
| **iOS**     | [![Download on the App Store](https://img.shields.io/badge/App_Store-0D96F6?style=for-the-badge&logo=app-store&logoColor=white)](https://apps.apple.com/)            | Coming Soon |

</div>

---

## ✨ Core Features

### 🔐 Authentication & User Management

- **Smart Authentication**: Email-based signup with verification
- **Profile Management**: Complete user profiles with skills, preferences, and dietary requirements
- **QR Code Integration**: Unique QR codes for each participant for meal tracking
- **Role-Based Access**: Admin and participant roles with different feature sets

### 🍽️ Meal Management System

- **Real-time Menu Display**: 48-hour meal schedules across event days (Oct 3-5)
- **QR Code Meal Tracking**: Scan-to-claim meal allowances with validation
- **Dietary Accommodation**: Support for various dietary restrictions and preferences
- **Provider Information**: Clear meal provider details and descriptions

### 📅 Event Timeline & Schedule

- **Interactive Timeline**: Comprehensive event schedule with notifications
- **Real-time Updates**: Live event information and schedule changes
- **Location Integration**: Google Maps integration for venue navigation

### 🔔 Smart Notifications

- **Push Notifications**: Firebase-powered real-time notifications
- **Event Reminders**: Automated reminders for meals, sessions, and important updates
- **Admin Broadcasting**: Bulk notification system for event organizers

### 💾 Offline-First Architecture

- **Smart Caching**: Hive-based local storage with staleness validation
- **Automatic Sync**: Seamless online/offline data synchronization
- **Fallback Systems**: Multi-layer error handling and data recovery

### 👥 Admin Features

- **QR Code Scanning**: Validate meal claims and track attendance
- **User Management**: View participant profiles and meal allowances
- **Notification Center**: Send targeted or broadcast notifications
- **Real-time Analytics**: Track meal usage and event participation

---

## 🛠️ Tech Stack

### **Frontend Framework**

- **Flutter 3.8+** - Cross-platform mobile development
- **Dart** - Programming language

### **Backend & Database**

- **Supabase** - Backend-as-a-Service with PostgreSQL
- **Row Level Security (RLS)** - Database security policies
- **Stored Procedures** - Custom database functions for complex operations

### **State Management & Architecture**

- **Provider Pattern** - Reactive state management
- **Service Layer Architecture** - Clean separation of concerns
- **Repository Pattern** - Data access abstraction

### **Real-time & Notifications**

- **Firebase Cloud Messaging (FCM)** - Push notifications
- **Firebase Core** - Firebase SDK integration
- **WebSocket** - Real-time data synchronization

### **Local Storage & Caching**

- **Hive** - Fast, lightweight NoSQL database
- **Shared Preferences** - Simple key-value storage
- **Path Provider** - File system access

### **Authentication & Security**

- **Supabase Auth** - User authentication system
- **Deep Linking** - App Links for email verification
- **JWT Tokens** - Secure API authentication

### **UI/UX & Media**

- **Material Design 3** - Modern UI components
- **Custom Theming** - Brand-consistent design system
- **QR Code Generation/Scanning** - Mobile Scanner integration
- **Image Handling** - Profile pictures and media management

### **Development & CI/CD**

- **Codemagic** - Automated build and deployment
- **Flutter Lints** - Code quality and consistency
- **Build Runner** - Code generation for models
- **Hive Generator** - Automatic adapter generation

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK 3.8+** - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** - Included with Flutter
- **Android Studio / Xcode** - For mobile development
- **Supabase Account** - For backend services
- **Firebase Project** - For push notifications

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/iecloudbird/hackathlone-app.git
   cd hackathlone-app
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Setup environment variables:**

   ```bash
   cp assets/.env.example assets/.env
   # Add your Supabase credentials to assets/.env
   ```

4. **Generate code (Hive adapters):**

   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🔧 Development

### **Code Generation**

After modifying Hive models, regenerate adapters:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **Building for Production**

```bash
# Android
flutter build apk --release

# iOS (requires Apple Developer account)
flutter build ipa --release
```

---

## 📄 License

## This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

- 📧 Email: sheanhans03@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/iecloudbird/hackathlone-app/issues)
- 📖 Documentation: [Project Wiki](https://github.com/iecloudbird/hackathlone-app/wiki)

---

<div align="center">

**🌟 Star this repository if you found it helpful!**

Made for 2025 NASA SpaceApps Challenge Athlone local event

</div>
