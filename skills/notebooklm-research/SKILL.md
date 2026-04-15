---
name: notebooklm-research
description: Complete API for Google NotebookLM - full programmatic access including features not in the web UI. Create notebooks, add sources, generate all artifact types, download in multiple formats. Activates on explicit /notebooklm or intent like "create a podcast about X"
---

# NotebookLM Automation

Complete programmatic access to Google NotebookLM—including capabilities not exposed in the web UI. Create notebooks, add sources (URLs, YouTube, PDFs, audio, video, images), chat with content, generate all artifact types, and download results in multiple formats.

## Installation

**Requires Python 3.10 or higher.**

```bash
pip install notebooklm-py
```

After install, ensure the CLI is on your PATH. If `notebooklm --help` fails, add the Python scripts directory:

```bash
# macOS/Linux (add to ~/.zshrc or ~/.bashrc)
export PATH="$(python3 -m site --user-base)/bin:$PATH"

# Or run directly
python3 -m pip install notebooklm-py
```

## Prerequisites

**IMPORTANT:** Before using any command, you MUST authenticate:

```bash
notebooklm login          # Opens browser for Google OAuth
notebooklm list           # Verify authentication works
```

If commands fail with authentication errors, re-run `notebooklm login`.

Authentication state is stored locally at `~/.notebooklm/storage_state.json`. On a new device, run `notebooklm login` again.

### CI/CD and Parallel Agents

For automated environments or parallel agent workflows:

| Variable | Purpose |
|----------|---------|
| `NOTEBOOKLM_HOME` | Custom config directory (default: `~/.notebooklm`) |
| `NOTEBOOKLM_AUTH_JSON` | Inline auth JSON - no file writes needed |

**CI/CD setup:** Set `NOTEBOOKLM_AUTH_JSON` from a secret containing your `storage_state.json` contents.

**Parallel agents:** The CLI stores notebook context in a shared file (`~/.notebooklm/context.json`). Multiple concurrent agents using `notebooklm use` can overwrite each other's context.

**Solutions for parallel workflows:**
1. **Always use explicit notebook ID** (recommended): Pass `-n <notebook_id>` instead of relying on `use`
2. **Per-agent isolation:** Set unique `NOTEBOOKLM_HOME` per agent: `export NOTEBOOKLM_HOME=/tmp/agent-$ID`
3. **Use full UUIDs:** Avoid partial IDs in automation (they can become ambiguous)

## Agent Setup Verification

Before starting workflows, verify the CLI is ready:

1. `notebooklm auth check` → Should show authentication status
2. `notebooklm list --json` → Should return valid JSON (even if empty)
3. If either fails → Run `notebooklm login`

## When This Skill Activates

**Explicit:** User says "/notebooklm", "use notebooklm", or mentions the tool by name

**Intent detection:** Recognize requests like:
- "Create a podcast about [topic]"
- "Summarize these URLs/documents"
- "Generate a quiz from my research"
- "Turn this into an audio overview"
- "Create flashcards for studying"
- "Generate a video explainer"
- "Make an infographic"
- "Create a mind map of the concepts"
- "Download the quiz as markdown"
- "Add these sources to NotebookLM"

## Autonomy Rules

**Run automatically (no confirmation):**
- `notebooklm auth check` - diagnose auth issues
- `notebooklm status` - show context
- `notebooklm list` - list notebooks
- `notebooklm source list` - list sources
- `notebooklm source get` - get source details
- `notebooklm source guide` - get source summary
- `notebooklm source stale` - check if source needs refresh
- `notebooklm artifact list` - list artifacts
- `notebooklm artifact get` - get artifact details
- `notebooklm artifact poll` - single status check
- `notebooklm artifact suggestions` - get AI-suggested topics
- `notebooklm artifact wait` - wait for artifact (in subagent context)
- `notebooklm source wait` - wait for source (in subagent context)
- `notebooklm research status` - check research status
- `notebooklm research wait` - wait for research (in subagent context)
- `notebooklm note list` - list notes
- `notebooklm note get` - get note content
- `notebooklm language list` - list supported languages
- `notebooklm language get` - get current language
- `notebooklm language set` - set language (global setting)
- `notebooklm metadata` - export notebook metadata
- `notebooklm use <id>` - set context (⚠️ SINGLE-AGENT ONLY - use `-n` in parallel workflows)
- `notebooklm clear` - clear context
- `notebooklm create` - create notebook
- `notebooklm ask "..."` - chat queries (without `--save-as-note`)
- `notebooklm history` - display conversation history (read-only)
- `notebooklm source add` - add sources
- `notebooklm source add-research` - web/drive research

