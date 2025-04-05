import React, { useState } from 'react';
import { View, Text, StyleSheet, Switch, TouchableOpacity, ScrollView } from 'react-native';
import { Settings } from '../types';

const SettingsView: React.FC = () => {
  const [settings, setSettings] = useState<Settings>({
    distanceUnit: 'km',
    trackingEnabled: true,
    offlineMaps: {
      downloaded: false,
      selectedMap: 'default',
      availableMaps: ['default', 'terrain', 'satellite'],
    },
    weatherOptions: {
      showPrecipitation: true,
      showWind: true,
      showClouds: true,
      showUVIndex: false,
    },
  });

  const toggleSetting = (key: keyof Settings['weatherOptions']) => {
    setSettings(prev => ({
      ...prev,
      weatherOptions: {
        ...prev.weatherOptions,
        [key]: !prev.weatherOptions[key],
      },
    }));
  };

  const toggleTracking = () => {
    setSettings(prev => ({
      ...prev,
      trackingEnabled: !prev.trackingEnabled,
    }));
  };

  const toggleDistanceUnit = () => {
    setSettings(prev => ({
      ...prev,
      distanceUnit: prev.distanceUnit === 'km' ? 'miles' : 'km',
    }));
  };

  const downloadOfflineMap = () => {
    // Implement offline map download
    setSettings(prev => ({
      ...prev,
      offlineMaps: {
        ...prev.offlineMaps,
        downloaded: true,
      },
    }));
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Tracking</Text>
        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>Enable GPS Tracking</Text>
          <Switch
            value={settings.trackingEnabled}
            onValueChange={toggleTracking}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Units</Text>
        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>Distance Unit: {settings.distanceUnit}</Text>
          <TouchableOpacity
            style={styles.toggleButton}
            onPress={toggleDistanceUnit}
          >
            <Text style={styles.toggleButtonText}>Switch</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Offline Maps</Text>
        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>Download Offline Maps</Text>
          <TouchableOpacity
            style={styles.downloadButton}
            onPress={downloadOfflineMap}
            disabled={settings.offlineMaps.downloaded}
          >
            <Text style={styles.downloadButtonText}>
              {settings.offlineMaps.downloaded ? 'Downloaded' : 'Download'}
            </Text>
          </TouchableOpacity>
        </View>
        <View style={styles.mapOptions}>
          {settings.offlineMaps.availableMaps.map((map) => (
            <TouchableOpacity
              key={map}
              style={[
                styles.mapOption,
                settings.offlineMaps.selectedMap === map && styles.selectedMapOption,
              ]}
              onPress={() => setSettings(prev => ({
                ...prev,
                offlineMaps: {
                  ...prev.offlineMaps,
                  selectedMap: map,
                },
              }))}
            >
              <Text style={styles.mapOptionText}>{map}</Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Weather Display</Text>
        {Object.entries(settings.weatherOptions).map(([key, value]) => (
          <View key={key} style={styles.settingRow}>
            <Text style={styles.settingLabel}>
              {key.charAt(0).toUpperCase() + key.slice(1)}
            </Text>
            <Switch
              value={value}
              onValueChange={() => toggleSetting(key as keyof Settings['weatherOptions'])}
            />
          </View>
        ))}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  section: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 16,
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  settingLabel: {
    fontSize: 16,
    color: '#444',
  },
  toggleButton: {
    padding: 8,
    backgroundColor: '#007AFF',
    borderRadius: 4,
  },
  toggleButtonText: {
    color: '#fff',
    fontSize: 14,
  },
  downloadButton: {
    padding: 8,
    backgroundColor: '#34C759',
    borderRadius: 4,
  },
  downloadButtonText: {
    color: '#fff',
    fontSize: 14,
  },
  mapOptions: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 12,
  },
  mapOption: {
    padding: 8,
    marginRight: 8,
    marginBottom: 8,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
  },
  selectedMapOption: {
    backgroundColor: '#007AFF',
  },
  mapOptionText: {
    color: '#333',
    fontSize: 14,
  },
});

export default SettingsView; 