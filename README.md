# 💬 ChatApp – Real-Time Chat Application with Firebase

ChatApp is a modern, real-time chat application built with Flutter and Firebase, featuring individual and group chats, email verification, and a sleek, themeable UI with light and dark modes.

---

## 🌟 Overview

ChatApp is a Flutter-based chat application that allows users to engage in individual and group conversations with real-time messaging. It uses Firebase Authentication for secure user management with email verification, Firestore for persistent chat data, and Firebase Hosting for web deployment. The app supports light and dark themes, offering a seamless and visually appealing user experience.

---

## 🚀 Features

- ✅ Individual and group chat functionality with real-time messaging.
- 💾 Persistent chat history stored in Firebase Firestore.
- 🔐 Secure user authentication with email verification using Firebase Auth.
- 🔍 Search functionality for group chat messages (by content and sender).
- 🧑‍🤝‍🧑 Add new friends and create/join group chats.
- 🎨 Beautiful UI with light and dark mode support, featuring gradient backgrounds and blur effects.
- 👤 Friend profile view with common groups section.
- 🌐 Web deployment support via Firebase Hosting.

---

## 🛠️ Tech Stack

- **Flutter & Dart** – Cross-platform UI development for mobile and web.
- **Firebase**:
  - **Firestore** – Backend for storing chat messages, groups, and user data.
  - **Authentication** – Email-based user authentication with verification.
  - **Hosting** – Web deployment for the Flutter web app.
- **GitHub** – Version control and project hosting.

---


## 🏁 Getting Started

### 📥 Clone the Repository


git clone https://github.com/SujithaKC/ChatApp.git
cd ChatApp

### 🔧 Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com).
2. Enable Firestore Database and Email/Password Authentication.
3. Enable Firebase Hosting for web deployment (optional).
4. Register your Flutter app:
   - **Android**: Download `google-services.json` → `/android/app/`
   - **iOS**: Download `GoogleService-Info.plist` → `/ios/Runner/`
   - **Web**: Setup Firebase Hosting

5. Use FlutterFire CLI to configure:

flutterfire configure

6. This generates `firebase_options.dart` in `lib/`.

### 📦 Install Dependencies

flutter pub get

### ▶️ Run the App

flutter run

---

## 🗂️ Firestore Data Structure

```
users/
  userID/
    email: string
    displayName: string
    photoURL: string
    bio: string
    createdAt: timestamp

chats/
  chatID/
    members: [userId, ...]
    lastMessage: string
    lastMessageTime: timestamp
    messages/
      messageID/
        senderId: string
        text: string
        timestamp: timestamp

groups/
  groupID/
    name: string
    members: [userId, ...]
    admins: [userId, ...]
    adminOnlyChat: boolean
    lastMessage: string
    lastMessageSenderId: string
    lastMessageTime: timestamp
    messages/
      messageID/
        senderId: string
        text: string
        timestamp: timestamp
```

---

## 🎨 Design & Architecture

- Firestore provides persistent and real-time updates.
- Email verification ensures secure authentication.
- Themeable UI with gradient backgrounds and blur effects.
- Modular architecture (auth, chat, group, profile modules).

---

## ⚙️ Key Components

| Widget/Service         | Responsibility                                 |
|------------------------|-----------------------------------------------|
| `LoginScreen`          | User login with email verification            |
| `SignUpScreen`         | User registration with email verification     |
| `ChatListScreen`       | List all individual and group chats           |
| `ChatScreen`           | One-on-one chat interface                     |
| `GroupChatScreen`      | Group chat with search and admin controls     |
| `GroupCreateScreen`    | Create new group chats                        |
| `FriendProfileScreen`  | View friend’s profile and common groups       |
| `LoginViewModel`       | Manages authentication logic                  |
| `ChatViewModel`        | Handles individual chat logic                 |
| `GroupChatViewModel`   | Manages group chat logic                      |

---

## 🤝 Contribution

Contributions are welcome!  
Please fork the repo and create a pull request.  
Make sure your code follows the architecture and is well-documented.

⭐ Thank you for checking out **ChatApp**! Feel free to give a ⭐ star if you like the project.