**Ask before running:**
- `notebooklm delete` - destructive
- `notebooklm source delete` - destructive
- `notebooklm source delete-by-title` - destructive
- `notebooklm artifact delete` - destructive
- `notebooklm note delete` - destructive
- `notebooklm generate *` - long-running, may fail due to rate limits
- `notebooklm download *` - writes to filesystem
- `notebooklm artifact wait` - long-running (when in main conversation)
- `notebooklm source wait` - long-running (when in main conversation)
- `notebooklm research wait` - long-running (when in main conversation)
- `notebooklm ask "..." --save-as-note` - writes a note
- `notebooklm note create` - writes a note
- `notebooklm note save` - modifies a note
- `notebooklm history --save` - writes a note
- `notebooklm share *` - modifies sharing permissions
- `notebooklm source refresh` - triggers re-indexing

## Quick Reference

| Task | Command |
|------|---------|
| Authenticate | `notebooklm login` |
| Diagnose auth | `notebooklm auth check` |
| Diagnose auth (full) | `notebooklm auth check --test` |
| List notebooks | `notebooklm list` |
| Create notebook | `notebooklm create "Title"` |
| Rename notebook | `notebooklm rename <id> "New Title"` |
| Delete notebook | `notebooklm delete <id>` |
| Set context | `notebooklm use <notebook_id>` |
| Show context | `notebooklm status` |
| Clear context | `notebooklm clear` |
| Notebook summary | `notebooklm summary` |
| Notebook metadata | `notebooklm metadata` |
| Add URL source | `notebooklm source add "https://..."` |
| Add file | `notebooklm source add ./file.pdf` |
| Add YouTube | `notebooklm source add "https://youtube.com/..."` |
| Add Google Drive doc | `notebooklm source add-drive <drive_url>` |
| List sources | `notebooklm source list` |
| Get source details | `notebooklm source get <source_id>` |
| Get source fulltext | `notebooklm source fulltext <source_id>` |
| Get source guide | `notebooklm source guide <source_id>` |
| Check if source is stale | `notebooklm source stale <source_id>` |
| Refresh a source | `notebooklm source refresh <source_id>` |
| Rename a source | `notebooklm source rename <source_id> "New Name"` |
| Delete source by ID | `notebooklm source delete <source_id>` |
| Delete source by title | `notebooklm source delete-by-title "Exact Title"` |
| Wait for source | `notebooklm source wait <source_id>` |
| Web research (fast) | `notebooklm source add-research "query"` |
| Web research (deep) | `notebooklm source add-research "query" --mode deep --no-wait` |
| Drive research | `notebooklm source add-research "query" --from drive` |
| Check research status | `notebooklm research status` |
| Wait for research | `notebooklm research wait --import-all` |
| Chat | `notebooklm ask "question"` |
| Chat (new conversation) | `notebooklm ask "question" --new` |
| Chat (specific sources) | `notebooklm ask "question" -s src_id1 -s src_id2` |
| Chat (with references) | `notebooklm ask "question" --json` |
| Chat (save as note) | `notebooklm ask "question" --save-as-note` |
| Chat (save with title) | `notebooklm ask "question" --save-as-note --note-title "Title"` |
| Continue conversation | `notebooklm ask "question" -c <conversation_id>` |
| Configure chat persona | `notebooklm configure` |
| Show conversation history | `notebooklm history` |
| Save history as note | `notebooklm history --save` |
| List artifacts | `notebooklm artifact list` |
| Get artifact details | `notebooklm artifact get <artifact_id>` |
| Poll artifact status | `notebooklm artifact poll <artifact_id>` |
| Wait for artifact | `notebooklm artifact wait <artifact_id>` |
| Rename artifact | `notebooklm artifact rename <artifact_id> "New Name"` |
| Delete artifact | `notebooklm artifact delete <artifact_id>` |
| Export to Google Docs | `notebooklm artifact export <artifact_id>` |
| Get topic suggestions | `notebooklm artifact suggestions` |
| Generate podcast | `notebooklm generate audio "instructions"` |
| Generate podcast (JSON) | `notebooklm generate audio --json` |
| Generate podcast (sources) | `notebooklm generate audio -s src_id1 -s src_id2` |
| Generate video | `notebooklm generate video "instructions"` |
| Generate cinematic video | `notebooklm generate cinematic-video` |
| Generate slide deck | `notebooklm generate slide-deck` |
| Revise a slide | `notebooklm generate revise-slide "prompt" --artifact <id> --slide 0` |
| Generate infographic | `notebooklm generate infographic` |
| Generate report | `notebooklm generate report --format briefing-doc` |
| Generate report (append) | `notebooklm generate report --format study-guide --append "Target: beginners"` |
| Generate quiz | `notebooklm generate quiz` |
| Generate flashcards | `notebooklm generate flashcards` |
| Generate mind map | `notebooklm generate mind-map` |
| Generate data table | `notebooklm generate data-table "description"` |
| Download audio | `notebooklm download audio ./output.mp3` |
| Download video | `notebooklm download video ./output.mp4` |
| Download cinematic video | `notebooklm download cinematic-video ./output.mp4` |
| Download slide deck (PDF) | `notebooklm download slide-deck ./slides.pdf` |
| Download slide deck (PPTX) | `notebooklm download slide-deck ./slides.pptx --format pptx` |
| Download infographic | `notebooklm download infographic ./image.png` |
| Download report | `notebooklm download report ./report.md` |
| Download mind map | `notebooklm download mind-map ./map.json` |
| Download data table | `notebooklm download data-table ./data.csv` |
| Download quiz | `notebooklm download quiz quiz.json` |
| Download quiz (markdown) | `notebooklm download quiz --format markdown quiz.md` |
| Download flashcards | `notebooklm download flashcards cards.json` |
| Download flashcards (md) | `notebooklm download flashcards --format markdown cards.md` |
| Download all of a type | `notebooklm download audio --all ./audio/` |
| List notes | `notebooklm note list` |
| Create note | `notebooklm note create "Title" "Content"` |
| Get note | `notebooklm note get <note_id>` |
| Update note | `notebooklm note save <note_id> "New content"` |
| Rename note | `notebooklm note rename <note_id> "New Title"` |
| Delete note | `notebooklm note delete <note_id>` |
| Sharing status | `notebooklm share status` |
| Enable public link | `notebooklm share public --enable` |
| Share with user | `notebooklm share add user@example.com --permission viewer` |
| Update permission | `notebooklm share update user@example.com --permission editor` |
| Remove access | `notebooklm share remove user@example.com` |
| List languages | `notebooklm language list` |
| Get language | `notebooklm language get` |
| Set language | `notebooklm language set zh_Hans` |

