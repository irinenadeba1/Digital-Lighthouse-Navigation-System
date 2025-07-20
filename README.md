# Digital Lighthouse Navigation System

A comprehensive blockchain-based maritime navigation and safety system built on Stacks using Clarity smart contracts.

## System Overview

The Digital Lighthouse Navigation System consists of five interconnected smart contracts that work together to ensure safe maritime navigation:

### 1. Maritime Traffic Monitoring Contract (`maritime-traffic.clar`)
- Tracks vessel movements and positions
- Monitors collision risks between ships
- Maintains vessel registry and status updates
- Calculates safe distances and alerts

### 2. Weather Condition Contract (`weather-conditions.clar`)
- Provides real-time weather data updates
- Tracks storm systems and visibility conditions
- Issues weather warnings and advisories
- Maintains historical weather patterns

### 3. Navigation Assistance Contract (`navigation-assistance.clar`)
- Guides vessels through dangerous waters
- Provides route recommendations
- Manages navigation waypoints
- Issues navigation warnings and updates

### 4. Emergency Beacon Contract (`emergency-beacon.clar`)
- Coordinates search and rescue operations
- Manages distress signals and emergency alerts
- Tracks rescue vessel deployment
- Maintains emergency contact information

### 5. Maintenance Scheduling Contract (`maintenance-scheduling.clar`)
- Ensures lighthouse equipment functionality
- Schedules regular maintenance tasks
- Tracks equipment status and repairs
- Manages maintenance crew assignments

## Key Features

- **Decentralized Maritime Safety**: All navigation data stored on blockchain
- **Real-time Monitoring**: Continuous tracking of vessels and conditions
- **Emergency Response**: Automated distress signal handling
- **Predictive Maintenance**: Proactive equipment monitoring
- **Weather Integration**: Real-time weather condition updates

## Data Structures

### Vessel Information
- Vessel ID, name, type, and dimensions
- Current position (latitude/longitude)
- Speed, heading, and destination
- Emergency contact information

### Weather Data
- Temperature, wind speed/direction
- Visibility conditions
- Storm tracking and intensity
- Sea state and wave height

### Navigation Points
- Waypoint coordinates and descriptions
- Hazard locations and warnings
- Safe passage routes
- Restricted areas

## Security Features

- Multi-signature authorization for critical operations
- Role-based access control (lighthouse operators, vessel captains, emergency services)
- Immutable audit trail for all maritime activities
- Encrypted emergency communications

## Usage

### For Lighthouse Operators
1. Update weather conditions and visibility
2. Monitor vessel traffic in coverage area
3. Issue navigation warnings and advisories
4. Schedule and track maintenance activities

### For Vessel Captains
1. Register vessel and update position
2. Receive navigation assistance and warnings
3. Access weather condition updates
4. Activate emergency beacon if needed

### For Emergency Services
1. Monitor distress signals and alerts
2. Coordinate search and rescue operations
3. Access vessel information and last known positions
4. Communicate with vessels in distress

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Run `npm test` to execute test suite
5. Deploy contracts using `clarinet deploy`

## Testing

The system includes comprehensive tests covering:
- Contract deployment and initialization
- Vessel registration and tracking
- Weather condition updates
- Emergency beacon activation
- Maintenance scheduling

Run tests with: `npm test`

## Contributing

Please read the PR-DETAILS.md file for contribution guidelines and development standards.
