import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Image } from 'react-native';
import { Lodging } from '../types';

const LodgingView: React.FC<{ lodging: Lodging }> = ({ lodging }) => {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{lodging.name}</Text>
        <Text style={styles.subtitle}>Check-in: {lodging.checkInTime} | Check-out: {lodging.checkOutTime}</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Description</Text>
        <Text style={styles.description}>{lodging.description}</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Amenities</Text>
        <View style={styles.amenitiesContainer}>
          {lodging.amenities.map((amenity, index) => (
            <View key={index} style={styles.amenityItem}>
              <Text style={styles.amenityText}>• {amenity}</Text>
            </View>
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Contact Information</Text>
        <View style={styles.contactContainer}>
          <Text style={styles.contactText}>Phone: {lodging.contact.phone}</Text>
          <Text style={styles.contactText}>Email: {lodging.contact.email}</Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Location</Text>
        <Text style={styles.coordinates}>
          Latitude: {lodging.coordinates.latitude}
          {'\n'}
          Longitude: {lodging.coordinates.longitude}
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
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
    marginBottom: 12,
  },
  description: {
    fontSize: 16,
    color: '#444',
    lineHeight: 24,
  },
  amenitiesContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  amenityItem: {
    width: '50%',
    marginBottom: 8,
  },
  amenityText: {
    fontSize: 16,
    color: '#444',
  },
  contactContainer: {
    marginTop: 8,
  },
  contactText: {
    fontSize: 16,
    color: '#444',
    marginBottom: 4,
  },
  coordinates: {
    fontSize: 16,
    color: '#444',
    fontFamily: 'monospace',
  },
});

export default LodgingView; 