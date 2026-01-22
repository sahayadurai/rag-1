#!/bin/bash

# Quick Start Script - Minimal checks, fast execution
# Use this if you've already set up .env and just want to run

set -e

CONTAINER_NAME="rag-app"
PORT="8501"

echo "🚀 Quick Starting RAG_4_Scratch..."

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "Please create .env file with:"
    echo "  OPENROUTER_API_KEY=your_key_here"
    exit 1
fi

# Stop and remove existing container if it exists
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

# Build and run with docker-compose if available, otherwise use docker
if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then
    if [ -f "docker-compose.yml" ]; then
        echo "📦 Using Docker Compose..."
        if command -v docker-compose >/dev/null 2>&1; then
            docker-compose up -d --build
        else
            docker compose up -d --build
        fi
    else
        echo "📦 Building Docker image..."
        docker build -t rag-4-scratch:latest .
        echo "🚀 Starting container..."
        docker run -d --name ${CONTAINER_NAME} -p ${PORT}:8501 --env-file .env -v $(pwd)/vector_store:/app/vector_store rag-4-scratch:latest
    fi
else
    echo "📦 Building Docker image..."
    docker build -t rag-4-scratch:latest .
    echo "🚀 Starting container..."
    docker run -d --name ${CONTAINER_NAME} -p ${PORT}:8501 --env-file .env -v $(pwd)/vector_store:/app/vector_store rag-4-scratch:latest
fi

echo "✅ Application is running!"
echo "🌐 Open http://localhost:${PORT} in your browser"
echo ""
echo "View logs: docker logs -f ${CONTAINER_NAME}"
echo "Stop: docker stop ${CONTAINER_NAME}"

# Try to open browser
sleep 2
if command -v open >/dev/null 2>&1; then
    open "http://localhost:${PORT}"
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "http://localhost:${PORT}"
fi
