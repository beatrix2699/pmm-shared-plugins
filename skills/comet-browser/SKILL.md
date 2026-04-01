---
name: comet-browser
description: Use when the user wants live web research, competitor pricing, screenshots, or any task requiring real browser access — including login-walled pages, dynamic content, or agentic multi-step browsing. Triggers: "check the website", "look up live pricing", "research competitors", "take a screenshot", "search for current data", or any task needing up-to-date web information beyond Claude's knowledge.
---

# Comet Browser

## Overview

Delegate web research and browsing tasks to Perplexity's Comet AI browser via 6 MCP tools. This is **AI-to-AI delegation** — you send a natural language prompt to Comet, and Comet handles the actual browsing, searching, and page interaction autonomously.

**Comet must be running on your Mac before using these tools.**

## The 6 Tools

| Tool | Purpose | When to use |
|------|---------|-------------|
| `comet_connect` | Connect to Comet (auto-starts if needed) | Always call first in a session |
| `comet_ask` | Send a prompt, get back a response (blocking) | Main tool for all research tasks |
| `comet_mode` | Switch search mode (search/research/labs/learn) | Before `comet_ask` for specific task types |
| `comet_poll` | Check progress of a long-running task | When `comet_ask` times out mid-task |
| `comet_stop` | Cancel the current task | When task goes off track |
| `comet_screenshot` | Capture the current page | Visual evidence for slides/reports |

## Search Modes

Switch with `comet_mode` before `comet_ask`:

| Mode | Best for |
|------|---------|
| `search` | Quick lookups, current prices, facts |
| `research` | Deep competitive analysis, comprehensive reports |
| `labs` | Data analysis, charts, visualizations |
| `learn` | Technical explanations, how-to guides |

## Standard Workflow

```
1. comet_connect           → ensure connection
2. comet_mode("research")  → set mode (optional)
3. comet_ask("prompt")     → delegate the task
   ↓ if timeout before completion:
4. comet_poll              → check progress (repeat)
5. comet_screenshot        → capture result (optional)
```

## Common Use Cases

### GPU / Cloud Pricing Research
```
comet_connect
comet_mode("search")
comet_ask("What are current H100 GPU on-demand prices from Lambda Labs, CoreWeave, RunPod, and Hyperstack as of today?")
```

### Deep Competitive Analysis
```
comet_connect
comet_mode("research")
comet_ask("Research GreenNode vs CoreWeave vs Lambda Labs for GPU cloud: pricing, SLA, data center locations, enterprise features", newChat: true)
→ if still working after 15s: comet_poll every 10-15s until completed
```

### GTM Slide Evidence
```
comet_connect
comet_ask("Go to [competitor URL] and summarize their pricing page")
comet_screenshot  → capture for presentation
```

### Login-Walled or Dynamic Pages
```
comet_ask("Log into [service] and check [specific data]")
→ Comet handles authentication and page interaction
```

## comet_ask Parameters

```
prompt   (required) — Natural language task. Be specific about what you want.
newChat  (optional) — true = fresh conversation, clears prior context. Use for unrelated tasks.
timeout  (optional) — ms to wait before returning "in progress" (default: 15000 = 15s)
```

**For long research tasks:** set `timeout: 60000` (60s) or use default + poll.

## Common Mistakes

- **Not calling `comet_connect` first** → tools will fail if Comet isn't connected
- **Using too short a prompt** → be specific: "H100 pricing" vs "current on-demand H100 GPU prices from top 5 providers"
- **Not polling after timeout** → long tasks continue running; call `comet_poll` to get results
- **Missing `newChat: true`** → follow-up `comet_ask` calls continue previous conversation context; use `newChat: true` for unrelated tasks
- **Wrong mode** → use `research` for competitive analysis, `search` for quick facts

## Setup

MCP server is installed globally: `claude mcp add comet -s user -- npx -y comet-mcp`

Verify: `claude mcp list` → comet should show `✓ Connected`

If disconnected: open Comet browser, then call `comet_connect`.
