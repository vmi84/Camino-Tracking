# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-04-03

### Added
- Significant map updates, including improved route point fetching and display logic.

### Fixed
- Resolved compiler errors related to optional coordinate handling in `MapViewModel`.

### Changed
- Refined `.gitignore` rules to properly ignore nested Xcode files (`xcshareddata`, `xcuserdata`) and build artifacts (`.build`).
- Cleaned Git index by untracking previously committed build artifacts and the `Dependencies/SwiftyJSON` directory (now ignored).

## [1.0.3] - 2024-07-31

### Fixed
- Resolved an issue where the Weather tab would become unresponsive after being used once, requiring an app restart. The redirection attempt flag was being incorrectly persisted.

## [1.0.0] - 2024-07-16

### Added
- **Feedback Feature:** Added a "Send Feedback" option in Settings, allowing users to compose and send feedback via email using the built-in Mail app.
- Static app icon (church image) (from v0.7.0).
- Comprehensive Settings screen (theme, units, language, map, GPS, etc.) (from v0.5.0).
- Weather tab with deep-link to Apple Weather (based on v0.4.0, fixed in v0.7.4).
- Translation tab using GoogleTranslate view (based on v0.6.3).
- Detailed route information in Destination views (from v0.5.1).
- Hotel information display in Destination views (from v0.7.1).

### Changed
- Shifted destination day numbering to start from Day 0 (from v0.7.1).
- Restored distance display in DestinationDetailView (from v0.6.5.3).
- Updated destination dates/names based on bookings (from v0.5.8).
- Moved language selection to Settings (from v0.5.5).

### Fixed
- Corrected app icon configuration and assets (v0.7.3).
- Refactored Weather view/viewModel for reliable deep-linking (v0.7.4).
- Adjusted Translator layout for better text display (v0.7.2).
- Fixed current location button and handling in MapView (v0.6.5).
- Resolved Git submodule issues (v0.7.0).
- Corrected route distance calculations (v0.3.3).
- Numerous minor layout adjustments and stability improvements across versions.

## [Unreleased]

## [1.0.2] - 2024-07-30
### Added
- Settings: Added a button to link to a user-selected documents folder in the Files app.

### Changed
- Settings: Refactored 'My Documents' section to support linking a single folder instead of multiple individual files.

### Removed
- Settings: Removed functionality for linking and previewing individual Voucher, Dossier, and Insurance PDFs.

## [1.0.1] - 2024-07-29
### Fixed
- `DestinationDetailView`: Corrected the navigation title to display the previous destination name instead of the next one.

## [1.0.0] - 2024-07-29
### Added
- Feedback feature allowing users to send comments via email.
- Email address updated to `vmi84@me.com`.

### Changed
- Dismiss `FeedbackView` after sending email.

## [0.7.4] - 2024-07-16

### Fixed
- Refactored `WeatherView` and `WeatherViewModel`.
- `WeatherView` now uses the shared `WeatherViewModel` instance created in `CaminoMainView`.
- Fixed Apple Weather deep-link: It now correctly triggers when the Weather tab is selected (if WeatherKit is not enabled).
- Simplified WeatherViewModel state management.

## [0.6.5] - 2025-04-29

### Fixed
- Fixed current location button functionality in MapView
- Added visual feedback for location availability status
- Improved location authorization handling
- Added user alerts when location services are unavailable
- Enhanced location updates to start automatically when permissions are granted

## [0.6.3] - 2025-04-21

### Added
- Added support for regional languages: Galician and Basque
- Updated language labels for better clarity (Spanish → Spanish (Castilian))
- Enhanced Translation tab functionality for immediate language selection

### Fixed
- Fixed Weather tab to immediately open Apple Weather for current location
- Optimized redirection timing for smoother user experience
- Resolved WelcomeView display issues on certain devices

## [0.6.0] - 2025-04-20

