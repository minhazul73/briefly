# Briefly - Notes Management App

A modern, responsive Notes Management application built with Flutter, Provider, and Firebase Cloud Firestore.

## Tech Stack
*   **Framework:** Flutter (Material 3)
*   **State Management:** Provider
*   **Backend/Database:** Firebase Cloud Firestore
*   **Layout:** Masonry Grid (`flutter_staggered_grid_view`)

## Features
*   **Real-time sync:** Notes update instantly across devices via Cloud Firestore streams.
*   **Masonry Layout:** Notes automatically size to their content and stagger gracefully.
*   **Optimistic UI:** UI responds instantly when deleting notes while syncing safely in the background.
*   **Modern Aesthetics:** Material 3 design, custom card colors, soft animations, and a seamless bottom sheet for creating/editing notes.

## Setup Instructions

1.  **Flutter setup:** Ensure you have Flutter installed and configured.
2.  **Firebase setup:** 
    *   This project requires Firebase to be configured. 
    *   Initialize a Firebase project and add the Flutter apps (via `flutterfire configure`).
    *   Enable Cloud Firestore in the Firebase console.
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

## Firestore Schema

**Collection:** `notes` (root-level collection)

Each document follows this structure:
```json
{
  "title": "string",
  "description": "string",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```
*   **Document IDs** are auto-generated.
*   `createdAt` and `updatedAt` are populated via `FieldValue.serverTimestamp()` to ensure consistent server-side timestamps.
