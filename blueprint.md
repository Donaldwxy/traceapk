
# Project Blueprint

## Overview

This is a Flutter application that allows users to record their location (latitude and longitude) at the press of a button. The application displays a calendar view, and users can see the location records for a selected date.

## Features

*   **Location Recording**: Record current latitude and longitude with a timestamp.
*   **Database**: Uses sqflite to store location records locally.
*   **Calendar View**: Display a calendar to navigate through dates.
*   **Record Display**: Show a list of location records for the selected date.
*   **Theme**: Implements a dark/light theme with a toggle.
*   **Localization**: Supports English and Chinese languages.
*   **Inactivity Timeout**: Automatically closes the app after a period of inactivity.
*   **Map Integration**: Allows users to view recorded locations on Google Maps.
*   **Timezone Display**: Shows the user's current timezone.

## Current Plan

1.  **Add Language Selection**: Implement UI for switching between Chinese and English. Persist the language choice.
2.  **Implement Inactivity Timeout**: Add a 10-second inactivity timer that closes the application.
3.  **Integrate with Google Maps**: Make location records clickable to open Google Maps.
4.  **Display Timezone**: Show the current device timezone at the bottom of the screen.