**Parallel safety:** Use explicit notebook IDs (`-n <id>`) in parallel workflows. Most commands support `-n`. Download commands also support `-a/--artifact` to target a specific artifact. For chat, use `-c <conversation_id>` to target a specific conversation.

**Partial IDs:** Use first 6+ characters of UUIDs. Must be unique prefix. Works for all ID-based commands. For automation, prefer full UUIDs.

## Command Output Formats

Commands with `--json` return structured data for parsing:

**Create notebook:**
```
$ notebooklm create "Research" --json
{"id": "abc123de-...", "title": "Research"}
```

**Add source:**
```
$ notebooklm source add "https://example.com" --json
{"source_id": "def456...", "title": "Example", "status": "processing"}
```

**Generate artifact:**
```
$ notebooklm generate audio "Focus on key points" --json
{"task_id": "xyz789...", "status": "pending"}
```

**Chat with references:**
```
$ notebooklm ask "What is X?" --json
{"answer": "X is... [1] [2]", "conversation_id": "...", "turn_number": 1, "is_follow_up": false, "references": [{"source_id": "abc123...", "citation_number": 1, "cited_text": "Relevant passage..."}, {"source_id": "def456...", "citation_number": 2, "cited_text": "Another passage..."}]}
```

**Source fulltext:**
```
$ notebooklm source fulltext <source_id> --json
{"source_id": "...", "title": "...", "char_count": 12345, "content": "Full indexed text..."}
```

**List notebooks:**
```json
{"notebooks": [{"id": "...", "title": "...", "created_at": "..."}]}
```

