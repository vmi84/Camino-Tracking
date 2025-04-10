# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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