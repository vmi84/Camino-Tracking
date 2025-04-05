import React, { useState } from 'react';
import { View, Text, StyleSheet, FlatList, TouchableOpacity } from 'react-native';
import { Route } from '../types';

const DestinationView: React.FC = () => {
  const [selectedDay, setSelectedDay] = useState<number | null>(null);

  const renderDayItem = ({ item }: { item: Route }) => (
    <TouchableOpacity
      style={styles.dayItem}
      onPress={() => setSelectedDay(item.day)}
    >
      <View style={styles.dayHeader}>
        <Text style={styles.dayNumber}>Day {item.day}</Text>
        <Text style={styles.distance}>{item.distance} km</Text>
      </View>
      <Text style={styles.routeText}>
        {item.startLocation} → {item.endLocation}
      </Text>
      {selectedDay === item.day && (
        <View style={styles.detailsContainer}>
          <Text style={styles.detailsTitle}>Directions:</Text>
          {item.directions.map((direction, index) => (
            <Text key={index} style={styles.directionText}>
              • {direction}
            </Text>
          ))}
          <Text style={styles.hotelText}>Hotel: {item.hotel}</Text>
        </View>
      )}
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={[]} // Replace with actual route data
        renderItem={renderDayItem}
        keyExtractor={(item) => item.day.toString()}
        contentContainerStyle={styles.listContainer}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  listContainer: {
    padding: 16,
  },
  dayItem: {
    backgroundColor: '#f8f8f8',
    borderRadius: 8,
    padding: 16,
    marginBottom: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  dayHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  dayNumber: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  distance: {
    fontSize: 16,
    color: '#666',
  },
  routeText: {
    fontSize: 16,
    color: '#444',
    marginBottom: 8,
  },
  detailsContainer: {
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#eee',
  },
  detailsTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  directionText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
    marginLeft: 8,
  },
  hotelText: {
    fontSize: 14,
    color: '#666',
    marginTop: 8,
    fontStyle: 'italic',
  },
});

export default DestinationView; 