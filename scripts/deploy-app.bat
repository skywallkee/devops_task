:: Deploy the application stack to either Docker Swarm or Kubernetes
@echo off
setlocal enabledelayedexpansion


:: Retrieve the deployment target from the first argument
if "%1"=="" (
    echo Usage: deploy-app.bat ^[docker^|k8s^]
    exit /b 1
)
set DEPLOY_TARGET=%1


:: Deploy the application based on the deployment target
if "%DEPLOY_TARGET%"=="docker" (
    echo Deploying the application stack to Docker Swarm...

    :: Check if the stack is running and remove it if it exists
    docker stack ls | findstr flask-mongo >nul
    if %errorlevel% equ 0 (
        echo Removing existing stack flask-mongo...
        docker stack rm flask-mongo
        timeout /t 8 /nobreak
    ) else (
        echo Stack flask-mongo is not running.
    )

    :: Load environment variables from .env file
    for /f "tokens=1,2 delims==" %%i in (..\.env) do (
        set %%i=%%j
    )

    :: Deploy the stack with the loaded environment variables
    docker stack deploy -c ..\docker-compose.yml flask-mongo

) else if "%DEPLOY_TARGET%"=="k8s" (
    :: Deploy the application to Kubernetes
    kubectl apply -f ..\k8s\app\deployment.yaml
) else (
    echo Invalid parametere. Use "docker" or "k8s".
    exit /b 1
)

endlocal