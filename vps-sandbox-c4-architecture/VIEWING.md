# Viewing C4 Diagrams with Structurizr Lite

This guide explains how to view the VPS Sandbox Platform C4 architecture diagrams using Structurizr Lite.

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)

1. **Start Structurizr Lite**:
   ```bash
   cd vps-sandbox-c4-architecture
   docker-compose up -d
   ```

2. **Open in Browser**:
   - Navigate to: http://localhost:8080
   - The workspace will load automatically

3. **Stop when done**:
   ```bash
   docker-compose down
   ```

### Option 2: Docker Run

If you prefer not to use Docker Compose:

```bash
docker run -d \
  --name structurizr-lite \
  -p 8080:8080 \
  -v $(pwd):/usr/local/structurizr \
  structurizr/lite
```

Then open http://localhost:8080

## 📊 Available Views

Once Structurizr Lite is running, you'll see the following diagrams:

### 1. System Context Diagram
**View Name**: SystemContext

Shows the VPS Sandbox Platform in its environment:
- Users (DevOps Engineer, Developer, Technical Interviewer)
- External systems (GitHub, Docker Hub, Let's Encrypt)
- High-level interactions

**Use for**: Portfolio presentations, explaining the overall system

---

### 2. Container Diagram
**View Name**: Containers

Shows the major runtime components:
- NGINX Reverse Proxy
- FastAPI Backend API
- PostgreSQL Database
- Redis Cache
- Prometheus & Grafana monitoring

**Use for**: Technical interviews, discussing architecture decisions

---

### 3. Component Diagram
**View Name**: Components

Zooms into the Backend API to show:
- API Routes (Container, Auth, Health)
- Services (Container Service, Security, Resource Monitor)
- Repositories (Data access layer)
- Infrastructure components (Docker Client, Cache Client)

**Use for**: Deep technical discussions, code reviews

---

### 4. Dynamic Diagrams

**Container Deployment Flow**:
- Shows the sequence of deploying a container
- From user request through to monitoring registration

**Resource Monitoring Flow**:
- Shows how metrics flow from containers to dashboards
- Demonstrates observability architecture

---

### 5. Deployment Diagrams

**Phase 1: Docker-based Deployment**:
- Shows all containers running on Docker Engine
- Contabo VPS hosting

**Phase 2: Kubernetes Deployment**:
- Shows migration to Kubernetes
- Namespace organization
- StatefulSets for databases
- Deployments for stateless services

## 🎨 Structurizr Lite Features

### Navigation
- **Click** on elements to see details
- **Use tabs** at the top to switch between views
- **Zoom** with mouse wheel or pinch gestures
- **Pan** by clicking and dragging

### Diagram Export
- Click the **camera icon** to export diagrams
- Choose format: PNG, SVG, or PlantUML
- Useful for documentation and presentations

### Auto-Layout
All views use auto-layout, which you can customize by:
1. Clicking "Edit" mode (if enabled)
2. Dragging elements to preferred positions
3. The layout will be remembered for your session

## 🔧 Troubleshooting

### Port Already in Use
If port 8080 is already in use, modify `docker-compose.yml`:
```yaml
ports:
  - "8081:8080"  # Use 8081 instead
```

### Docker Not Running
Ensure Docker Desktop (or Docker daemon) is running:
```bash
docker ps  # Should list running containers
```

### Workspace Not Loading
Check that `workspace.dsl` is in the same directory as `docker-compose.yml`:
```bash
ls -la workspace.dsl
```

### Syntax Errors
If the workspace doesn't load, check the logs:
```bash
docker-compose logs structurizr-lite
```

## 📝 Editing the Workspace

### Make Changes
1. Edit `workspace.dsl` with any text editor
2. Save the file
3. Refresh your browser (Structurizr Lite auto-detects changes)

### Syntax Reference
See the [Structurizr DSL documentation](https://github.com/structurizr/dsl/tree/master/docs) for:
- Model syntax (people, systems, containers, components)
- View types (system context, container, component, deployment, dynamic)
- Styling options
- Themes

## 🎯 Interview Usage

### Presenting Architecture
1. Start with **System Context** - high-level overview
2. Move to **Container** - technical architecture
3. Dive into **Component** - detailed design (if asked)
4. Show **Dynamic** views - explain workflows
5. Discuss **Deployment** views - phase evolution

### Key Talking Points

**System Context**:
- Who uses the system and why
- Integration with external systems
- System boundaries

**Container**:
- Technology choices (FastAPI, PostgreSQL, Redis)
- Communication patterns
- Monitoring and observability

**Component**:
- Clean architecture (layered)
- Separation of concerns
- Design patterns used

**Deployment**:
- Phase 1 vs Phase 2 (Docker → Kubernetes)
- Progressive complexity
- Production-ready from day one

## 📚 Additional Resources

- [Structurizr Lite Documentation](https://github.com/structurizr/lite)
- [Structurizr DSL Language Reference](https://github.com/structurizr/dsl)
- [C4 Model](https://c4model.com/)
- [VPS Sandbox Platform README](../vps-sandbox-platform/README.md)

## 🐛 Common Issues

### Issue: Diagram is cluttered
**Solution**: Use the filter panel to hide certain relationships or elements

### Issue: Can't see all relationships
**Solution**: Click on an element to highlight its relationships

### Issue: Want to change colors
**Solution**: Edit the `styles` section in `workspace.dsl`

### Issue: Need to export for presentation
**Solution**: Use the camera icon to export as PNG or SVG

---

**Created**: February 4, 2026
**Last Updated**: February 4, 2026
**Owner**: Christos Michaelides
**Project**: VPS Sandbox Platform C4 Architecture
