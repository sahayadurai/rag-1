@echo off
REM ============================================
REM RAG_4_Scratch - Docker Auto-Run Script (Windows)
REM ============================================

setlocal enabledelayedexpansion

set CONTAINER_NAME=rag-app
set IMAGE_NAME=rag-4-scratch:latest
set PORT=8501
set ENV_FILE=.env

echo.
echo ============================================
echo   RAG_4_Scratch - Docker Setup ^& Run
echo ============================================
echo.

REM Check if Docker is installed
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not installed or not in PATH.
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    exit /b 1
)
echo [OK] Docker is installed

REM Check if Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker daemon is not running.
    echo Please start Docker Desktop and try again.
    exit /b 1
)
echo [OK] Docker daemon is running

REM Check/create .env file
if not exist "%ENV_FILE%" (
    echo [WARNING] .env file not found. Creating one...
    echo.
    echo Enter your OpenRouter API key:
    set /p API_KEY="OPENROUTER_API_KEY: "
    if "!API_KEY!"=="" (
        echo [ERROR] API key cannot be empty. Exiting.
        exit /b 1
    )
    echo OPENROUTER_API_KEY=!API_KEY! > "%ENV_FILE%"
    echo [OK] .env file created with OPENROUTER_API_KEY
) else (
    echo [OK] .env file exists
)

REM Check for existing container
docker ps -a --format "{{.Names}}" | findstr /C:"%CONTAINER_NAME%" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    docker ps --format "{{.Names}}" | findstr /C:"%CONTAINER_NAME%" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [WARNING] Container '%CONTAINER_NAME%' is already running
        set /p RESTART="Do you want to restart it? (y/n): "
        if /i "!RESTART!"=="y" (
            echo Stopping existing container...
            docker stop %CONTAINER_NAME% >nul 2>&1
            docker rm %CONTAINER_NAME% >nul 2>&1
            echo [OK] Container removed
        ) else (
            echo Using existing container. Access at http://localhost:%PORT%
            start http://localhost:%PORT%
            exit /b 0
        )
    ) else (
        echo Removing stopped container...
        docker rm %CONTAINER_NAME% >nul 2>&1
        echo [OK] Stopped container removed
    )
)

REM Create vector_store directory
if not exist "vector_store" mkdir vector_store

REM Check for docker-compose
where docker-compose >nul 2>&1
set USE_COMPOSE=0
if %ERRORLEVEL% EQU 0 (
    if exist "docker-compose.yml" (
        set USE_COMPOSE=1
        echo [OK] Using Docker Compose
    )
)

REM Build Docker image
echo.
echo Building Docker image (this may take several minutes)...
if !USE_COMPOSE! EQU 1 (
    docker-compose build
) else (
    docker build -t %IMAGE_NAME% .
)
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to build Docker image
    exit /b 1
)
echo [OK] Docker image built successfully

REM Run the container
echo.
echo Starting container...
if !USE_COMPOSE! EQU 1 (
    docker-compose up -d
) else (
    docker run -d --name %CONTAINER_NAME% -p %PORT%:8501 --env-file %ENV_FILE% -v "%CD%\vector_store:/app/vector_store" %IMAGE_NAME%
)
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start container
    exit /b 1
)
echo [OK] Container started successfully

REM Wait a bit for application to start
echo.
echo Waiting for application to start...
timeout /t 5 /nobreak >nul

REM Check if container is running
docker ps --format "{{.Names}}" | findstr /C:"%CONTAINER_NAME%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Container failed to start. Checking logs...
    docker logs %CONTAINER_NAME%
    exit /b 1
)

REM Success message
echo.
echo ============================================
echo [SUCCESS] Application is running!
echo ============================================
echo.
echo Access the application at:
echo   http://localhost:%PORT%
echo.
echo Useful commands:
echo   View logs:    docker logs -f %CONTAINER_NAME%
echo   Stop:        docker stop %CONTAINER_NAME%
echo   Start:       docker start %CONTAINER_NAME%
echo   Remove:      docker rm -f %CONTAINER_NAME%
if !USE_COMPOSE! EQU 1 (
    echo   (or use:     docker-compose down)
)
echo.

REM Open browser
timeout /t 2 /nobreak >nul
start http://localhost:%PORT%

endlocal
