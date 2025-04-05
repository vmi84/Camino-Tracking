import React, { useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import WelcomeScreen from './views/WelcomeScreen';
import RouteView from './views/RouteView';
import LodgingView from './views/LodgingView';
import DestinationView from './views/DestinationView';
import SettingsView from './views/SettingsView';

const Stack = createNativeStackNavigator();

const App: React.FC = () => {
  const [hasSeenWelcome, setHasSeenWelcome] = useState(false);

  if (!hasSeenWelcome) {
    return (
      <WelcomeScreen
        onGetStarted={() => setHasSeenWelcome(true)}
      />
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Route"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#4CAF50',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}
      >
        <Stack.Screen
          name="Route"
          component={RouteView}
          options={{ title: 'Your Journey' }}
        />
        <Stack.Screen
          name="Lodging"
          component={LodgingView}
          options={{ title: 'Accommodation' }}
        />
        <Stack.Screen
          name="Destinations"
          component={DestinationView}
          options={{ title: 'Daily Routes' }}
        />
        <Stack.Screen
          name="Settings"
          component={SettingsView}
          options={{ title: 'Settings' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App; 