### Fixed
- Fixed route schedule to properly represent the Camino Frances journey
- Corrected day numbering to include Day 0 at Saint Jean Pied de Port
- Ensured Destinations and Destination Details views properly reflect route schedules
- Updated CaminoModels module imports across the application
- Fixed Weather view to display accurate destination information

### Added
- Module imports in all view files for proper dependency management
- Enhanced route detail information with accurate elevation profiles

## [0.5.9] - 2025-04-18

### Added
- Added Day 0 for Saint Jean Pied de Port on May 1st, 2025
- Expanded the description for the arrival day to include more details

### Changed
- Shifted all subsequent day numbers up by 1 while maintaining correct dates
- Adjusted all daily distances and cumulative distances to reflect the proper journey

## [0.5.8] - 2025-04-18

### Fixed
- Corrected all destination dates to match the official itinerary
- Updated destination names and locations based on actual accommodation bookings
- Fixed the León rest day (day 23) timing
- Ensured all subsequent dates are properly adjusted for the rest day

## [0.5.7] - 2025-04-18

### Added
- New church icon displayed on the welcome screen
- Enhanced visual appeal with cathedral artwork

### Changed
- Improved welcome screen layout with oval-shaped information panel
- Enhanced transparency effects on the welcome panel
- Better positioning of UI elements for visual hierarchy
- Ensured Start Journey button is clearly visible
- Refined gradient background for the welcome panel

## [0.5.5] - 2025-04-17

### Added
- Moved language selection from Translation screen to Settings for better user experience
- Added detailed language preferences section in Settings
- Support for multiple languages including English, Spanish, French, German, Italian, Portuguese, and Russian

### Changed
- Simplified Translation UI with non-interactive language display
- Added "Change languages in Settings" instruction for better discoverability
- Improved language detection with "Detect" button in translation input
- Enhanced translation experience with persistent language preferences across app sessions

## [0.5.1] - 2025-04-16

### Added
- Comprehensive route details for all 33 days of the Camino journey
- Detailed waypoint information for each day including distances and services
- Starting and ending point details with specific directions
- Complete elevation information (ascent/descent) for each stage
- Service availability information at waypoints (bars, fountains, stores, etc.)
- Specific route directions and path guidance
- Integration of route details in the destination detail view
- Support for route day mapping with León rest day adjustment

### Changed
- Enhanced destination detail view with organized route information
- Improved user experience with expandable route sections
- Better visual separation between waypoints
- Fixed waypoint comparison with Equatable conformance
- Made LocationPoint conform to Equatable for proper comparisons

## [0.5.0] - 2025-04-15

### Added
- Comprehensive Settings screen with configuration options
- Theme selection feature (Light, Dark, System) in Settings
- Distance unit toggle (kilometers/miles) in Settings
- Language selection (English/Spanish) in Settings
- GPS update frequency configuration
- Weather update frequency settings
- Map style configuration options (Standard, Satellite, Hybrid)
- Temperature unit toggle (Celsius/Fahrenheit)
- Data management options (backup/restore, cache clearing)
- About section with resources and app information

### Fixed
- Map style selection now correctly changes map appearance
- Fixed cross-platform color compatibility issues
- Resolved duplicate type declaration errors
- Applied consistent styling across all screens
- Fixed theme switching implementation to work system-wide

### Changed
- Improved Settings UI with organized sections and icons
- Enhanced Settings navigation with proper section headers
- Moved appearance settings to General section for better discoverability
- Applied theme changes app-wide using SwiftUI's preferredColorScheme
- Used AppStorage for persistent settings

## [0.4.0] - 2025-04-10

### Added
- Weather tab with current conditions and forecasts for all destinations
- Current weather display with temperature, conditions, and weather icons
- Detailed weather view with hourly forecast for the next 24 hours
- 10-day forecast for longer trip planning
- Current condition details (feels like temperature, humidity, wind, UV index)
- Loading indicators and placeholders for weather data
- Offline weather caching with 15-minute refresh intervals
- Last updated timestamp display
- WeatherKit integration with fallback to simulated weather data
- Proper attributions for weather data sources

