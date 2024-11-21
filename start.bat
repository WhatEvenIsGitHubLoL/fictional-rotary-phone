@echo off
setlocal

echo Starting Calculator Application Setup...

echo.
echo Starting backend server...
taskkill /F /IM python.exe /FI "WINDOWTITLE eq backend" > nul 2>&1
start "backend" cmd /k "cd backend && python main.py"

echo Waiting for backend to initialize (5 seconds)...
ping -n 6 127.0.0.1 > nul

echo Verifying backend is running...
curl -s http://localhost:5883 > nul
if errorlevel 1 (
    echo Backend failed to start! Please check the backend window for errors.
    goto ERROR_EXIT
)
echo Backend is running successfully.

echo.
echo Starting frontend application...
taskkill /F /IM flutter.exe /FI "WINDOWTITLE eq frontend" > nul 2>&1
start "frontend" cmd /k "cd frontend && flutter run -d edge --web-port 3000"

echo.
echo Setup complete! The calculator should open in your browser shortly.
echo Note: To stop the application, close both the backend and frontend windows.
echo.
echo Press any key to exit this window...
pause > nul
exit /b 0

:ERROR_EXIT
echo.
echo Setup failed! Please check the error messages above.
echo Press any key to exit...
pause > nul
exit /b 1
