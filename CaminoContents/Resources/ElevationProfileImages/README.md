# Elevation Profile Images

This directory contains all the elevation profile images for the Camino app.

## Image Naming Convention

- Regular days: `day{number}.png` (e.g., `day1.png`, `day2.png`)
- Special variants: `day{number}{variant}.png` (e.g., `day35a.png`, `day35b.png`)

## Important Notes

1. Do not create duplicate copies of these images in other locations, such as:
   - `/Users/jeffwhite/Desktop/ElevationProfileImages/`
   - `/Users/jeffwhite/Desktop/Camino/ElevationProfileImages/`
   - `/Users/jeffwhite/Desktop/Camino/CaminoContents/ElevationProfileImages/`

2. This directory (`/Users/jeffwhite/Desktop/Camino/CaminoContents/Resources/ElevationProfileImages/`) is the canonical location for all elevation profile images.

3. The app's `loadElevationProfileImage` function has been updated to only look for images in this directory.

4. If you need to add or update an image, place it directly in this directory with the appropriate naming convention. 