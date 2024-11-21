# Advanced Calculator

A modern calculator application with a Flutter web frontend and Python FastAPI backend.

## Features

- Clean, modern Material Design UI
- Support for complex mathematical expressions with PEMDAS/BODMAS order
- Basic arithmetic operations (+, -, *, /, ^)
- Mathematical functions (sqrt, root, frac)
- Real-time calculation
- Calculation history
- Input validation
- Error handling
- Dark/Light theme support
- Responsive design
- API documentation
- Logging system

## Project Structure

```
calculator/
├── backend/
│   ├── main.py              # FastAPI backend application
│   ├── calculator_engine.py # Core calculation engine
│   ├── evaluator.py        # Expression evaluation logic
│   ├── operators.py        # Operator definitions
│   ├── parser.py           # Expression parser
│   ├── requirements.txt    # Python dependencies
│   └── logs/              # Application logs directory
└── frontend/
    ├── lib/
    │   └── main.dart       # Flutter frontend application
    ├── pubspec.yaml        # Flutter dependencies
    └── web/                # Web-specific files
```

## Running the Application

You can run the application either using Docker or by setting up the development environment locally.

### Option 1: Using Docker (Recommended for Production)

Prerequisites:
- Docker
- Docker Compose

1. Clone the repository and navigate to the project directory

2. Start the application using Docker Compose:
   ```bash
   docker-compose up -d
   ```

The services will be available at:
- Frontend: http://localhost:80
- Backend API: http://localhost:5883
- API Documentation: http://localhost:5883/docs

To stop the application:
```bash
docker-compose down
```

### Option 2: Local Development Setup

Prerequisites:
- Python 3.8 or higher
- Flutter SDK
- A modern web browser

#### Backend Setup

1. Create and activate a Python virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install Python dependencies:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

#### Frontend Setup

1. Install Flutter dependencies:
   ```bash
   cd frontend
   flutter pub get
   ```

#### Running Locally

1. Start the Backend:
   ```bash
   cd backend
   python main.py
   ```
   The API will be available at `http://localhost:5883`
   
   API Documentation will be available at:
   - Swagger UI: `http://localhost:5883/docs`
   - ReDoc: `http://localhost:5883/redoc`

2. Start the Frontend:
   ```bash
   cd frontend
   flutter run -d chrome
   ```
   The application will be available in your default web browser.

## API Endpoints

### POST /calculate

Evaluates mathematical expressions with support for complex operations.

Request body:
```json
{
  "expression": "string"
}
```

Example expressions:
- Basic arithmetic: `"2 + 3 * (4 - 1)"`
- Square root: `"sqrt(16)"`
- Nth root: `"root(27, 3)"` (cube root of 27)
- Fractions: `"frac(1, 2) + frac(3, 4)"` (1/2 + 3/4)
- Mixed operations: `"2 * sqrt(9) + frac(5, 2)"`

Response:
```json
{
  "result": number,
  "formatted_expression": "string"
}
```

### GET /

Root endpoint that returns API information and supported operations.

Response:
```json
{
  "message": "Advanced Calculator API is running",
  "version": "2.0.0",
  "documentation": "/docs",
  "supported_operations": [
    "Addition (+)",
    "Subtraction (-)",
    "Multiplication (*)",
    "Division (/)",
    "Exponentiation (^)",
    "Square root (sqrt)",
    "Nth root (root)",
    "Fractions (frac)"
  ]
}
```

## Error Handling

The application includes comprehensive error handling:

- Invalid expression syntax
- Division by zero
- Invalid function arguments
- Mismatched parentheses
- Network error handling
- Server error handling

## Logging

Backend logs are stored in `backend/logs/calculator.log` with rotation enabled:
- Maximum file size: 1MB
- Keeps last 5 log files
- Includes timestamps and log levels

When running with Docker, logs are persisted using a named volume and can be accessed within the container at `/app/logs`.

## Development

### Backend Development

The backend is built with FastAPI and includes:
- Type hints
- Pydantic models for validation
- Comprehensive error handling
- CORS configuration
- Environment variable support
- Logging system
- Mathematical expression parser
- Shunting yard algorithm for expression evaluation

### Frontend Development

The frontend is built with Flutter and includes:
- Material Design 3
- Responsive layout
- Theme support (light/dark)
- Input validation
- Error handling
- Calculation history
- Loading states

## Production Deployment

### Using Docker (Recommended)

1. Configure environment variables in docker-compose.yml if needed
2. Build and start the containers:
   ```bash
   docker-compose up -d --build
   ```

### Manual Deployment

#### Backend Deployment

1. Set environment variables:
   ```
   PORT=5883
   HOST=0.0.0.0
   ```

2. Use a production ASGI server:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 5883 --workers 4
   ```

#### Frontend Deployment

1. Build the web application:
   ```bash
   cd frontend
   flutter build web --release
   ```

2. Deploy the contents of `build/web` to your web server

## Security Considerations

- In production, configure CORS with specific origins
- Use HTTPS in production
- Implement rate limiting if needed
- Add authentication if required
- Sanitize and validate all inputs
- When using Docker, review container security best practices

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