**List sources:**
```json
{"sources": [{"id": "...", "title": "...", "status": "ready|processing|error"}]}
```

**List artifacts:**
```json
{"artifacts": [{"id": "...", "title": "...", "type": "Audio Overview", "status": "in_progress|pending|completed|unknown"}]}
```

**Status values:**
- Sources: `processing` → `ready` (or `error`)
- Artifacts: `pending` or `in_progress` → `completed` (or `unknown`)

## Generation Types

All generate commands support:
- `-s, --source` to use specific source(s) instead of all sources
- `--language` to set output language (defaults to configured language or `en`)
- `--json` for machine-readable output (returns `task_id` and `status`)
- `--retry N` to automatically retry on rate limits with exponential backoff

| Type | Command | Options | Download |
|------|---------|---------|----------|
| Podcast | `generate audio` | `--format [deep-dive\|brief\|critique\|debate]`, `--length [short\|default\|long]` | .mp3 |
| Video | `generate video` | `--format [explainer\|brief]`, `--style [auto\|classic\|whiteboard\|kawaii\|anime\|watercolor\|retro-print\|heritage\|paper-craft]` | .mp4 |
| Cinematic Video | `generate cinematic-video` | *(AI-generated visuals)* | .mp4 |
| Slide Deck | `generate slide-deck` | `--format [detailed\|presenter]`, `--length [default\|short]` | .pdf / .pptx |
| Slide Revision | `generate revise-slide "prompt" --artifact <id> --slide N` | `--wait`, `--notebook` | *(re-downloads parent deck)* |
| Infographic | `generate infographic` | `--orientation [landscape\|portrait\|square]`, `--detail [concise\|standard\|detailed]`, `--style [auto\|sketch-note\|professional\|bento-grid\|editorial\|instructional\|bricks\|clay\|anime\|kawaii\|scientific]` | .png |
| Report | `generate report` | `--format [briefing-doc\|study-guide\|blog-post\|custom]`, `--append "extra instructions"` | .md |
| Mind Map | `generate mind-map` | *(sync, instant)* | .json |
| Data Table | `generate data-table` | description required | .csv |
| Quiz | `generate quiz` | `--difficulty [easy\|medium\|hard]`, `--quantity [fewer\|standard\|more]` | .json/.md/.html |
| Flashcards | `generate flashcards` | `--difficulty [easy\|medium\|hard]`, `--quantity [fewer\|standard\|more]` | .json/.md/.html |

## Features Beyond the Web UI

| Feature | Command | Description |
|---------|---------|-------------|
| **Batch downloads** | `download <type> --all` | Download all artifacts of a type at once |
| **Quiz/Flashcard export** | `download quiz --format json` | Export as JSON, Markdown, or HTML |
| **Mind map extraction** | `download mind-map` | Export hierarchical JSON for visualization tools |
| **Data table export** | `download data-table` | Download structured tables as CSV |
| **Slide deck as PPTX** | `download slide-deck --format pptx` | Download as editable .pptx (web UI only offers PDF) |
| **Slide revision** | `generate revise-slide "prompt" --artifact <id> --slide N` | Modify individual slides with natural language |
| **Cinematic video** | `generate cinematic-video` | AI-generated visual video (not in web UI) |
| **Source fulltext** | `source fulltext <id>` | Retrieve the indexed text content of any source |
| **Save chat to note** | `ask "..." --save-as-note` / `history --save` | Save Q&A or conversation history as a note |
| **Note management** | `note create/get/save/delete/rename` | Full CRUD for notebook notes |
| **Export to Google Docs** | `artifact export <id>` | Export any artifact to Google Docs/Sheets |
| **Topic suggestions** | `artifact suggestions` | Get AI-suggested report topics from notebook content |
| **Source refresh** | `source refresh <id>` | Re-index a URL/Drive source for fresh content |
| **Notebook summary** | `summary` | AI-generated summary of notebook insights |
| **Metadata export** | `metadata` | Full notebook metadata including all sources |
| **Programmatic sharing** | `share` commands | Manage sharing permissions without the UI |

## Common Workflows

### Research to Podcast (Interactive)
**Time:** 5-10 minutes total

