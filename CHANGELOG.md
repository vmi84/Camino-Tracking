# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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