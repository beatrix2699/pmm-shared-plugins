---
name: gamma-deck-creator
description: Use when converting a slide plan or GTM strategy document into a Gamma presentation. Triggers after slide-deck-planner or gtm-deck-planner output is complete, or when user says "create in Gamma", "build the deck in Gamma", "make this a Gamma presentation", or "turn this into slides". Also auto-opens the result in the default browser.
---

# Gamma Deck Creator

Convert structured slide plans into published Gamma presentations, then auto-open the result in the default browser.

## Pipeline Position

This skill is the **final step** in the deck creation pipeline:

```
gtm-deck-planner  ──┐
                    ├──▶  gamma-deck-creator  ──▶  default browser (auto-open)
slide-deck-planner ──┘
```

When either upstream skill finishes, run this skill immediately with its output — do not wait for the user to ask.

---

## Step 1 — Check Gamma connection

Gamma is accessed via direct HTTP to `https://mcp.gamma.app/mcp` using `x-api-key` authentication. The API key is stored in `~/.claude/settings.json` as `GAMMA_API_KEY`.

**Connection method (use this exact pattern):**

```python
import subprocess, json

api_key = "sk-gamma-..."  # from GAMMA_API_KEY env var or settings.json
url = "https://mcp.gamma.app/mcp"
cookie_jar = "/tmp/gamma_cookies.txt"

# Step 1: Initialize to get Cloudflare cookie
init_payload = json.dumps({
    "jsonrpc": "2.0", "id": 1, "method": "initialize",
    "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "claude", "version": "1.0"}}
})
subprocess.run(["curl", "-s", "-c", cookie_jar, "-X", "POST", url,
    "-H", f"x-api-key: {api_key}", "-H", "Content-Type: application/json",
    "-H", "Accept: application/json, text/event-stream", "-d", init_payload],
    capture_output=True)

# Step 2: Call any tool
payload = json.dumps({
    "jsonrpc": "2.0", "id": 2, "method": "tools/call",
    "params": {"name": "generate", "arguments": {...}}
})
with open("/tmp/gamma_payload.json", "w") as f:
    f.write(payload)

result = subprocess.run(["curl", "-s", "-b", cookie_jar, "-c", cookie_jar,
    "-X", "POST", url, "-H", f"x-api-key: {api_key}",
    "-H", "Content-Type: application/json",
    "-H", "Accept: application/json, text/event-stream",
    "--max-time", "120", "-d", "@/tmp/gamma_payload.json"],
    capture_output=True, text=True, timeout=130)
```

**Key rules:**
- Always `initialize` first to get the Cloudflare `__cf_bm` cookie — without it, `tools/call` returns 403
- Use `-b cookie_jar -c cookie_jar` on all subsequent requests
- Write large payloads to a temp file and use `-d @file` to avoid shell escaping issues
- Available tools: `generate`, `get_generation_status`, `get_themes`, `get_folders`

**If API key is not known:** check `~/.claude/settings.json` → `env.GAMMA_API_KEY`. If missing, ask the user.

---

## Step 2 — Accept the plan

Take the full output of the upstream skill as input. Do not ask the user to reformat it.

If no plan is present, ask:
> "Paste your slide outline, or run `slide-deck-planner` or `gtm-deck-planner` first."

Confirm two things only:
- **Deck title** (if not obvious from the plan)
- **Language** — English, Vietnamese, or bilingual?

**Slide count rule:** Count the slides explicitly listed in the plan and pass that exact number as `numCards`. Do not let Gamma decide — always set `numCards`. If the plan has no explicit count, count the sections/cards in the outline and use that number.

---

## Step 3 — Map plan to Gamma cards

Convert each section to a Gamma card. One key idea per card.

| Source content | Gamma card type |
|----------------|-----------------|
| Cover / title | Title card |
| Section divider | Big text / quote card |
| Bullet list (≤5 items) | Text + bullets card |
| Bullet list (>5 items) | Split into two cards |
| Table / comparison | Table card |
| Single stat or metric | Big stat card |
| Process / timeline | Timeline card |
| Architecture / diagram | Image placeholder card |
| Case study | Two-column card — challenge left, results right |
| CTA / next steps | Action card |

**Rules:**
- Card title: 8 words max
- Long prose → speaker notes, not card body
- One number or claim per stat card — don't stack metrics

**GTM doc mapping (from gtm-deck-planner output):**

| GTM section | Cards to create |
|-------------|----------------|
| Market Overview | 2–3 big stat cards (market size, trend, Vietnam angle) |
| ICP & JTBD | One persona card per ICP |
| Competitive Analysis | One comparison table card |
| Value Propositions & Messaging | One card per pillar (FASTER / SECURELY / EFFECTIVELY) |
| Objectives & Activities | Timeline card |
| Success Metrics | Big stat cards |
| Road to Production | Table card (feature status) |

---

## Step 4 — Create the deck in Gamma

Use the `generate` tool via direct HTTP (see Step 1 for connection pattern).

**Generate call arguments:**

```python
"arguments": {
    "inputText": "<full document content>",   # NEVER summarize — pass complete text
    "textMode": "condense",                   # for long docs (>5000 chars); use "generate" for short outlines
    "format": "presentation",
    "themeId": "mbkottin2sutvxw",             # GreenNode 2026 Template.pptx — ALWAYS use this unless user says otherwise
    "numCards": <N>,                          # REQUIRED — set to exact slide count from the slide planner
    "textOptions": {
        "tone": "professional",
        "audience": "executives",
        "language": "en"                      # or "vi" for Vietnamese
    },
    "imageOptions": {
        "source": "aiGenerated",
        "stylePreset": "illustration"
    }
}
```

**textMode selection:**
| Input | textMode |
|-------|----------|
| Short outline / bullet list | `generate` |
| Long GTM doc / full article (>5000 chars) | `condense` |
| Pre-written slide content | `preserve` |

**On success:** response contains `gammaUrl` — share this with the user immediately.

**On errors:**
- 403 on `tools/call` → missing cookie; re-run `initialize` first
- Timeout → call `get_generation_status` with the `generationId` from the response
- Content too long → `textMode: "condense"` handles it; no truncation needed

---

## Step 5 — Auto-open in default browser

Immediately after the deck URL is returned:

1. Open the URL in the system default browser using:
   ```bash
   open "[deck_url]"
   ```
   (On macOS this uses the default browser. On Linux use `xdg-open`; on Windows use `start`.)

If the command fails:
> "Could not open the browser automatically. Open [deck_url] manually in your browser."

---

## Step 6 — Deliver the result

```
✅ Deck created: [Deck Title]
🔗 [gamma_url]
📊 [N] cards — now open in your browser

Review needed (if any):
- Card [N] ([title]): image placeholder — add actual diagram
- Card [N] ([title]): content trimmed — full text in speaker notes
```

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Waiting for user to ask before running | Run automatically after upstream skill finishes |
| Asking user to reformat the plan | Accept gtm-deck-planner / slide-deck-planner output as-is |
| Putting full tables into bullet cards | Use table card type — preserve column headers |
| Stacking 3+ metrics on one stat card | One metric per card |
| Opening browser before deck is published | Always get deck_url first, then run `open` |
| Skipping browser step if URL exists | Always attempt `open [deck_url]` — fallback to manual link if it fails |