1. `notebooklm create "Research: [topic]"` — *if fails: check auth with `notebooklm login`*
2. `notebooklm source add` for each URL/document — *if one fails: log warning, continue with others*
3. Wait for sources: `notebooklm source list --json` until all status=ready — *required before generation*
4. `notebooklm generate audio "Focus on [specific angle]"` (confirm when asked) — *if rate limited: wait 5 min, retry once*
5. Note the artifact ID returned
6. Check `notebooklm artifact list` later for status
7. `notebooklm download audio ./podcast.mp3` when complete (confirm when asked)

### Research to Podcast (Automated with Subagent)
**Time:** 5-10 minutes, continues in background

When user wants full automation (generate and download when ready):

1. Create notebook and add sources as usual
2. Wait for sources to be ready (`source wait` or check `source list --json`)
3. Run `notebooklm generate audio "..." --json` → parse `artifact_id` from output
4. **Spawn a background agent** using Task tool:
   ```
   Task(
     prompt="Wait for artifact {artifact_id} in notebook {notebook_id} to complete, then download.
             Use: notebooklm artifact wait {artifact_id} -n {notebook_id} --timeout 600
             Then: notebooklm download audio ./podcast.mp3 -a {artifact_id} -n {notebook_id}",
     subagent_type="general-purpose"
   )
   ```
5. Main conversation continues while agent waits

**Error handling in subagent:**
- If `artifact wait` returns exit code 2 (timeout): Report timeout, suggest checking `artifact list`
- If download fails: Check if artifact status is COMPLETED first

### Document Analysis
**Time:** 1-2 minutes

1. `notebooklm create "Analysis: [project]"`
2. `notebooklm source add ./doc.pdf` (or URLs)
3. `notebooklm ask "Summarize the key points"`
4. `notebooklm ask "What are the main arguments?"`
5. Continue chatting as needed

### Bulk Import with Source Waiting (Subagent Pattern)
**Time:** Varies by source count

1. Add sources with `--json` to capture IDs:
   ```bash
   notebooklm source add "https://url1.com" --json  # → {"source_id": "abc..."}
   notebooklm source add "https://url2.com" --json  # → {"source_id": "def..."}
   ```
2. **Spawn a background agent** to wait for all sources:
   ```
   Task(
     prompt="Wait for sources {source_ids} in notebook {notebook_id} to be ready.
             For each: notebooklm source wait {id} -n {notebook_id} --timeout 120
             Report when all ready or if any fail.",
     subagent_type="general-purpose"
   )
   ```
3. Once sources are ready, proceed with chat or generation

**Why wait for sources?** Sources must be indexed before chat or generation. Takes 10-60 seconds per source.

### Deep Web Research (Subagent Pattern)
**Time:** 2-5 minutes, runs in background

1. Create notebook: `notebooklm create "Research: [topic]"`
2. Start deep research (non-blocking):
   ```bash
   notebooklm source add-research "topic query" --mode deep --no-wait
   ```
3. **Spawn a background agent** to wait and import:
   ```
   Task(
     prompt="Wait for research in notebook {notebook_id} to complete and import sources.
             Use: notebooklm research wait -n {notebook_id} --import-all --timeout 300
             Report how many sources were imported.",
     subagent_type="general-purpose"
   )
   ```
4. Main conversation continues while agent waits

**Alternative (blocking):** For simple cases:
```bash
notebooklm source add-research "topic" --mode deep --import-all
# Blocks for up to 5 minutes
```

**When to use each mode:**
- `--mode fast`: Specific topic, quick overview needed (5-10 sources, seconds)
- `--mode deep`: Broad topic, comprehensive analysis needed (20+ sources, 2-5 min)

## Output Style

**Progress updates:** Brief status for each step
- "Creating notebook 'Research: AI'..."
- "Adding source: https://example.com..."
- "Starting audio generation... (task ID: abc123)"

**Fire-and-forget for long operations:**
- Start generation, return artifact ID immediately
- Do NOT poll or wait in main conversation — generation takes 5-45 minutes (see timing table)
- User checks status manually, OR use subagent with `artifact wait`

**JSON output:** Use `--json` flag for machine-readable output:
```bash
notebooklm list --json
notebooklm auth check --json
notebooklm source list --json
notebooklm artifact list --json
notebooklm metadata --json
```

## Error Handling

**On failure, offer the user a choice:**
1. Retry the operation
2. Skip and continue with something else
3. Investigate the error

