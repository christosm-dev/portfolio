"""
Zensical Sandbox Platform - Backend API

This FastAPI application provides secure, isolated sandbox execution environments
for portfolio visitors to run code examples in real-time.

Key Features:
- Docker-based containerized execution
- Resource limits (CPU, memory, time)
- Network isolation for security
- Rate limiting per IP
- Comprehensive logging and monitoring
"""

from fastapi import FastAPI, HTTPException, Request, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, List, Literal
import docker
import asyncio
import uuid
import time
import logging
from datetime import datetime, timedelta
from collections import defaultdict
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI application
app = FastAPI(
    title="Zensical Sandbox Platform",
    description="Secure code execution sandbox for portfolio demonstrations",
    version="1.0.0"
)

# CORS configuration - adjust origins for your frontend domain
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",  # Local development
        "https://yourdomain.com",  # Production domain
    ],
    allow_credentials=True,
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)

# Initialize Docker client
try:
    docker_client = docker.from_env()
    logger.info("Docker client initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize Docker client: {e}")
    docker_client = None

# Rate limiting configuration
RATE_LIMIT_WINDOW = 60  # seconds
MAX_REQUESTS_PER_WINDOW = 10  # requests per IP per window
rate_limit_store: Dict[str, List[float]] = defaultdict(list)

# Sandbox execution limits
EXECUTION_TIMEOUT = 30  # seconds
MAX_OUTPUT_SIZE = 10000  # characters
MEMORY_LIMIT = "256m"  # 256 MB
CPU_QUOTA = 50000  # 50% of one CPU core (out of 100000)
CPU_PERIOD = 100000

# Supported sandbox environments
SUPPORTED_ENVIRONMENTS = {
    "python": {
        "image": "python:3.11-slim",
        "command_template": "python -c '{code}'",
        "file_extension": "py"
    },
    "node": {
        "image": "node:18-alpine",
        "command_template": "node -e '{code}'",
        "file_extension": "js"
    },
    "bash": {
        "image": "bash:5.2-alpine3.19",
        "command_template": "bash -c '{code}'",
        "file_extension": "sh"
    }
}


class SandboxRequest(BaseModel):
    """Request model for sandbox execution"""
    code: str = Field(..., min_length=1, max_length=5000, description="Code to execute")
    environment: Literal["python", "node", "bash"] = Field(
        ..., 
        description="Execution environment"
    )
    timeout: Optional[int] = Field(
        default=30, 
        ge=1, 
        le=60, 
        description="Execution timeout in seconds"
    )
    
    @validator('code')
    def validate_code(cls, v):
        """Validate code doesn't contain obviously malicious patterns"""
        dangerous_patterns = [
            'rm -rf',
            'dd if=',
            'fork',
            ':(){ :|:& };:',  # Fork bomb
            '/dev/random',
            'curl',
            'wget',
            'nc ',  # netcat
        ]
        
        v_lower = v.lower()
        for pattern in dangerous_patterns:
            if pattern in v_lower:
                raise ValueError(f"Code contains potentially dangerous pattern: {pattern}")
        
        return v


class SandboxResponse(BaseModel):
    """Response model for sandbox execution"""
    execution_id: str
    status: Literal["success", "error", "timeout"]
    output: Optional[str] = None
    error: Optional[str] = None
    execution_time: float
    environment: str
    timestamp: str


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    docker_available: bool
    timestamp: str
    active_containers: int


def check_rate_limit(ip_address: str) -> bool:
    """
    Check if IP address has exceeded rate limit
    
    Args:
        ip_address: Client IP address
        
    Returns:
        True if within rate limit, False if exceeded
    """
    current_time = time.time()
    
    # Clean up old entries
    rate_limit_store[ip_address] = [
        req_time for req_time in rate_limit_store[ip_address]
        if current_time - req_time < RATE_LIMIT_WINDOW
    ]
    
    # Check if exceeded
    if len(rate_limit_store[ip_address]) >= MAX_REQUESTS_PER_WINDOW:
        logger.warning(f"Rate limit exceeded for IP: {ip_address}")
        return False
    
    # Add current request
    rate_limit_store[ip_address].append(current_time)
    return True


