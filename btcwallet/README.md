# BTC Wallet

BTC Wallet's Backend service.

## Features

- **First Wallet**: Get the first wallet
- **Wallet by Address**: Get wallet by its address
- **All Wallets**: Retrieve all available wallets
- **Health Check**: Service health endpoint
- **RESTful API**: Clean REST endpoints with JSON responses

## Technology Stack

- **Java 17**
- **Spring Boot 3.2.0**
- **Maven** (Build tool)
- **JUnit 5** (Testing framework)
- **Spring Boot Test** (Integration testing) 

## Project Structure

```
src/
├── main/
│   ├── java/com/example/btcwallet/
│   │   ├── BTCWalletApplication.java    # Main application class
│   │   ├── controller/
│   │   │   └── BTCWalletController.java      # REST API endpoints
│   │   ├── service/
│   │   │   └── BTCWalletService.java         # Business logic
│   │   └── model/
│   │       └── BTCWallet.java                # Data model
│   └── resources/
│       └── application.properties        # Configuration
└── test/
    └── java/com/example/btcwallet/
        ├── BTCWalletOfDayApplicationTests.java    # Application tests
        ├── controller/
        │   └── BTCWalletControllerTest.java       # Controller tests
        └── service/
            └── BTCWalletServiceTest.java          # Service tests
```

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6 or higher

### Building the Project

```bash
# Navigate to the service directory
cd btcwallet

# Build the project
mvn clean install
```

### Running the Application

```bash
# Run the application
mvn spring-boot:run
```

The application will start on `http://localhost:8001`

### Running Tests

```bash
# Run all tests
mvn test

# Run tests with coverage
mvn test jacoco:report
```

## Configuration

The application can be configured through `src/main/resources/application.properties`:

- **Server Port**: Default is 8001
- **Logging**: Configured for INFO level
- **Jackson**: Configured to exclude null values and format dates properly

## Development

### Running in Development Mode

The application includes Spring Boot DevTools for enhanced development experience:

- Automatic restart on code changes
- Live reload capabilities
- Enhanced error pages

## Docker Support

The service includes a multi-stage Dockerfile for optimized container builds:

```bash
# Build Docker image
docker build -t btcwallet-service .

# Run container
docker run -p 8001:8001 btcwallet-service
```

### Docker Features

✅ **Multi-stage build**: Optimized image size  
✅ **Security**: Non-root user execution  
✅ **Health checks**: Built-in health monitoring  
✅ **Alpine base**: Minimal attack surface  

## Deployment

### Building for Production

```bash
# Create executable JAR
mvn clean package

# The JAR file will be created in target/ directory
java -jar target/btc-wallet-service-1.0.0.jar
```

### Container Deployment

```bash
# Build and run with Docker
docker build -t btcwallet-service .
docker run -p 8001:8001 btcwallet-service
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License.
