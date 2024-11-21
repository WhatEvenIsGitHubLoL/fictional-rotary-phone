# Advanced Calculator

A modern calculator application with a Flutter web frontend and Python FastAPI backend.

## Features

- Clean, modern Material Design UI
- Support for basic arithmetic operations (addition, subtraction, multiplication, division)
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
│   ├── requirements.txt     # Python dependencies
│   └── logs/               # Application logs directory
└── frontend/
    ├── lib/
    │   └── main.dart       # Flutter frontend application
    ├── pubspec.yaml        # Flutter dependencies
    └── web/                # Web-specific files
```

## Prerequisites

- Python 3.8 or higher
- Flutter SDK
- A modern web browser

## Installation

### Backend Setup

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

### Frontend Setup

1. Install Flutter dependencies:
   ```bash
   cd frontend
   flutter pub get
   ```

## Running the Application

### Start the Backend

1. From the backend directory:
   ```bash
   python main.py
   ```
   The API will be available at `http://localhost:5883`
   
   API Documentation will be available at:
   - Swagger UI: `http://localhost:5883/docs`
   - ReDoc: `http://localhost:5883/redoc`

### Start the Frontend

1. From the frontend directory:
   ```bash
   flutter run -d chrome
   ```
   The application will be available in your default web browser.

## API Endpoints

### POST /calculate

Performs arithmetic calculations.

Request body:
```json
{
  "operation": "add | subtract | multiply | divide",
  "num1": number,
  "num2": number
}
```

Response:
```json
{
  "result": number
}
```

## Error Handling

The application includes comprehensive error handling:

- Input validation for numbers
- Division by zero protection
- Network error handling
- Invalid operation handling
- Server error handling

## Logging

Backend logs are stored in `backend/logs/calculator.log` with rotation enabled:
- Maximum file size: 1MB
- Keeps last 5 log files
- Includes timestamps and log levels

## Development

### Backend Development

The backend is built with FastAPI and includes:
- Type hints
- Pydantic models for validation
- Comprehensive error handling
- CORS configuration
- Environment variable support
- Logging system

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

### Backend Deployment

1. Set environment variables:
   ```
   PORT=5883
   HOST=0.0.0.0
   ```

2. Use a production ASGI server:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 5883 --workers 4
   ```

### Frontend Deployment

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
