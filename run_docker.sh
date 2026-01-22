#!/bin/bash

# ============================================
# RAG_4_Scratch - Docker Auto-Run Script
# ============================================
# This script automates the Docker setup and running process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="rag-4-scratch"
CONTAINER_NAME="rag-app"
IMAGE_NAME="${PROJECT_NAME}:latest"
PORT="8501"
ENV_FILE=".env"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Docker is running
docker_running() {
    docker info >/dev/null 2>&1
}

# Function to check if port is in use
port_in_use() {
    lsof -i :${PORT} >/dev/null 2>&1 || nc -z localhost ${PORT} >/dev/null 2>&1
}

# Function to open browser (cross-platform)
open_browser() {
    local url="http://localhost:${PORT}"
    print_info "Opening browser at ${url}..."
    
    if command_exists open; then
        # macOS
        open "${url}"
    elif command_exists xdg-open; then
        # Linux
        xdg-open "${url}"
    elif command_exists start; then
        # Windows (Git Bash)
        start "${url}"
    else
        print_warning "Could not automatically open browser. Please manually open: ${url}"
    fi
}

# Main execution
main() {
    echo ""
    echo "============================================"
    echo "  RAG_4_Scratch - Docker Setup & Run"
    echo "============================================"
    echo ""

    # Step 1: Check Docker installation
    print_info "Checking Docker installation..."
    if ! command_exists docker; then
        print_error "Docker is not installed or not in PATH."
        echo "Please install Docker from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker is installed"

    # Step 2: Check if Docker is running
    print_info "Checking if Docker daemon is running..."
    if ! docker_running; then
        print_error "Docker daemon is not running."
        echo "Please start Docker Desktop and try again."
        exit 1
    fi
    print_success "Docker daemon is running"

    # Step 3: Check/create .env file
    print_info "Checking for .env file..."
    if [ ! -f "${ENV_FILE}" ]; then
        print_warning ".env file not found. Creating one..."
        echo ""
        echo "Enter your OpenRouter API key:"
        read -p "OPENROUTER_API_KEY: " api_key
        if [ -z "$api_key" ]; then
            print_error "API key cannot be empty. Exiting."
            exit 1
        fi
        echo "OPENROUTER_API_KEY=${api_key}" > "${ENV_FILE}"
        print_success ".env file created with OPENROUTER_API_KEY"
    else
        # Check if any API key is set
        has_openrouter=$(grep -q "OPENROUTER_API_KEY=" "${ENV_FILE}" && ! grep -q "OPENROUTER_API_KEY=$" "${ENV_FILE}" && ! grep -q "OPENROUTER_API_KEY=your" "${ENV_FILE}" && echo "yes" || echo "no")
        
        if [ "$has_openrouter" = "no" ]; then
            print_warning "No valid OpenRouter API key found in .env file"
            echo ""
            echo "Enter your OpenRouter API key:"
            read -p "OPENROUTER_API_KEY: " api_key
            if [ -z "$api_key" ]; then
                print_error "API key cannot be empty. Exiting."
                exit 1
            fi

            if grep -q "OPENROUTER_API_KEY=" "${ENV_FILE}"; then
                sed -i.bak "s/OPENROUTER_API_KEY=.*/OPENROUTER_API_KEY=${api_key}/" "${ENV_FILE}"
            else
                echo "OPENROUTER_API_KEY=${api_key}" >> "${ENV_FILE}"
            fi
            print_success "OPENROUTER_API_KEY updated in .env file"
        else
            if [ "$has_openrouter" = "yes" ]; then
                print_success ".env file exists and contains OPENROUTER_API_KEY"
            fi
        fi
    fi

    # Step 4: Check for existing container
    print_info "Checking for existing container..."
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
            print_warning "Container '${CONTAINER_NAME}' is already running"
            read -p "Do you want to restart it? (y/n): " restart_choice
            if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
                print_info "Stopping existing container..."
                docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
                docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true
                print_success "Container removed"
            else
                print_info "Using existing container. Access at http://localhost:${PORT}"
                open_browser
                exit 0
            fi
        else
            print_info "Removing stopped container..."
            docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true
            print_success "Stopped container removed"
        fi
    fi

    # Step 5: Check if port is in use
    print_info "Checking if port ${PORT} is available..."
    if port_in_use; then
        print_warning "Port ${PORT} is already in use"
        read -p "Do you want to use a different port? (y/n): " change_port
        if [[ "$change_port" =~ ^[Yy]$ ]]; then
            read -p "Enter new port number: " PORT
            if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
                print_error "Invalid port number. Using default port 8501."
                PORT="8501"
            fi
        else
            print_error "Cannot proceed. Please free port ${PORT} or choose a different port."
            exit 1
        fi
    fi
    print_success "Port ${PORT} is available"

    # Step 6: Check for docker-compose (preferred method)
    print_info "Checking for Docker Compose..."
    USE_COMPOSE=false
    if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
        if [ -f "docker-compose.yml" ]; then
            USE_COMPOSE=true
            print_success "Docker Compose found. Using docker-compose.yml"
        else
            print_warning "Docker Compose found but docker-compose.yml not found. Using Docker CLI instead."
        fi
    else
        print_info "Docker Compose not found. Using Docker CLI"
    fi

    # Step 7: Build Docker image
    print_info "Building Docker image (this may take several minutes)..."
    if [ "$USE_COMPOSE" = true ]; then
        if command_exists docker-compose; then
            docker-compose build
        else
            docker compose build
        fi
    else
        docker build -t "${IMAGE_NAME}" .
    fi
    print_success "Docker image built successfully"

    # Step 8: Create vector_store directory if it doesn't exist
    print_info "Ensuring vector_store directory exists..."
    mkdir -p vector_store
    print_success "vector_store directory ready"

    # Step 9: Run the container
    print_info "Starting container..."
    if [ "$USE_COMPOSE" = true ]; then
        # Modify docker-compose to use custom port if needed
        if [ "$PORT" != "8501" ]; then
            print_warning "Note: docker-compose.yml uses port 8501. For custom port, edit docker-compose.yml or use Docker CLI method."
        fi
        if command_exists docker-compose; then
            docker-compose up -d
        else
            docker compose up -d
        fi
    else
        docker run -d \
            --name "${CONTAINER_NAME}" \
            -p "${PORT}:8501" \
            --env-file "${ENV_FILE}" \
            -v "$(pwd)/vector_store:/app/vector_store" \
            "${IMAGE_NAME}"
    fi
    print_success "Container started successfully"

    # Step 10: Wait for application to be ready
    print_info "Waiting for application to start (this may take a few seconds)..."
    sleep 5
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        print_error "Container failed to start. Checking logs..."
        docker logs "${CONTAINER_NAME}" 2>&1 | tail -20
        exit 1
    fi

    # Step 11: Display success message and open browser
    echo ""
    echo "============================================"
    print_success "Application is running!"
    echo "============================================"
    echo ""
    echo "Access the application at:"
    echo "  ${BLUE}http://localhost:${PORT}${NC}"
    echo ""
    echo "Useful commands:"
    echo "  View logs:    ${GREEN}docker logs -f ${CONTAINER_NAME}${NC}"
    echo "  Stop:        ${GREEN}docker stop ${CONTAINER_NAME}${NC}"
    echo "  Start:       ${GREEN}docker start ${CONTAINER_NAME}${NC}"
    echo "  Remove:      ${GREEN}docker rm -f ${CONTAINER_NAME}${NC}"
    if [ "$USE_COMPOSE" = true ]; then
        echo "  (or use:     ${GREEN}docker-compose down${NC})"
    fi
    echo ""

    # Open browser
    sleep 2
    open_browser
}

# Run main function
main "$@"
