# Project Blueprint

## Overview

This is a Flutter application that allows users to record their location (latitude and longitude). The application is designed for both users in Mainland China and Overseas, providing a tailored experience for each region.

## Features

*   **Automatic Location Recording**: Records the user's current latitude and longitude with a timestamp every time the app comes to the foreground.
*   **Manual Recording**: Users can manually trigger a location record at any time.
*   **Database**: Uses sqflite to store location records locally.
*   **History View**: Displays a list of recent location records.
*   **Date-based Search**: Users can view all records from a specific date using a calendar.
*   **Region-based UI & Maps**:
    *   Provides a toggle to switch between "Mainland China" and "Overseas" modes.
    *   **Mainland China Mode**: The UI is in Chinese. Tapping a record opens **Amap (Gaode Maps)** with the location.
    *   **Overseas Mode**: The UI is in English. Tapping a record opens **Google Maps**.
*   **Timezone Display**: Shows the user's current timezone.

## Version

**1.0.2**

## Current Plan

1.  **Remove Coordinate Conversion**: Eliminate the `coord_convert` package and all related WGS84 to GCJ-02 conversion logic.
2.  **Implement Region Toggle**:
    *   Replace the language selection menu with a new button in the `AppBar` to toggle between "Mainland China" (中文) and "Overseas" (English) modes.
    *   This toggle will control both the UI language and the map service used.
3.  **Update Map URL Logic**:
    *   If in "Mainland China" mode, clicking a record will open Amap using its URL scheme.
    *   If in "Overseas" mode, it will open Google Maps.
4.  **Implement Automatic Recording on Resume**: The app will now automatically record the user's location every time it is brought to the foreground.
