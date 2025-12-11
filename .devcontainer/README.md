# Development Container Configuration

This directory contains the configuration for GitHub Codespaces and VS Code Dev Containers.

## What's Included

### Base Environment

- **Image**: Microsoft Universal base image with common development tools
- **User**: Non-root user 'codespace' for security

### Languages & Runtimes

- **Python 3.11**: Latest stable Python with pip tools
- **Node.js LTS**: Latest Long Term Support version
- **Git**: Version control
- **GitHub CLI**: Command line interface for GitHub

### Pre-installed Extensions

- **AI Development**:

  - GitHub Copilot & Copilot Chat
  - Python extension pack
  - Jupyter notebooks support

- **Code Quality**:

  - Python linting (Pylint)
  - Code formatting (Black for Python, Prettier for web)
  - JSON support

- **General Development**:
  - TypeScript support
  - Tailwind CSS support
  - Docker support

### Python Packages

The following Python packages are automatically installed:

- `jupyter` - Notebook environment
- `pandas` - Data manipulation
- `numpy` - Numerical computing
- `matplotlib`, `seaborn` - Data visualization
- `scikit-learn` - Machine learning
- `openai` - OpenAI API client
- `anthropic` - Anthropic API client
- `langchain` - AI agent framework

### Port Forwarding

The following ports are automatically forwarded:

- 3000 (React/Next.js apps)
- 5000 (Flask apps)
- 8000 (Django/FastAPI apps)
- 8080 (General web servers)

## Usage

1. **GitHub Codespaces**: Click "Code" → "Codespaces" → "Create codespace on main"
2. **VS Code Dev Containers**: Open in VS Code and select "Reopen in Container"

The environment will be automatically set up with all the tools and extensions you need for AI agent development.
