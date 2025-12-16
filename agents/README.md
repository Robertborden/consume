# CONSUME App Agents

This directory contains AI agent configurations for developing the CONSUME app.

## Available Agents

### 1. Frontend Designer Agent

**File:** `frontend-designer.md`

Expert Flutter/Dart developer specializing in:
- Material Design 3 implementation
- Riverpod state management
- Responsive layouts (iOS, Android, Web)
- Custom animations and interactions
- Accessibility best practices

**Use for:**
- Creating new UI components
- Implementing page layouts
- Styling and theming
- Animation and transitions
- Widget optimization

### 2. Backend Manager Agent

**File:** `backend-manager.md`

Expert Supabase/PostgreSQL developer specializing in:
- Database schema design
- Row Level Security policies
- PostgreSQL functions and triggers
- Edge Functions (Deno)
- Real-time subscriptions

**Use for:**
- Database migrations
- API endpoint design
- Security policies
- Performance optimization
- Server-side logic

---

## Usage

### With Claude Code CLI

Use the slash commands in `.claude/commands/`:

```bash
# Frontend tasks
claude /frontend Create a custom guilt meter widget with gradient colors

# Backend tasks  
claude /backend Add a tags table with many-to-many relationship to saved_items

# Code review
claude /review Check the review page for performance issues

# Testing
claude /test Write unit tests for the SavedItem entity
```

### With Other AI Tools

Copy the system prompt from the agent file and use it as the system message:

1. Open `frontend-designer.md` or `backend-manager.md`
2. Copy the entire content
3. Paste as the system prompt in your AI tool
4. Start your conversation

---

## Agent Knowledge Base

Both agents have deep knowledge of:

### Project Structure
```
lib/
├── core/           # Theme, constants, utilities
├── domain/         # Entities and repository interfaces
├── data/           # Models and data sources
└── presentation/   # UI, providers, pages, widgets
```

### Tech Stack
- **Framework:** Flutter 3.16+, Dart 3.2+
- **State:** Riverpod 2.x
- **Navigation:** go_router
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Local DB:** Drift (SQLite)

### Design System
- **Colors:** Primary Indigo #6366F1
- **Font:** Inter
- **Spacing:** 4px grid (xs=4, sm=8, md=16, lg=24)
- **Radius:** 8px, 12px, 16px

---

## Customizing Agents

To modify an agent's behavior:

1. Edit the relevant `.md` file
2. Update the "Core Competencies" section for skill focus
3. Modify the "Your Workflow" section for process changes
4. Adjust the "Communication Style" for output format

---

## Creating New Agents

To create a new specialized agent:

1. Copy an existing agent file as a template
2. Update the identity section
3. Define core competencies
4. Add relevant project knowledge
5. Specify the workflow and output format
6. Add a slash command in `.claude/commands/`

---

## Best Practices

1. **Be specific** - Give clear, detailed requirements
2. **Provide context** - Mention related files or features
3. **Ask for explanations** - Request reasoning for decisions
4. **Iterate** - Refine the output through follow-up questions
5. **Verify** - Test generated code before committing
