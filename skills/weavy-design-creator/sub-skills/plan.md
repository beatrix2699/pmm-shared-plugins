# Plan Phase

You are in Phase 1 of weavy-design-creator. Your job is to collect a campaign brief and content pieces, generate one asset entry per content piece × format, and save a campaign plan file.

Read `references/weavy-nodes.md` before generating any prompts.

---

## Step 1 — Check for Upstream Context

Before asking any questions, scan the current conversation for output from upstream skills:
- `social-content` output → extract each post as a content piece
- `content-strategy` output → extract each recommended article/topic as a content piece
- `email-sequence` output → extract each email as a content piece

If upstream content is found, pre-fill the content_pieces list and skip Step 4. Tell the user: "I found [N] content pieces from [skill name]. Using those — please confirm or edit."

---

## Step 2 — Collect Campaign Brief

Ask for the following in order. One question at a time. Skip any field the user has already provided.

1. **Campaign name** — "What should we call this campaign? (e.g., 'GreenNode April Launch')"

2. **Campaign brief** — "Describe the visual mood and style in free text. Include: tone, colors you're thinking of, any references, overall feel. (e.g., 'Dark techy, purple neon, cinematic, premium GPU product')"

3. **Primary colors** — "What are the primary brand colors for this campaign? (provide hex codes, e.g., #6B2FFA, #1A1A2E)"

4. **Logo placement** — "Where should the logo be placed? Options: bottom-right / bottom-left / none / top-right / top-left"

5. **Aspect ratios** — "Which formats do you need? Select all that apply: 1:1 / 16:9 / 9:16 / 4:5"

6. **Negative prompts** — "Anything to avoid in all generated images? I'll add the standard quality exclusions automatically."
   - Append defaults from `references/weavy-nodes.md` § Negative Prompt Defaults to whatever the user provides.

7. **Reference image URL** — "Do you have a reference image for visual style? (optional — paste URL or press Enter to skip)"

8. **Weavy workflow URL** — "Paste your Figma Weave workflow URL. (e.g., https://app.weavy.ai/workflows/abc123)"

---

## Step 3 — Build System Prompt

Using the collected brief and locked params, generate the campaign system_prompt using the template from `references/weavy-nodes.md` § System Prompt Template:

```
You are generating visuals for [campaign.name].
Style: [campaign.brief]. Colors: [campaign.locked_params.primary_colors joined by comma]. Avoid: [campaign.negative_prompts].
Maintain visual consistency across all assets in this campaign.
```

Show the generated system_prompt to the user and ask: "Does this system prompt look right? (y / edit)"

If "edit" — let the user modify it inline. Use their version as system_prompt for all assets.

---

## Step 4 — Collect Content Pieces

If not pre-filled from upstream context, ask:

"Paste your content pieces below. Each piece on a new line, or as a numbered list. I'll assign them IDs automatically."

Format each as:
```yaml
- id: "cp-{N:02d}"
  source: "free-text"
  raw_content: "[full text as provided]"
  intent: "[inferred: awareness | engagement | conversion]"
```

Infer `intent` from the text:
- Promotional, offer, CTA-heavy → conversion
- Question, poll, discussion → engagement
- Educational, announcement, news → awareness

If intent is ambiguous, ask: "Is cp-{N} meant for awareness, engagement, or conversion?"

---

## Step 5 — Generate Asset Entries

For each `content_piece × aspect_ratio` combination:

1. Read the matching prompt pattern from `references/weavy-nodes.md` § Prompt Patterns by Campaign Type — choose the pattern that best fits `campaign.brief` and `content_piece.intent`
2. Substitute `[primary_color]` with `campaign.locked_params.primary_colors[0]`
3. Substitute `[format]` with the current aspect_ratio
4. Add 1-2 content-specific phrases extracted from `content_piece.raw_content` (key nouns or visual concepts only — no text/copy)

Build each asset entry:
```yaml
- id: "cp-{N:02d}-{format_slug}"   # format_slug: 1x1 | 16x9 | 9x16 | 4x5
  content_piece_id: "cp-{N:02d}"
  format: "{aspect_ratio}"
  generated_prompt: "{constructed prompt}"
  system_prompt: "{campaign system_prompt}"
  estimated_cost: "{low | med | high}"   # low=<10s model, med=10-30s, high=>30s or video
  status: "pending"
```

Default `estimated_cost` to "med" unless:
- Model Selector is set to a video model → high
- Simple flat/vector style → low

---

## Step 6 — Pre-Save Confirmation

Show this summary before saving:

```
─────────────────────────────────────
Campaign:       [campaign.name]
Content pieces: [N]
Formats:        [list] ([N] per piece)
Total assets:   [N × formats]
Est. cost:      [LOW | MED | HIGH — based on majority of assets]
Workflow URL:   [weavy_workflow_url]
─────────────────────────────────────
Save plan? (y / n / show-prompts)
```

If `show-prompts`: print all generated_prompt values with their asset IDs so the user can review before saving.

If `n`: ask "What would you like to change?" and loop back to the relevant step.

---

## Step 7 — Save Plan File

On `y`, write the plan file to:
`.agents/superpowers/plans/campaign-plan-{campaign.name slug}-{YYYY-MM-DD}.md`

Where `{campaign.name slug}` = lowercase, spaces replaced with `-`, special chars removed.

File format:

```markdown
# Campaign Plan: [campaign.name]
**Created:** [YYYY-MM-DD]
**Workflow URL:** [weavy_workflow_url]

## Campaign Brief
[campaign.brief]

## System Prompt
[system_prompt]

## Locked Params
- Primary colors: [hex list]
- Logo placement: [value]
- Aspect ratios: [list]
- Negative prompts: [value]

## Assets

| ID | Content Piece | Format | Est. Cost | Status |
|----|--------------|--------|-----------|--------|
[one row per asset]

## Asset Details

### [asset.id]
**Content piece:** [cp id] — [first 80 chars of raw_content]...
**Format:** [format]
**Prompt:**
> [generated_prompt]

**System prompt:**
> [system_prompt]

**Status:** pending
```

After saving, print:

```
Plan saved to .agents/superpowers/plans/campaign-plan-[slug]-[date].md
Run with: /weavy-design-creator run
```

Then exit Phase 1. Do not start Phase 2 automatically.
