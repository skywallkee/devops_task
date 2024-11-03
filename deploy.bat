@echo off
setlocal enabledelayedexpansion

:: Check if the stack is running and remove it if it exists
docker stack ls | findstr flask-mongo >nul
if %errorlevel% equ 0 (
    echo Removing existing stack flask-mongo...
    docker stack rm flask-mongo
    timeout /t 5 /nobreak
) else (
    echo Stack flask-mongo is not running.
)

:: Load environment variables from .env file
for /f "tokens=1,2 delims==" %%i in (.env) do (
    set %%i=%%j
)

:: Build the Flask APP image
docker build -t flask-mongo-app ./app

timeout /t 5 /nobreak

:: Deploy the stack with the loaded environment variables
docker stack deploy -c docker-compose.yml flask-mongo

endlocal