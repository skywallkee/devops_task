:: Deploy the infrastructure to Kubernetes
@echo off
setlocal


:: Load the deployment service from the first argument
if "%~1"=="" (
    echo Usage: %0 [component]
    echo Components: app, logging, mongodb, monitoring, all
    exit /b 1
)
set COMPONENT=%~1


:: Deploy based on the provided parameter
if "%COMPONENT%"=="app" (
    call :deploy_component app
    kubectl rollout restart deployment flask-mongo-app
    echo.
    goto :eof
) else if "%COMPONENT%"=="logging" (
    echo logggggg
    call :deploy_subcomponents logging volumes
    call :deploy_subcomponents logging filebeat
    for /f "tokens=1-4 delims=:. " %%a in ('echo %date% %time%') do set datetime=%%aT%%b:%%c:%%d
    kubectl patch daemonset filebeat -p "{\"spec\": {\"template\": {\"metadata\": {\"annotations\": {\"kubectl.kubernetes.io/restartedAt\": \"%datetime%\"}}}}}"
    echo.
    call :deploy_subcomponents logging elasticsearch
    kubectl rollout restart statefulset elasticsearch
    echo.
    call :deploy_subcomponents logging kibana
    kubectl rollout restart deployment kibana
    echo.
    goto :eof
) else if "%COMPONENT%"=="mongodb" (
    call :deploy_component mongodb
    kubectl rollout restart deployment mongodb
    echo.
    goto :eof
) else if "%COMPONENT%"=="monitoring" (
    call :deploy_subcomponents monitoring mongodb-exporter
    kubectl rollout restart deployment mongodb-exporter
    echo.
    call :deploy_subcomponents monitoring prometheus
    kubectl rollout restart deployment prometheus
    echo.
    goto :eof
) else if "%COMPONENT%"=="all" (
    call :deploy_subcomponents logging volumes
    call :deploy_component app
    kubectl rollout restart deployment flask-mongo-app
    echo.
    call :deploy_subcomponents logging filebeat
    for /f "tokens=1-4 delims=:. " %%a in ('echo %date% %time%') do set datetime=%%aT%%b:%%c:%%d
    kubectl patch daemonset filebeat -p "{\"spec\": {\"template\": {\"metadata\": {\"annotations\": {\"kubectl.kubernetes.io/restartedAt\": \"%datetime%\"}}}}}"
    echo.
    call :deploy_subcomponents logging elasticsearch
    kubectl rollout restart statefulset elasticsearch
    echo.
    call :deploy_subcomponents logging kibana
    kubectl rollout restart deployment kibana
    echo.
    call :deploy_component mongodb
    kubectl rollout restart deployment mongodb
    echo.
    call :deploy_subcomponents monitoring mongodb-exporter
    kubectl rollout restart deployment mongodb-exporter
    echo.
    call :deploy_subcomponents monitoring prometheus
    kubectl rollout restart deployment prometheus
    echo.
    goto :eof
) else (
    echo Invalid component: %COMPONENT%
    exit /b 1
)


:: Function to deploy a component
:deploy_component
if exist "..\k8s\%1" (
    echo Deploying %1...
    for %%f in (..\k8s\%1\*serviceaccount*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\*rolebind*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\*persistentvolume*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\*persistentvolumeclaim*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\*secret*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\*configmap*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\*.yaml) do (
        echo %%~nxf | findstr /v /i "serviceaccount rolebind persistentvolume secret configmap" >nul
        if not errorlevel 1 (
            kubectl apply -f %%f
        )
    )
    echo Successfully deployed %1!
    echo.
) else (
    echo Component %1 not found!
)
goto :eof


:: Function to deploy subcomponents
:deploy_subcomponents
if exist "..\k8s\%1\%2" (
    echo Deploying %1 %2...
    for %%f in (..\k8s\%1\%2\*serviceaccount*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\%2\*rolebind*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\%2\*persistentvolume*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\%2\*persistentvolumeclaim*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\%2\*secret*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\%2\*configmap*.yaml) do kubectl apply -f %%f
    for %%f in (..\k8s\%1\%2\*.yaml) do (
        echo %%~nxf | findstr /v /i "serviceaccount rolebind persistentvolume secret configmap" >nul
        if %errorlevel% equ 1 kubectl apply -f %%f
    )
    echo Successfully deployed %2!
    echo.
) else (
    echo Subcomponent %2 of %1 not found!
)
goto :eof

endlocal