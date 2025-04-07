# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2024-04-06

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

## [0.2.1] - 2024-04-06

### Added
- New `MapView` component for displaying the Camino route using MapKit
- Weather tab in the main navigation with cloud.sun icon

### Changed
- Moved Start button to the top of the Welcome screen
- Updated Welcome screen layout and styling
- Changed Start button color to light blue-gray

### Fixed
- Resolved crash when selecting the Map tab by implementing proper MapView 