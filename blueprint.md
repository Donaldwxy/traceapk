
# Project Blueprint: Location Tracker App

## 1. Overview

This document outlines the design, features, and development plan for the Location Tracker application. The goal is to create a robust Flutter application that automatically and manually records the user's location and time, persists these records locally, and allows the user to view and query their location history.

---

## 2. Style, Design, and Features

### Version 2.0 (Current Goal)

*   **Core Functionality**:
    *   **Persistent Storage**: Records will be stored in a local SQLite database using the `sqflite` package.
    *   **Automatic & Manual Recording**: The app will automatically log the location and time upon startup. A manual refresh button will allow users to trigger a new record at any time.
    *   **History View**: The main screen will display a list of the 10 most recent location records.
    *   **Date-based Query**: Users can select a date to view all records logged on that specific day.

*   **User Interface (UI)**:
    *   **Main Screen**: A two-part layout. The top section shows the status of the latest data fetch. The bottom section is a `ListView` that displays historical records.
    *   **Record Display**: Each record in the list will be shown in a `Card` with clear labels for time and location coordinates.
    *   **Date Query**: An `IconButton` (calendar icon) in the `AppBar` will trigger a `showDatePicker` dialog.
    *   **Query Results**: The results of a date search will be displayed in an `AlertDialog`.

*   **Data Model & Architecture**:
    *   **`LocationRecord` Model**: A Dart class to represent a single entry with `id`, `timestamp`, `latitude`, and `longitude`.
    *   **`DatabaseHelper` Class**: A singleton class to manage all database interactions (CRUD operations), abstracting the `sqflite` logic from the UI.

### Version 1.0 (Initial Implementation)

*   **Core Functionality**: Fetched and displayed the *current* location and time. No persistence.
*   **UI**: Simple screen with `Text` widgets, later improved with `Card` and `Icon` elements.
*   **State Management**: Used a simple `enum` to track loading/success/error states for a single data fetch.

---

## 3. Current Task: Implement Persistence and History Features

The user requires the app to save records and provide a history view. This involves adding a database, refactoring the UI, and building new query features.

### Plan & Steps

1.  **Add Dependencies**: Add `sqflite` and `path_provider` to the `pubspec.yaml` file.
2.  **Create Data Model**: Create a new file `lib/location_record.dart` for the `LocationRecord` class.
3.  **Create Database Helper**: Create a new file `lib/database_helper.dart` to house the `DatabaseHelper` class. This class will handle:
    *   Database initialization.
    *   `insertRecord(LocationRecord record)` method.
    *   `getRecentRecords({int limit = 10})` method.
    *   `getRecordsByDate(DateTime date)` method.
4.  **Refactor `lib/main.dart`**:
    *   Integrate the `DatabaseHelper`.
    *   Modify the state to hold a `List<LocationRecord>` for the history.
    *   Rewrite the `_getData` function to fetch location and then save it to the database using the helper.
    *   Create a `_loadHistory` function to populate the list from the database.
    *   Call `_getData` and `_loadHistory` in `initState` to fulfill the auto-record requirement.
    *   Update the `FloatingActionButton` to also call `_getData` and `_loadHistory`.
    *   Rebuild the UI to include the `ListView` of recent records.
    *   Implement the `_showDatePicker` function and the associated search logic, displaying results in a dialog.
