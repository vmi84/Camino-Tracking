import React, { useEffect, useState } from 'react';
import { View, StyleSheet, Text } from 'react-native';
import MapView, { Marker, Polyline } from 'react-native-maps';
import { Route, Weather } from '../types';
import { getCurrentWeather } from '../services/weatherService';
import { getCurrentLocation } from '../services/locationService';

const RouteView: React.FC = () => {
  const [currentRoute, setCurrentRoute] = useState<Route | null>(null);
  const [weather, setWeather] = useState<Weather | null>(null);
  const [userLocation, setUserLocation] = useState<{ latitude: number; longitude: number } | null>(null);
  const [routeProgress, setRouteProgress] = useState<number>(0);

  useEffect(() => {
    // Initialize location tracking
    const locationSubscription = getCurrentLocation((location) => {
      setUserLocation(location);
      // Calculate progress based on distance from start
      if (currentRoute) {
        const progress = calculateProgress(location, currentRoute);
        setRouteProgress(progress);
      }
    });

    // Initialize weather updates
    const weatherSubscription = getCurrentWeather((weatherData) => {
      setWeather(weatherData);
    });

    return () => {
      locationSubscription.remove();
      weatherSubscription.remove();
    };
  }, [currentRoute]);

  const calculateProgress = (location: { latitude: number; longitude: number }, route: Route) => {
    // Implement distance calculation between current location and route start
    // Return percentage of route completed
    return 0; // Placeholder
  };

  return (
    <View style={styles.container}>
      <MapView
        style={styles.map}
        initialRegion={{
          latitude: currentRoute?.coordinates.latitude || 42.8806,
          longitude: currentRoute?.coordinates.longitude || -8.5444,
          latitudeDelta: 0.0922,
          longitudeDelta: 0.0421,
        }}
      >
        {currentRoute && (
          <>
            <Marker
              coordinate={currentRoute.coordinates}
              title={currentRoute.endLocation}
              description={`Day ${currentRoute.day}: ${currentRoute.startLocation} to ${currentRoute.endLocation}`}
            />
            <Polyline
              coordinates={[
                { latitude: currentRoute.coordinates.latitude, longitude: currentRoute.coordinates.longitude },
                // Add more coordinates for the route path
              ]}
              strokeWidth={3}
              strokeColor="#FF0000"
            />
          </>
        )}
        {userLocation && (
          <Marker
            coordinate={userLocation}
            title="Your Location"
            pinColor="blue"
          />
        )}
      </MapView>

      <View style={styles.overlay}>
        <View style={styles.weatherContainer}>
          {weather && (
            <>
              <Text style={styles.weatherText}>{weather.temperature}°C</Text>
              <Text style={styles.weatherText}>{weather.condition}</Text>
              {weather.precipitation > 0 && (
                <Text style={styles.weatherText}>Precipitation: {weather.precipitation}mm</Text>
              )}
            </>
          )}
        </View>

        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>Route Progress: {routeProgress}%</Text>
          <Text style={styles.distanceText}>
            Distance to next stop: {currentRoute?.distance || 0} km
          </Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  overlay: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    padding: 16,
  },
  weatherContainer: {
    marginBottom: 16,
  },
  weatherText: {
    fontSize: 16,
    color: '#333',
  },
  progressContainer: {
    marginTop: 8,
  },
  progressText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  distanceText: {
    fontSize: 16,
    color: '#666',
  },
});

export default RouteView; 