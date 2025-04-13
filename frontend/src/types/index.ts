export interface Route {
  day: number;
  startLocation: string;
  endLocation: string;
  distance: number;
  hotel: string;
  coordinates: {
    latitude: number;
    longitude: number;
  };
  directions: string[];
}

export interface Weather {
  temperature: number;
  condition: string;
  precipitation: number;
  windSpeed: number;
  windDirection: number;
  cloudCover: number;
  uvIndex: number;
  timestamp: number;
}

export interface Lodging {
  name: string;
  description: string;
  coordinates: {
    latitude: number;
    longitude: number;
  };
  amenities: string[];
  contact: {
    phone: string;
    email: string;
  };
  checkInTime: string;
  checkOutTime: string;
}

export interface Settings {
  distanceUnit: 'km' | 'miles';
  trackingEnabled: boolean;
  offlineMaps: {
    downloaded: boolean;
    selectedMap: string;
    availableMaps: string[];
  };
  weatherOptions: {
    showPrecipitation: boolean;
    showWind: boolean;
    showClouds: boolean;
    showUVIndex: boolean;
  };
} 