**Error decision tree:**

| Error | Cause | Action |
|-------|-------|--------|
| Auth/cookie error | Session expired | Run `notebooklm auth check` then `notebooklm login` |
| "No notebook context" | Context not set | Use `-n <id>` flag (parallel), or `notebooklm use <id>` (single-agent) |
| "No result found for RPC ID" | Rate limiting | Wait 5-10 min, retry |
| `GENERATION_FAILED` | Google rate limit | Wait and retry later |
| Download fails | Generation incomplete | Check `artifact list` for status |
| Invalid notebook/source ID | Wrong ID | Run `notebooklm list` to verify |
| RPC protocol error | Google changed APIs | Update CLI: `pip install --upgrade notebooklm-py` |
| `command not found: notebooklm` | Not on PATH | Add Python scripts dir to PATH (see Installation) |

## Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Continue |
| 1 | Error (not found, processing failed) | Check stderr, see Error Handling |
| 2 | Timeout (wait commands only) | Extend timeout or check status manually |

- `source wait` returns 1 if source not found or processing failed
- `artifact wait` returns 2 if timeout reached before completion
- `generate` returns 1 if rate limited (check stderr for details)

## Known Limitations

**Rate limiting:** Audio, video, quiz, flashcards, infographic, and slide deck generation may fail due to Google's rate limits. This is an API limitation, not a bug.

**Reliable operations:**
- Notebooks (list, create, delete, rename)
- Sources (add, list, delete)
- Chat/queries
- Mind-map, study-guide, report, data-table generation

**Unreliable operations (may fail with rate limiting):**
- Audio (podcast) and video generation
- Cinematic video generation
- Quiz and flashcard generation
- Infographic and slide deck generation

**Workaround:** If generation fails — check `notebooklm artifact list`, retry after 5-10 minutes, or use the NotebookLM web UI as fallback.

**Processing times vary significantly:**

| Operation | Typical time | Suggested timeout |
|-----------|--------------|-------------------|
| Source processing | 30s - 10 min | 600s |
| Research (fast) | 30s - 2 min | 180s |
| Research (deep) | 15 - 30+ min | 1800s |
| Notes | instant | n/a |
| Mind-map | instant (sync) | n/a |
| Quiz, flashcards | 5 - 15 min | 900s |
| Report, data-table | 5 - 15 min | 900s |
| Audio generation | 10 - 20 min | 1200s |
| Video generation | 15 - 45 min | 2700s |

**Polling intervals:** When checking status manually, poll every 15-30 seconds.

## Language Configuration

Language is a **GLOBAL** setting affecting all notebooks in your account.

```bash
notebooklm language list           # Show all 80+ supported languages
notebooklm language get            # Show current language
notebooklm language set zh_Hans    # Simplified Chinese
notebooklm language set en         # English (default)
```

**Override per command:** Use `--language` flag on generate commands:
```bash
notebooklm generate audio --language ja        # Japanese podcast
notebooklm generate video --language zh_Hans   # Chinese video
```

**Common language codes:**
| Code | Language |
|------|----------|
| `en` | English |
| `zh_Hans` | 中文（简体） |
| `zh_Hant` | 中文（繁體） |
| `ja` | 日本語 |
| `ko` | 한국어 |
| `es` | Español |
| `fr` | Français |
| `de` | Deutsch |
| `pt_BR` | Português (Brasil) |

## Troubleshooting

```bash
notebooklm --help              # Main commands
notebooklm auth check          # Diagnose auth issues
notebooklm auth check --test   # Full auth validation with network test
notebooklm source --help       # Source management
notebooklm artifact --help     # Artifact management
notebooklm generate --help     # Content generation
notebooklm download --help     # Download content
notebooklm note --help         # Note management
notebooklm share --help        # Sharing commands
notebooklm language --help     # Language settings
notebooklm skill status        # Check if skill is installed and version info
notebooklm --version           # Check CLI version
```

**Update CLI:** `pip install --upgrade notebooklm-py`

**Source limits:** Varies by plan — Standard: 50, Plus: 100, Pro: 300, Ultra: 600 sources per notebook. The CLI does not enforce these limits; they are applied by your account.

**Supported source types:** PDFs, YouTube URLs, web URLs, Google Docs, Google Drive files, text files, Markdown, Word docs, audio files, video files, images