async def cleanup_container(container_id: str, delay: int = 5):
    """
    Background task to cleanup container after delay
    
    Args:
        container_id: Docker container ID
        delay: Seconds to wait before cleanup
    """
    await asyncio.sleep(delay)
    try:
        container = docker_client.containers.get(container_id)
        container.stop(timeout=2)
        container.remove(force=True)
        logger.info(f"Cleaned up container: {container_id}")
    except docker.errors.NotFound:
        logger.info(f"Container already removed: {container_id}")
    except Exception as e:
        logger.error(f"Failed to cleanup container {container_id}: {e}")


def execute_in_sandbox(
    code: str,
    environment: str,
    timeout: int = EXECUTION_TIMEOUT
) -> Dict:
    """
    Execute code in isolated Docker container
    
    Args:
        code: Code to execute
        environment: Execution environment (python, node, bash)
        timeout: Maximum execution time in seconds
        
    Returns:
        Dictionary containing execution results
    """
    execution_id = str(uuid.uuid4())
    start_time = time.time()
    
    logger.info(f"Starting execution {execution_id} in {environment} environment")
    
    if not docker_client:
        return {
            "execution_id": execution_id,
            "status": "error",
            "error": "Docker client not available",
            "execution_time": 0,
            "timestamp": datetime.utcnow().isoformat()
        }
    
    env_config = SUPPORTED_ENVIRONMENTS[environment]
    container = None
    
    try:
        # Prepare command
        # For security, we write code to a file and execute it
        # This prevents command injection through the code parameter
        safe_code = code.replace("'", "'\\''")  # Escape single quotes
        command = ["sh", "-c", f"echo '{safe_code}' > /tmp/code.{env_config['file_extension']} && {env_config['command_template'].format(code='$(cat /tmp/code.' + env_config['file_extension'] + ')')}"]
        
        # Create container with security constraints
        container = docker_client.containers.create(
            image=env_config["image"],
            command=command,
            detach=True,
            mem_limit=MEMORY_LIMIT,
            memswap_limit=MEMORY_LIMIT,  # No swap
            cpu_quota=CPU_QUOTA,
            cpu_period=CPU_PERIOD,
            network_mode="none",  # No network access
            read_only=True,  # Read-only root filesystem
            tmpfs={'/tmp': 'size=50M,mode=1777'},  # Small writable temp space
            security_opt=["no-new-privileges"],
            cap_drop=["ALL"],  # Drop all capabilities
            pids_limit=50,  # Limit number of processes
            labels={
                "zensical.execution_id": execution_id,
                "zensical.environment": environment,
                "zensical.created": datetime.utcnow().isoformat()
            }
        )
        
        # Start container
        container.start()
        logger.info(f"Container started: {container.id}")
        
        # Wait for completion or timeout
        try:
            exit_code = container.wait(timeout=timeout)
            status = "success" if exit_code["StatusCode"] == 0 else "error"
        except Exception:
            status = "timeout"
            logger.warning(f"Execution {execution_id} timed out")
            container.stop(timeout=2)
        
        # Get logs (output)
        try:
            logs = container.logs(stdout=True, stderr=True).decode('utf-8')
            # Truncate if too large
            if len(logs) > MAX_OUTPUT_SIZE:
                logs = logs[:MAX_OUTPUT_SIZE] + "\n... (output truncated)"
        except Exception as e:
            logs = f"Failed to retrieve logs: {str(e)}"
        
        execution_time = time.time() - start_time
        
        result = {
            "execution_id": execution_id,
            "status": status,
            "output": logs if status != "error" else None,
            "error": logs if status == "error" else None,
            "execution_time": round(execution_time, 3),
            "environment": environment,
            "timestamp": datetime.utcnow().isoformat()
        }
        
        logger.info(f"Execution {execution_id} completed: {status} in {execution_time:.3f}s")
        return result
        
    except docker.errors.ImageNotFound:
        logger.error(f"Docker image not found: {env_config['image']}")
        return {
            "execution_id": execution_id,
            "status": "error",
            "error": f"Environment image not available: {environment}",
            "execution_time": time.time() - start_time,
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Execution {execution_id} failed: {str(e)}")
        return {
            "execution_id": execution_id,
            "status": "error",
            "error": f"Execution failed: {str(e)}",
            "execution_time": time.time() - start_time,
            "timestamp": datetime.utcnow().isoformat()
        }
    finally:
        # Cleanup container
        if container:
            try:
                container.remove(force=True)
                logger.info(f"Container removed: {container.id}")
            except Exception as e:
                logger.error(f"Failed to remove container: {e}")


@app.get("/", response_model=Dict[str, str])
async def root():
    """Root endpoint with API information"""
    return {
        "service": "Zensical Sandbox Platform",
        "version": "1.0.0",
        "status": "operational",
        "documentation": "/docs"
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint
    
    Returns service health status and Docker availability
    """
    docker_available = docker_client is not None
    active_containers = 0
    
    if docker_available:
        try:
            # Count active sandbox containers
            containers = docker_client.containers.list(
                filters={"label": "zensical.execution_id"}
            )
            active_containers = len(containers)
        except Exception as e:
            logger.error(f"Failed to get container count: {e}")
    
    return HealthResponse(
        status="healthy" if docker_available else "degraded",
        docker_available=docker_available,
        timestamp=datetime.utcnow().isoformat(),
        active_containers=active_containers
    )


@app.get("/environments", response_model=Dict[str, List[str]])
async def list_environments():
    """
    List available execution environments
    
    Returns list of supported languages/environments
    """
    return {
        "environments": list(SUPPORTED_ENVIRONMENTS.keys()),
        "details": {
            env: {
                "image": config["image"],
                "file_extension": config["file_extension"]
            }
            for env, config in SUPPORTED_ENVIRONMENTS.items()
        }
    }


@app.post("/execute", response_model=SandboxResponse)
async def execute_code(
    request: SandboxRequest,
    client_request: Request,
    background_tasks: BackgroundTasks
):
    """
    Execute code in sandboxed environment
    
    This endpoint creates an isolated Docker container, executes the provided
    code with strict resource limits, and returns the results.
    
    Security measures:
    - Rate limiting per IP
    - Network isolation (no external access)
    - Resource limits (CPU, memory, processes)
    - Execution timeout
    - Read-only filesystem
    - Dropped Linux capabilities
    """
    # Get client IP
    client_ip = client_request.client.host
    
    # Check rate limit
    if not check_rate_limit(client_ip):
        raise HTTPException(
            status_code=429,
            detail=f"Rate limit exceeded. Maximum {MAX_REQUESTS_PER_WINDOW} requests per {RATE_LIMIT_WINDOW} seconds."
        )
    
    # Validate Docker client
    if not docker_client:
        raise HTTPException(
            status_code=503,
            detail="Sandbox service unavailable. Docker not accessible."
        )
    
    # Execute in sandbox
    result = execute_in_sandbox(
        code=request.code,
        environment=request.environment,
        timeout=request.timeout
    )
    
    return SandboxResponse(**result)


@app.get("/stats", response_model=Dict)
async def get_stats():
    """
    Get platform statistics
    
    Returns execution statistics and system information
    """
    if not docker_client:
        return {"error": "Docker not available"}
    
    try:
        # Get all sandbox containers (active and stopped in last hour)
        all_containers = docker_client.containers.list(
            all=True,
            filters={"label": "zensical.execution_id"}
        )
        
        active = sum(1 for c in all_containers if c.status == "running")
        total = len(all_containers)
        
        return {
            "active_executions": active,
            "total_containers": total,
            "supported_environments": list(SUPPORTED_ENVIRONMENTS.keys()),
            "rate_limit": {
                "window_seconds": RATE_LIMIT_WINDOW,
                "max_requests": MAX_REQUESTS_PER_WINDOW
            },
            "resource_limits": {
                "memory": MEMORY_LIMIT,
                "cpu_percent": (CPU_QUOTA / CPU_PERIOD) * 100,
                "timeout_seconds": EXECUTION_TIMEOUT
            },
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Failed to get stats: {e}")
        return {"error": str(e)}


@app.on_event("startup")
async def startup_event():
    """Pull required Docker images on startup"""
    if not docker_client:
        logger.error("Cannot pull images: Docker client not available")
        return
    
    logger.info("Pulling required Docker images...")
    for env, config in SUPPORTED_ENVIRONMENTS.items():
        try:
            docker_client.images.pull(config["image"])
            logger.info(f"Pulled image: {config['image']}")
        except Exception as e:
            logger.error(f"Failed to pull {config['image']}: {e}")


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    if not docker_client:
        return
    
    logger.info("Cleaning up sandbox containers...")
    try:
        containers = docker_client.containers.list(
            filters={"label": "zensical.execution_id"}
        )
        for container in containers:
            try:
                container.stop(timeout=2)
                container.remove(force=True)
                logger.info(f"Cleaned up container: {container.id}")
            except Exception as e:
                logger.error(f"Failed to cleanup container {container.id}: {e}")
    except Exception as e:
        logger.error(f"Shutdown cleanup failed: {e}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
