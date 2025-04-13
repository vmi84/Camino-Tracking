import React, { useState, useEffect } from 'react';
import axios from 'axios';

interface Route {
  id: string;
  day: number;
  startLocation: string;
  endLocation: string;
  distance: number;
  directions: string[];
  hotel: {
    name: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
    directions: string;
  };
}

const RouteList: React.FC = () => {
  const [routes, setRoutes] = useState<Route[]>([]);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchRoutes = async () => {
      try {
        const response = await axios.get('http://localhost:3000/api/routes');
        setRoutes(response.data);
        setLoading(false);
      } catch (err) {
        setError('Failed to fetch routes');
        setLoading(false);
      }
    };

    fetchRoutes();
  }, []);

  const handleDaySelect = (day: number) => {
    setSelectedDay(day);
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div className="route-list">
      <h2>Camino de Santiago Routes</h2>
      <div className="days-list">
        {routes.map((route) => (
          <button
            key={route.id}
            className={`day-button ${selectedDay === route.day ? 'selected' : ''}`}
            onClick={() => handleDaySelect(route.day)}
          >
            Day {route.day}: {route.startLocation} to {route.endLocation}
          </button>
        ))}
      </div>
      {selectedDay && (
        <div className="route-details">
          <h3>Day {selectedDay} Details</h3>
          {routes
            .filter((route) => route.day === selectedDay)
            .map((route) => (
              <div key={route.id}>
                <p>Distance: {route.distance} km</p>
                <h4>Directions:</h4>
                <ol>
                  {route.directions.map((direction, index) => (
                    <li key={index}>{direction}</li>
                  ))}
                </ol>
                <h4>Hotel: {route.hotel.name}</h4>
                <p>{route.hotel.directions}</p>
                <p>
                  Coordinates: {route.hotel.coordinates.latitude}° N,{' '}
                  {route.hotel.coordinates.longitude}° W
                </p>
              </div>
            ))}
        </div>
      )}
    </div>
  );
};

export default RouteList; 