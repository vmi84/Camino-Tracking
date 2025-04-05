# Camino - Pilgrimage Tracking App

A mobile application to track and manage your Camino de Santiago pilgrimage journey.

## Features

- Route mapping of the French Way (~775km)
- GPS-based progress tracking
- Town and village information
- Lodging management
- Trip planning
- Offline functionality
- Multi-language support

## Technical Stack

### Backend
- Node.js with Express
- TypeScript
- MongoDB
- Jest for testing

### Frontend
- React Native
- TypeScript
- Redux for state management
- React Navigation
- React Native Maps

## Getting Started

### Prerequisites
- Node.js (v14 or higher)
- MongoDB
- React Native development environment

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vmi84/Camino.git
cd Camino
```

2. Install backend dependencies:
```bash
cd backend
npm install
```

3. Install frontend dependencies:
```bash
cd ../frontend
npm install
```

4. Set up environment variables:
```bash
cp .env.example .env
```

5. Start the development servers:
```bash
# Backend
cd backend
npm run dev

# Frontend
cd frontend
npm start
```

## Development

- Backend API documentation: `/docs/api`
- Frontend component library: `/docs/components`
- Testing: `npm test`
- Code coverage: `npm run test:coverage`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### v0.0.1 (2024-04-05)
- Initial project setup
- Basic backend structure with Express and TypeScript
- Testing infrastructure with Jest
- Project documentation and requirements
