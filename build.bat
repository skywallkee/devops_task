@echo off
setlocal enabledelayedexpansion

:: Load environment variables from .env file
for /f "tokens=1,2 delims==" %%i in (.env) do (
    set %%i=%%j
)

:: Build the Flask APP image
docker build -t flask-mongo-app:latest ./app

timeout /t 5 /nobreak

:: Check if the image exists in Minikube and delete it if it already does
set image_name=
for /f "delims=" %%i in ('minikube ssh "docker images flask-mongo-app --format {{.Repository}}:{{.Tag}}"') do set "image_name=%%i"
if defined image_name (
    echo Image found: %image_name%
    echo Deleting image...
    minikube ssh "docker rmi %image_name%"
) else (
    echo No image named 'flask-mongo-app' found in Minikube, adding new image...
)

timeout /t 5 /nobreak

:: Load the new image into Minikube
minikube image load flask-mongo-app:latest