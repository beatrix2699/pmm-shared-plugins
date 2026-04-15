# gamma-deck-creator — Design Spec

**Date:** 2026-04-01
**Status:** Implemented (updated to reflect actual build)

---

## Overview

A standalone skill `gamma-deck-creator` that takes the completed output of `slide-deck-planner` or `gtm-deck-planner`, confirms a deck title and language, then creates the presentation in Gamma via direct HTTP MCP and auto-opens the result in Comet browser.

---

## Pipeline Position

This skill is the **final step** in the deck creation pipeline:

```
gtm-deck-planner  ──┐
                    ├──▶  gamma-deck-creator  ──▶  Comet browser (auto-open)
slide-deck-planner ──┘
```

When either upstream skill finishes, this skill runs immediately — **do not wait for the user to ask**.

---

## Trigger

**Skill name:** `gamma-deck-creator`

**Trigger phrases:**
- "create in Gamma"
- "build the deck in Gamma"
- "make this a Gamma presentation"
- "turn this into slides"
- Auto-triggered when `slide-deck-planner` or `gtm-deck-planner` output is complete

**Pre-condition:** A slide plan or GTM strategy document must be present in context. If not, ask:
> "Paste your slide outline, or run `slide-deck-planner` or `gtm-deck-planner` first."

---

## Flow

### Step 1 — Check Gamma connection

Gamma is accessed via direct HTTP to `https://mcp.gamma.app/mcp` using `x-api-key` authentication.
API key is stored in `~/.claude/settings.json` as `GAMMA_API_KEY`.

**Connection pattern:**

1. POST `initialize` to `https://mcp.gamma.app/mcp` with `x-api-key` header — this returns the Cloudflare `__cf_bm` cookie
2. Save cookie to `/tmp/gamma_cookies.txt`
3. All subsequent `tools/call` requests must send `-b cookie_jar -c cookie_jar`
4. Write large payloads to `/tmp/gamma_payload.json` and use `-d @file` to avoid shell escaping issues

**Key rules:**
- Always `initialize` first — without the CF cookie, `tools/call` returns 403
- Available tools: `generate`, `get_generation_status`, `get_themes`, `get_folders`
- If API key is missing: check `~/.claude/settings.json` → `env.GAMMA_API_KEY`; if absent, ask the user

---

### Step 2 — Accept the plan

Take the full output of the upstream skill as input. Do not ask the user to reformat it.

Confirm **two things only** (no 4-question prompt):
- **Deck title** — if not obvious from the plan
- **Language** — English, Vietnamese, or bilingual?

**Slide count:** Count the slides explicitly listed in the plan. Pass that exact number as `numCards`. Do not let Gamma decide. If no explicit count, count the sections/cards in the outline.

---

### Step 3 — Map plan to Gamma cards

Convert each section to a Gamma card (one key idea per card):

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

**Content rules:**
- Card title: 8 words max
- Long prose → speaker notes, not card body
- One number or claim per stat card — don't stack metrics

**GTM doc mapping (from `gtm-deck-planner` output):**

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

### Step 4 — Create the deck in Gamma

Call `generate` via direct HTTP (see Step 1).

**Generate arguments:**

```python
{
    "inputText": "<full document content>",   # NEVER summarize — pass complete text
    "textMode": "condense",                   # see table below
    "format": "presentation",
    "themeId": "mbkottin2sutvxw",             # GreenNode 2026 Template — ALWAYS use unless user says otherwise
    "numCards": <N>,                          # REQUIRED — exact slide count from plan
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

**On success:** response contains `gammaUrl` — share with user immediately.

**On errors:**
- 403 on `tools/call` → missing cookie; re-run `initialize` first
- Timeout → call `get_generation_status` with the `generationId` from the response
- Content too long → `textMode: "condense"` handles it; no truncation needed

---

### Step 5 — Auto-open in Comet browser

Immediately after `generate` returns the URL:

1. Call `comet_connect` to ensure Comet browser is running
2. Call `comet_ask`:
   ```
   prompt: "Open this URL and show me the deck: [deck_url]"
   ```

If Comet is not connected:
> "Comet browser isn't running. Open [deck_url] manually in your browser."

---

### Step 6 — Deliver the result

```
✅ Deck created: [Deck Title]
🔗 [gamma_url]
📊 [N] cards — now open in Comet

Review needed (if any):
- Card [N] ([title]): image placeholder — add actual diagram
- Card [N] ([title]): content trimmed — full text in speaker notes
```

---

## Error Handling

| Situation | Behavior |
|-----------|----------|
| 403 on `tools/call` | Re-run `initialize` to refresh CF cookie, then retry |
| Timeout on `generate` | Poll `get_generation_status` with `generationId` |
| No plan in context | Ask user to paste outline or run a planner skill first |
| API key missing | Check `~/.claude/settings.json`; if absent, ask user |
| Comet not running | Skip Comet step; provide manual link to user |

---

## Design Decisions (vs. original spec)

| Original spec | Actual implementation | Reason |
|---------------|----------------------|--------|
| 4 visual questions (theme, slide count, audience, language) | Confirm title + language only | Theme hardcoded to GreenNode template; numCards derived from plan |
| `mcp__claude_ai_Gamma__authenticate` | Direct HTTP curl with cookie management | MCP transport required CF cookie workaround |
| "Open in browser" (generic) | Auto-open in Comet browser specifically | Comet integration available |
| 5-step flow | 6-step flow | Connection step separated from generation |
| QA checklist from source planner | Inline review notes (placeholders + trimmed content) | Simpler delivery — source planner already has its own QA |
| Wait for user to trigger | Auto-run after upstream skill | Pipeline design decision for speed |

---

## Scope Boundaries

- This skill **only creates** — it does not edit existing Gamma decks
- This skill does **not invent content** — only uses what the plan provides
- Theme is fixed to GreenNode 2026 Template per session unless user overrides
- Does not re-run the source planner — if user wants to update content, they go back to the planner skill first

---

## Relationship to Existing Skills

| Skill | Relationship |
|-------|-------------|
| `slide-deck-planner` | Source of slide structure |
| `gtm-deck-planner` | Source of GTM sections |
| `comet-browser` | Auto-opens the resulting deck URL |
| `gamma-deck-creator` | Consumes output from either planner; creates in Gamma |

The upstream skills are **not modified**. This skill is purely additive.
