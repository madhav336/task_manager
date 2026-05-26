# Task Manager

A Flutter-based task management application that helps you organize, prioritize, and track your daily tasks with cloud synchronization. Tasks are stored locally using Hive and automatically synced with Firebase Firestore for seamless access across sessions.

## Features

- User Authentication: Secure login and account creation with Firebase Authentication
- Task Management: Create, edit, and delete tasks with titles and descriptions
- Task Status Tracking: Mark tasks as completed or pending
- Dual Storage: Local storage with Hive for offline access and Cloud Firestore for persistent backup
- Cloud Synchronization: Automatic sync between local and cloud storage when internet is available
- Offline Support: Full functionality without internet connection with automatic sync when reconnected
- Tab-Based Organization: Separate tabs for upcoming and completed tasks
- Swipe to Delete: Quick task deletion with swipe gesture
- User-Specific Tasks: Each user's tasks are securely stored in their own collection
- Due Date Support: Assign due dates to tasks for better planning
- Dark Theme: Modern dark theme with custom green color scheme
- Google Fonts Integration: Clean typography with Poppins font family

## Prerequisites

- Flutter SDK 3.10.4 or higher
- Dart 3.10.4 or higher
- Android Studio or Xcode for emulator
- Firebase account and project setup

## Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/madhav336/task_manager.git
cd task_manager
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com/
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Download and configure Firebase credentials for your platform

4. Generate Hive adapters:
```bash
flutter pub run build_runner build
```

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point with Firebase and Hive initialization
├── login_screen.dart      # Authentication screen with login and signup
├── task_screen.dart       # Main task management screen with tabs
├── task_item.dart         # Task model with Hive annotations
├── sync_service.dart      # Firebase synchronization service
└── firebase_options.dart  # Firebase configuration
```

## Dependencies

- `flutter` - UI framework
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Cloud database
- `hive` - Local NoSQL database
- `hive_flutter` - Hive integration with Flutter
- `connectivity_plus` - Network connectivity detection
- `google_fonts` - Custom fonts
- `cupertino_icons` - iOS style icons

## Key Features Explained

**Cloud Synchronization**: Tasks are automatically synced to Firebase when internet is available. The app detects connectivity and syncs all changes. On logout, local tasks are cleared to ensure privacy.

**Offline Functionality**: All tasks work offline using Hive local storage. Changes are queued and synced automatically when internet returns.

**User-Specific Storage**: Each user's tasks are stored in Firebase under their unique user ID, ensuring complete data separation and security.

**Task Management**: Create tasks with title and optional description, mark them complete with checkbox, edit existing tasks, or delete by swiping left.

## Usage

1. Launch the app
2. Sign up with email and password or login if you have an account
3. Click the add button to create a new task
4. Enter task title (required) and description (optional)
5. Click Add to save the task
6. Tap on a task to edit it
7. Check the checkbox to mark a task as complete
8. Swipe left on a task to delete it
9. Switch between "Upcoming" and "Completed" tabs to organize your tasks
10. Click your email avatar to logout

## Building

### Android:
```bash
flutter build apk
```

### iOS:
```bash
flutter build ios
```

## Contributing

Contributions are welcome. Feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License.

## Support

For issues or questions, please open an issue on the repository.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Hive Database](https://docs.hivedb.dev/)
