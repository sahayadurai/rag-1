# Docker Setup Guide - Step by Step

This guide will walk you through running the RAG_4_Scratch project using Docker.

## Quick Start (TL;DR)

### 🚀 Automated Scripts (Recommended)

**Linux/macOS:**
```bash
# Full-featured script with checks and prompts
./run_docker.sh

# OR quick start (minimal checks, faster)
./quick_start.sh
```

**Windows:**
```batch
# Double-click or run in Command Prompt
run_docker.bat
```

### Manual Methods

**Using Docker Compose (Easiest):**
```bash
# 1. Create .env file with your OpenRouter API key
echo "OPENROUTER_API_KEY=your_key_here" > .env

# 2. Build and run
docker-compose up -d --build

# 3. Open browser
open http://localhost:8501
```

**Using Docker CLI:**
```bash
# 1. Create .env file with your OpenRouter API key
echo "OPENROUTER_API_KEY=your_key_here" > .env

# 2. Build image
docker build -t rag-4-scratch:latest .

# 3. Run container
docker run -d --name rag-app -p 8501:8501 --env-file .env -v $(pwd)/vector_store:/app/vector_store rag-4-scratch:latest

# 4. Open browser
open http://localhost:8501
```

---

## Prerequisites

- Docker installed on your system ([Download Docker](https://www.docker.com/products/docker-desktop))
- **OpenRouter API key** (supports multiple providers like OpenAI, Anthropic, Google, etc.)
- Optional: HuggingFace token (if you plan to use HuggingFace models)

---

## Available Scripts

The project includes automated scripts to make running easier:

1. **`run_docker.sh`** (Linux/macOS) - Full-featured script with:
   - Docker installation checks
   - .env file creation/validation
   - Port conflict detection
   - Existing container handling
   - Automatic browser opening
   - Comprehensive error handling

2. **`quick_start.sh`** (Linux/macOS) - Minimal script for quick execution:
   - Assumes .env already exists
   - Faster startup
   - Less interactive

3. **`run_docker.bat`** (Windows) - Windows batch script with similar features

**To use the scripts:**
- Make sure they're executable: `chmod +x run_docker.sh quick_start.sh`
- Run: `./run_docker.sh` or `./quick_start.sh`

---

## Two Methods to Run

This guide provides two methods:
1. **Docker CLI** (Manual commands) - More control, good for learning
2. **Docker Compose** (Recommended) - Easier and faster

Choose the method you prefer!

---

## Method 1: Docker Compose (Recommended - Easier)

### Step 1: Navigate to Project Directory

```bash
cd /Users/sahayamuthukanignanadurai/RAG_4_Scratch
```

### Step 2: Create Environment File (.env)

Create a `.env` file in the project root:

```bash
touch .env
```

Edit the `.env` file and add your API keys:

**OpenRouter** (recommended if you want access to multiple providers)
```bash
OPENROUTER_API_KEY=your_openrouter_api_key_here
```

**Optional: HuggingFace**
```bash
# Required if using HuggingFace private models
HUGGINGFACE_API_TOKEN=your_hf_token_here
```

**Notes:**
- Replace `your_openrouter_api_key_here` with your OpenRouter API key (starts with `sk-or-...`)
- **OpenRouter** is OpenAI-compatible and supports multiple providers (OpenAI, Anthropic, Google, etc.)
- The automated scripts (`run_docker.sh`, `run_docker.bat`) will prompt you for the OpenRouter key if missing

### Step 3: Build and Run with Docker Compose

```bash
docker-compose up -d --build
```

This command:
- `up` - Starts the container
- `-d` - Runs in detached mode (background)
- `--build` - Builds the image if it doesn't exist or if changes were made

### Step 4: Access the Application

Open your browser and go to:
```
http://localhost:8501
```

### Docker Compose Commands

**View logs:**
```bash
docker-compose logs -f
```

**Stop the container:**
```bash
docker-compose down
```

**Restart the container:**
```bash
docker-compose restart
```

**Rebuild and restart:**
```bash
docker-compose up -d --build
```

---

## Method 2: Docker CLI (Manual Commands)

## Step-by-Step Instructions

### Step 1: Navigate to Project Directory

Open your terminal and navigate to the project root directory:

```bash
cd /Users/sahayamuthukanignanadurai/RAG_4_Scratch
```

### Step 2: Create Environment File (.env)

Create a `.env` file in the project root directory to store your API keys:

```bash
touch .env
```

Edit the `.env` file and add your API keys:

```bash
# Required for OpenRouter models
OPENROUTER_API_KEY=your_openrouter_api_key_here

# Optional: Required if using HuggingFace private models
# HUGGINGFACE_API_TOKEN=your_hf_token_here
```

**Note:** Replace `your_openrouter_api_key_here` with your actual OpenRouter API key.

### Step 3: Build the Docker Image

Build the Docker image from the Dockerfile:

```bash
docker build -t rag-4-scratch:latest .
```

This command:
- `-t rag-4-scratch:latest` - Tags the image with name `rag-4-scratch` and version `latest`
- `.` - Uses the Dockerfile in the current directory

**Expected output:** The build process will take several minutes as it installs all Python dependencies.

### Step 4: Run the Docker Container

Run the container with the following command:

```bash
docker run -d \
  --name rag-app \
  -p 8501:8501 \
  --env-file .env \
  -v $(pwd)/vector_store:/app/vector_store \
  rag-4-scratch:latest
```

**Command breakdown:**
- `-d` - Runs the container in detached mode (background)
- `--name rag-app` - Names the container `rag-app` for easy reference
- `-p 8501:8501` - Maps port 8501 from container to host (Streamlit default port)
- `--env-file .env` - Loads environment variables from `.env` file
- `-v $(pwd)/vector_store:/app/vector_store` - Mounts the vector_store directory to persist data
- `rag-4-scratch:latest` - The image to run

**Alternative (if you prefer interactive mode):**

```bash
docker run -it \
  --name rag-app \
  -p 8501:8501 \
  --env-file .env \
  -v $(pwd)/vector_store:/app/vector_store \
  rag-4-scratch:latest
```

### Step 5: Access the Application

Once the container is running, open your web browser and navigate to:

```
http://localhost:8501
```

You should see the "Agentic RAG Playground (LangChain)" interface.

---

## Useful Docker Commands

### Check if container is running:
```bash
docker ps
```

### View container logs:
```bash
docker logs rag-app
```

### View live logs (follow mode):
```bash
docker logs -f rag-app
```

### Stop the container:
```bash
docker stop rag-app
```

### Start a stopped container:
```bash
docker start rag-app
```

### Remove the container:
```bash
docker rm rag-app
```

### Remove the container and image:
```bash
docker rm rag-app
docker rmi rag-4-scratch:latest
```

### Execute commands inside the container:
```bash
docker exec -it rag-app /bin/bash
```

---

## Troubleshooting

### Port 8501 already in use

If you get an error that port 8501 is already in use, you can:

1. **Use a different port:**
   ```bash
   docker run -d --name rag-app -p 8502:8501 --env-file .env -v $(pwd)/vector_store:/app/vector_store rag-4-scratch:latest
   ```
   Then access at `http://localhost:8502`

2. **Or stop the process using port 8501:**
   ```bash
   # Find process using port 8501
   lsof -i :8501
   # Kill the process (replace PID with actual process ID)
   kill -9 PID
   ```

### Environment variables not loading

- Ensure `.env` file exists in the project root
- Check that `.env` file has correct format (no spaces around `=`)
- Verify the file is readable: `cat .env`

### Container exits immediately

Check the logs to see what went wrong:
```bash
docker logs rag-app
```

### Vector store data not persisting

Ensure the volume mount is correct. The `-v $(pwd)/vector_store:/app/vector_store` flag should map your local `vector_store` directory to the container's directory.

---

## Quick Start (All-in-One Commands)

If you want to do everything in one go:

```bash
# Navigate to project
cd /Users/sahayamuthukanignanadurai/RAG_4_Scratch

# Create .env file (edit with your OpenRouter API key)
echo "OPENROUTER_API_KEY=your_key_here" > .env

# Build image
docker build -t rag-4-scratch:latest .

# Run container
docker run -d --name rag-app -p 8501:8501 --env-file .env -v $(pwd)/vector_store:/app/vector_store rag-4-scratch:latest

# Check logs
docker logs -f rag-app
```

Then open `http://localhost:8501` in your browser.

---

## Using OpenRouter

**OpenRouter** is an OpenAI-compatible API that provides access to multiple LLM providers (OpenAI, Anthropic, Google, etc.) through a single API.

### Benefits of OpenRouter:
- Access to multiple providers (OpenAI, Anthropic, Google, Meta, etc.)
- Often cheaper than direct provider APIs
- Single API key for multiple models
- OpenAI-compatible API (drop-in replacement)

### How to Use OpenRouter:

1. **Get an OpenRouter API Key:**
   - Sign up at [https://openrouter.ai](https://openrouter.ai)
   - Get your API key (starts with `sk-or-...`)

2. **Set up `.env` file:**
   ```bash
   OPENROUTER_API_KEY=sk-or-your-key-here
   ```

3. **In the Configuration Page:**
   - Select **"openrouter"** as the LLM Provider
   - Use model names with provider prefix:
     - `openai/gpt-4o-mini` (OpenAI models)
     - `anthropic/claude-3-haiku` (Anthropic models)
     - `google/gemini-pro` (Google models)
     - See [https://openrouter.ai/models](https://openrouter.ai/models) for full list

4. **Note:** The code uses `OPENROUTER_API_KEY` for OpenRouter requests.

## Next Steps

After the application is running:

1. **Configuration Page** - Set up your LLM provider (OpenRouter or HuggingFace), embedding model, and data folders
2. **Vector DB Builder** - Load your JSON data and create the FAISS vector database
3. **Chatbot Q&A** - Start chatting with your RAG chatbot
4. **RAG Evaluation** - Evaluate your RAG system's performance

---

## Notes

- The vector store data is persisted in the `vector_store/` directory on your host machine
- Chat sessions are saved in `chat_sessions.json` (inside the container, consider mounting this too if you want persistence)
- The container runs in the background by default (`-d` flag)
- All dependencies are installed during the Docker build process
