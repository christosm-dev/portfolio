#!/usr/bin/env python3
"""
Test client for Zensical Sandbox Platform

This script demonstrates how to interact with the sandbox API
and can be used for testing and development.
"""

import requests
import json
import time
from typing import Dict, Any

# API configuration
API_BASE_URL = "http://localhost:8000"
API_TIMEOUT = 60  # seconds


class SandboxClient:
    """Client for interacting with the Zensical Sandbox Platform API"""
    
    def __init__(self, base_url: str = API_BASE_URL):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
    
    def health_check(self) -> Dict[str, Any]:
        """Check API health status"""
        response = self.session.get(f"{self.base_url}/health")
        response.raise_for_status()
        return response.json()
    
    def list_environments(self) -> Dict[str, Any]:
        """List available execution environments"""
        response = self.session.get(f"{self.base_url}/environments")
        response.raise_for_status()
        return response.json()
    
    def execute_code(
        self,
        code: str,
        environment: str,
        timeout: int = 30
    ) -> Dict[str, Any]:
        """
        Execute code in sandbox environment
        
        Args:
            code: Code to execute
            environment: Execution environment (python, node, bash)
            timeout: Maximum execution time in seconds
            
        Returns:
            Execution results including output or error
        """
        payload = {
            "code": code,
            "environment": environment,
            "timeout": timeout
        }
        
        response = self.session.post(
            f"{self.base_url}/execute",
            json=payload,
            timeout=API_TIMEOUT
        )
        response.raise_for_status()
        return response.json()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get platform statistics"""
        response = self.session.get(f"{self.base_url}/stats")
        response.raise_for_status()
        return response.json()


def print_result(result: Dict[str, Any]):
    """Pretty print execution result"""
    print(f"\n{'='*60}")
    print(f"Execution ID: {result['execution_id']}")
    print(f"Status: {result['status']}")
    print(f"Environment: {result['environment']}")
    print(f"Execution Time: {result['execution_time']}s")
    print(f"{'='*60}")
    
    if result['status'] == 'success' and result['output']:
        print("Output:")
        print(result['output'])
    elif result['error']:
        print("Error:")
        print(result['error'])


def run_examples():
    """Run example code executions"""
    client = SandboxClient()
    
    # Check health
    print("Checking API health...")
    health = client.health_check()
    print(f"API Status: {health['status']}")
    print(f"Docker Available: {health['docker_available']}")
    print(f"Active Containers: {health['active_containers']}")
    
    # List environments
    print("\nAvailable environments:")
    environments = client.list_environments()
    for env in environments['environments']:
        print(f"  - {env}")
    
    # Example 1: Python - Hello World
    print("\n\n=== Example 1: Python Hello World ===")
    result = client.execute_code(
        code="""
print("Hello from the Zensical Sandbox!")
print("Python version check:")
import sys
print(f"Python {sys.version}")
""",
        environment="python"
    )
    print_result(result)
    
    # Example 2: Python - Math operations
    print("\n\n=== Example 2: Python Math Operations ===")
    result = client.execute_code(
        code="""
import math

# Calculate fibonacci sequence
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

print("First 10 Fibonacci numbers:")
for i in range(10):
    print(f"F({i}) = {fibonacci(i)}")

print(f"\\nSquare root of 2: {math.sqrt(2)}")
print(f"Pi: {math.pi}")
""",
        environment="python"
    )
    print_result(result)
    
    # Example 3: Node.js - JSON manipulation
    print("\n\n=== Example 3: Node.js JSON Manipulation ===")
    result = client.execute_code(
        code="""
const data = {
    project: "Zensical Sandbox",
    technologies: ["Docker", "FastAPI", "Node.js"],
    secure: true,
    resourceLimits: {
        cpu: "50%",
        memory: "256MB"
    }
};

console.log("Project Configuration:");
console.log(JSON.stringify(data, null, 2));

console.log("\\nTechnologies used:");
data.technologies.forEach((tech, index) => {
    console.log(`${index + 1}. ${tech}`);
});
""",
        environment="node"
    )
    print_result(result)
    
    # Example 4: Bash - System information
    print("\n\n=== Example 4: Bash System Information ===")
    result = client.execute_code(
        code="""
echo "=== Container Information ==="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Working Directory: $(pwd)"
echo ""
echo "=== Available Commands ==="
which sh bash cat echo ls pwd
echo ""
echo "=== Temp Directory ==="
ls -lah /tmp
echo ""
echo "=== Memory Info (limited) ==="
cat /proc/meminfo | head -5
""",
        environment="bash"
    )
    print_result(result)
    
    # Example 5: Test timeout
    print("\n\n=== Example 5: Testing Timeout (5s limit) ===")
    result = client.execute_code(
        code="""
import time
print("Starting long-running task...")
for i in range(10):
    print(f"Iteration {i}")
    time.sleep(1)
print("Completed!")
""",
        environment="python",
        timeout=5
    )
    print_result(result)
    
    # Get final stats
    print("\n\n=== Platform Statistics ===")
    stats = client.get_stats()
    print(json.dumps(stats, indent=2))


def interactive_mode():
    """Interactive REPL for testing"""
    client = SandboxClient()
    
    print("Zensical Sandbox Platform - Interactive Mode")
    print("=" * 60)
    print("Commands:")
    print("  python <code>  - Execute Python code")
    print("  node <code>    - Execute Node.js code")
    print("  bash <code>    - Execute Bash code")
    print("  health         - Check API health")
    print("  stats          - Show platform stats")
    print("  quit           - Exit")
    print("=" * 60)
    
    while True:
        try:
            user_input = input("\n>>> ").strip()
            
            if not user_input:
                continue
            
            if user_input.lower() == 'quit':
                break
            
            if user_input.lower() == 'health':
                health = client.health_check()
                print(json.dumps(health, indent=2))
                continue
            
            if user_input.lower() == 'stats':
                stats = client.get_stats()
                print(json.dumps(stats, indent=2))
                continue
            
            # Parse environment and code
            parts = user_input.split(maxsplit=1)
            if len(parts) != 2:
                print("Invalid command. Use: <environment> <code>")
                continue
            
            environment, code = parts
            
            if environment not in ['python', 'node', 'bash']:
                print(f"Invalid environment: {environment}")
                continue
            
            result = client.execute_code(code, environment)
            print_result(result)
            
        except KeyboardInterrupt:
            print("\nExiting...")
            break
        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--interactive":
        interactive_mode()
    else:
        print("Running example code executions...")
        print("(Use --interactive for REPL mode)")
        try:
            run_examples()
        except requests.exceptions.ConnectionError:
            print("\nError: Cannot connect to API at", API_BASE_URL)
            print("Make sure the API is running with: docker-compose up")
        except Exception as e:
            print(f"\nError: {e}")
