# Claude Project Context

This folder contains architecture and planning documentation for the **LightWave E-commerce Template**.

## Purpose

The `.claude/` directory provides persistent context to Claude Code across sessions, ensuring consistent understanding of project architecture, tech stack, and development patterns.

## Structure

```
.claude/
├── README.md                           # This file - how to use the .claude system
├── project-context/
│   ├── 00-project-overview.md          # Quick reference guide
│   ├── 01-tech-stack.md                # Complete technology stack details
│   ├── 02-architecture.md              # System architecture and patterns
│   ├── 03-development-guide.md         # Development workflows and commands
│   ├── 04-collections-schema.md        # Payload collections reference
│   ├── 05-deployment.md                # Deployment strategies and guides
│   └── 06-customization-guide.md       # How to adapt this template
└── prompts/
    └── coding-session-start.md         # Copy/paste to start new sessions
```

## Usage

### Starting a New Coding Session

1. **Quick Start**: Copy contents of `prompts/coding-session-start.md` and paste into Claude Code
2. **Specify Task**: Add what you're working on to the prompt
3. **Begin Work**: Claude Code will have full project context

### During Development

Reference specific docs when needed:
- **Quick facts**: `project-context/00-project-overview.md`
- **Tech questions**: `project-context/01-tech-stack.md`
- **Architecture**: `project-context/02-architecture.md`
- **How to build/test**: `project-context/03-development-guide.md`
- **Collections**: `project-context/04-collections-schema.md`
- **Deployment**: `project-context/05-deployment.md`

### Updating Documentation

When project structure or architecture changes:
1. Update relevant files in `project-context/`
2. Keep `00-project-overview.md` in sync as the quick reference
3. Update `prompts/coding-session-start.md` if core context changes

## Quick Links

- **Current Work**: See project-context/00-project-overview.md for active sprint/tasks
- **Architecture**: project-context/02-architecture.md
- **Collections Schema**: project-context/04-collections-schema.md
- **Development Commands**: project-context/03-development-guide.md

## Version Control

This `.claude/` directory is designed to be **git-committed** so all team members and Claude Code sessions have consistent context.

---

**Last Updated**: 2025-11-01
**Maintained By**: LightWave Media Team + Claude Code
**Version**: 1.0.0
