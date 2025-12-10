#!/bin/bash
# Agent Workflow Runner
# This script demonstrates how to chain agents together in sequence

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
AGENTS_DIR=".github/agents"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Agent Workflow Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if agents directory exists
if [ ! -d "$AGENTS_DIR" ]; then
    echo -e "${RED}Error: Agents directory not found at $AGENTS_DIR${NC}"
    exit 1
fi

# Function to display agent step
show_agent_step() {
    local agent_name=$1
    local step_num=$2
    echo ""
    echo -e "${GREEN}>>> Step $step_num: $agent_name${NC}"
    echo -e "${BLUE}────────────────────────────────────────${NC}"
}

# Function to display agent info
show_agent_info() {
    local agent_file=$1
    if [ -f "$agent_file" ]; then
        echo -e "${YELLOW}Agent Role:${NC}"
        grep -A 3 "## Your Role" "$agent_file" | tail -n +2 | head -n 3
        echo ""
    fi
}

# Main workflow
echo -e "Task: ${1:-'Placeholder task - no specific task provided'}"
echo ""
echo "Workflow: develop → test → document → review"
echo ""
echo -e "${YELLOW}Starting agent workflow chain...${NC}"
echo ""

# Step 1: Develop Agent
show_agent_step "Develop Agent" "1"
show_agent_info "$AGENTS_DIR/develop-agent.md"
echo "Status: This is a placeholder agent demonstration"
echo "Output: Ready to implement features when given concrete tasks"
echo ""

# Step 2: Test Agent
show_agent_step "Test Agent" "2"
show_agent_info "$AGENTS_DIR/test-agent.md"
echo "Status: This is a placeholder agent demonstration"
echo "Output: Ready to test implementations independently"
echo ""

# Step 3: Document Agent
show_agent_step "Document Agent" "3"
show_agent_info "$AGENTS_DIR/document-agent.md"
echo "Status: This is a placeholder agent demonstration"
echo "Output: Ready to create comprehensive documentation"
echo ""

# Step 4: Review Agent
show_agent_step "Review Agent" "4"
show_agent_info "$AGENTS_DIR/review-agent.md"
echo "Status: This is a placeholder agent demonstration"
echo "Output: Ready to review and provide feedback"
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Workflow Chain Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Workflow Summary:"
echo "  • All 4 agents demonstrated"
echo "  • Chain sequence: develop → test → document → review"
echo "  • Each agent is independent and ready for concrete tasks"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Provide specific tasks to each agent"
echo "  2. Agents will execute independently"
echo "  3. Context will be passed between agents"
echo "  4. Review agent will provide final approval or request changes"
echo ""
echo "For more information, see:"
echo "  • $AGENTS_DIR/workflow-orchestrator.md"
echo "  • $AGENTS_DIR/workflow-example.md"
echo ""
