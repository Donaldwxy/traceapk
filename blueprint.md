
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
*   **Map Integration**: Allows users to view recorded locations on Google Maps.
*   **Timezone Display**: Shows the user's current timezone.
*   **Coordinate Conversion**: Converts WGS84 coordinates to GCJ-02 for accurate map display in China.

## Version

1.0.1

## Current Plan

1.  **Remove Inactivity Timeout**: Removed the 10-second inactivity timer that closes the application.
2.  **Move Language Selection**: Moved the language selection from the drawer to a popup menu in the app bar, next to the calendar icon.
3.  **Update Version**: Updated the application version to 1.0.1.
4.  **Fix Map Coordinate Offset**: Added `coord_convert` package to convert WGS84 coordinates to GCJ-02 before opening Google Maps to ensure correct location display in China.