### Changed
- Main tab view now includes fully functional weather tab
- Improved weather data presentation with appropriate icons and formatting
- Added detailed weather information for each destination
- Enhanced Welcome screen with proper iPhone 13 Mini support
- Repositioned Start Journey button at the top of the Welcome screen
- Improved button styling with gradient background and shadow
- Optimized image sizing for different device dimensions
- Added status bar hiding for more immersive welcome experience

### Fixed
- Resolved duplicate WeatherStore class definition
- Fixed UIKit color compatibility issues across platforms
- Properly configured GeometryReader for adaptive layouts
- Fixed welcome screen image scaling and positioning

## [0.3.3] - 2025-04-08

### Fixed
- Corrected route distance discrepancy between the Route Information section and Directions section
- Updated distance calculations to use actual route distances extracted from content
- Fixed cumulative distance calculation to use the correct distance values
- Ensured destination list shows accurate distance information

## [0.3.2] - 2025-04-07

### Added
- Hotel markers displayed on the map with orange pins
- Home button to center the map on St. Jean Pied de Port (starting point)
- Improved coordinates display in destination detail view
- Added hotel coordinates to MapView
- Zoom in/out buttons at top right corner of the map
- Added rest day in León (day 23, May 24)
- Updated all subsequent days and dates in the itinerary

### Changed
- Map now starts centered on St. Jean Pied de Port
- Enhanced hotel coordinates display with proper degree symbols and directional indicators
- Improved UI for destination detail view
- Added shadow effect to map control buttons for better visibility
- Adjusted itinerary to reflect an extra day spent in León
- Updated arrival date in Santiago de Compostela to June 6 

## [0.2.5] - 2025-04-07

### Added
- Total distance calculation for the Camino Frances route
- Complete trip planning with all days and locations resolved

### Changed
- Positioned Start Journey button at top of image without white space
- Improved text wrapping with increased horizontal padding (80pt)
- Increased description text size to .body
- Added MapView and DestinationsView integration
- Fixed map navigation and destination tracking

## [0.2.4] - 2025-04-07

### Added
- Calendar dates for each destination (e.g., "01 May 2025")
- Date display in both destination list and detail views
- Date formatter for consistent date formatting

### Changed
- Updated CaminoDestination model to include date information
- Enhanced destination views with date display
- Improved destination list item layout

## [0.2.3] - 2025-04-07

### Added
- Implemented map view with destination tracking
- Added location services integration
- Created destination detail view with map and information

### Changed
- Updated project structure for better organization
- Improved map view performance and accuracy

## [0.2.2] - 2025-04-07

### Added
- Destination model with all 29 Camino Frances locations
- Map annotations for each destination with day numbers
- Route overlay showing the path between destinations
- Real-time location tracking with off-route detection
- Location permissions configuration in Info.plist
- Project restructuring with CaminoContents directory
- Added Podfile for dependency management
- New MapViewModel for handling map state and user location
- Bottom navigation bar with Map, Weather, Profile, and Settings tabs
- Destination detail sheet with location and hotel information

### Changed
- Reorganized project structure for better modularity
- Moved Views into dedicated directory
- Updated Xcode schemes for iPhone 15 and 16 simulators
- Integrated MapView with TabView navigation
- Consolidated all map-related code into MapView.swift
- Fixed file organization and project structure
- Successfully integrated MapView into Xcode project
- Map now displays and builds correctly

## [0.2.1] - 2025-04-07

### Added
- Initial implementation of MapView with destinations
- Added CaminoDestination model
- Added MapViewModel for location handling
- Created MapPolyline for route visualization

## [0.2.0] - 2025-04-07

### Added
- Basic project structure
- Initial SwiftUI setup

### Changed
- Moved Start button to the top of the Welcome screen
- Updated Welcome screen layout and styling
- Changed Start button color to light blue-gray

### Fixed
- Resolved crash when selecting the Map tab by implementing proper MapView 