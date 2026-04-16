---
name: icp-research
description: "Use when the user wants to research, define, score, or refine their Ideal Customer Profile (ICP). Triggers on: 'ICP research', 'ideal customer profile', 'who should we target', 'define our ICP', 'score accounts', 'account prioritization', 'buyer committee', 'market sizing', 'TAM SAM SOM', 'lookalike audience', 'customer fit', 'ICP gap analysis', 'interview analysis for ICP', 'which accounts to prioritize', 'build ICP', 'refine ICP'. Uses the icp-intelligence MCP server for deep pattern detection and analysis."
metadata:
  version: 1.0.0
---

# ICP Research

You help users define, validate, score, and activate their Ideal Customer Profile using AI-powered analysis. This skill uses the **icp-intelligence MCP server** which provides 9 specialized tools for the full ICP lifecycle.

## Before Starting

Check if `.agents/product-marketing-context.md` exists. If it does, read it — it contains product, audience, and positioning context that will pre-fill many inputs. If it doesn't, suggest running `/product-marketing-context` first to build that foundation.

---

## Mode Selection

Ask the user which mode they need, or infer from their request:

| Mode | When to use | Primary tools |
|------|-------------|---------------|
| **A. Define ICP** | Starting from scratch or validating assumptions | `icp_deep_dive`, `buyer_group_analyzer` |
| **B. Score & Prioritize** | Have an ICP, need to rank accounts | `icp_scoring_model`, `account_prioritization` |
| **C. Gap Analysis** | Have customers, want to compare to ideal | `icp_gap_analysis`, `icp_evolution_tracker` |
| **D. Market Sizing** | Need TAM/SAM/SOM for planning or fundraising | `tam_sam_som_calculator` |
| **E. Activation** | Ready to run ads or find lookalikes | `lookalike_signal_generator` |
| **F. Interview Synthesis** | Have customer interview notes to analyze | `icp_interview_synthesizer` |
| **G. Full ICP Sprint** | New product or major repositioning — run all tools in sequence | All tools |

---

## Mode A: Define ICP

**Goal:** Identify who your best customers are and what patterns they share.

### Step 1: Gather customer data
Ask the user to provide:
- List of current customers (company names, industries, sizes, revenue, tenure)
- Which ones are the "best" customers (highest LTV, lowest churn, best fit)
- Any industry focus they already have in mind

### Step 2: Run icp_deep_dive
```
Use icp_deep_dive with:
- customer_data: the customer list provided
- best_customers: the highlighted top customers
- industry_focus: any stated focus (optional)
```

### Step 3: Run buyer_group_analyzer
```
Use buyer_group_analyzer with:
- product: from product-marketing-context or user input
- target_company_size: from the ICP patterns found above
- deal_complexity: ask if enterprise (complex) or SMB (simple)
```

### Step 4: Synthesize & document
Present findings as a structured ICP definition:
- Firmographic profile (industry, size, stage, geography)
- Technographic signals
- Buying committee map (roles, motivations, objections)
- Key triggers that indicate readiness to buy

Ask if they want to save this to `.agents/icp-profile.md` and update `.agents/product-marketing-context.md`.

---

## Mode B: Score & Prioritize Accounts

**Goal:** Build a scoring model and rank a list of accounts.

### Step 1: Confirm ICP attributes
Ask for (or read from `.agents/icp-profile.md`):
- The ICP attributes to score against
- Whether this is for inbound lead scoring or outbound account selection

### Step 2: Run icp_scoring_model
```
Use icp_scoring_model with:
- icp_attributes: the confirmed ICP attributes
- deal_data: win/loss data if available
- scoring_type: "lead" or "account" (ask user)
```

### Step 3: Run account_prioritization
```
Use account_prioritization with:
- accounts: the list of accounts to rank (ask user to provide)
- icp_criteria: scoring model output from above
- intent_signals: any intent data available (G2, Bombora, etc.)
- relationship_data: any existing relationships (optional)
```

### Step 4: Deliver tiered output
Present accounts in tiers:
- **Tier 1 — Priority:** Strong fit, act now
- **Tier 2 — Watch:** Good fit, nurture
- **Tier 3 — Low priority:** Weak fit, deprioritize

Ask if they want this exported to a Lark task list (use lark-task-creator skill).

---

## Mode C: Gap Analysis & Evolution

**Goal:** Understand how current customers compare to the ideal, and how ICP is shifting.

### Step 1: Run icp_gap_analysis
```
Use icp_gap_analysis with:
- current_customers: list of current customers with attributes
- ideal_icp: the ICP definition (from icp-profile.md or user input)
- key_metrics: ask which metrics matter most (LTV, churn rate, NPS, etc.)
```

### Step 2: Run icp_evolution_tracker (if historical data available)
```
Use icp_evolution_tracker with:
- historical_data: customer data from different time periods
- time_period: the period to analyze (e.g., "last 12 months")
- win_loss_patterns: win/loss trends if available
```

### Step 3: Identify actions
Based on the gaps, recommend:
- Segments to double down on
- Segments to exit or deprioritize
- Messaging adjustments needed
- Sales qualification criteria to tighten or loosen

---

## Mode D: Market Sizing (TAM/SAM/SOM)

**Goal:** Quantify the addressable market for planning, fundraising, or board reporting.

### Step 1: Gather inputs
Ask for:
- Product description (or read from context)
- Target segments (who you're going after)
- Pricing model (ACV, monthly, per seat, etc.)
- Geographic focus (global, APAC, specific countries)

### Step 2: Run tam_sam_som_calculator
```
Use tam_sam_som_calculator with:
- product: product description
- target_segments: list of target segments
- pricing: pricing model and ranges
- geographic_focus: geography
- data_sources: any known data sources (optional)
```

### Step 3: Present results
Deliver as:
- **TAM:** Total Addressable Market — if you captured 100%
- **SAM:** Serviceable Addressable Market — realistic reach with current GTM
- **SOM:** Serviceable Obtainable Market — realistic 1-3 year target

Include assumptions clearly so it's defensible for board/investor use.

---

## Mode E: Lookalike & Ad Targeting

**Goal:** Generate platform-specific targeting criteria to find more customers who look like your ICP.

### Step 1: Confirm ICP profile
Read from `.agents/icp-profile.md` or ask user to describe their ICP.

### Step 2: Ask which platforms
- LinkedIn (most common for B2B)
- Google/YouTube
- Meta
- Programmatic (DV360, The Trade Desk)

### Step 3: Run lookalike_signal_generator
```
Use lookalike_signal_generator with:
- icp_profile: the confirmed ICP profile
- platforms: the platforms selected
- budget_tier: ask (e.g., "under $10k/month", "$10k-$50k/month", "enterprise")
```

### Step 4: Deliver targeting specs
For each platform, provide:
- Job titles and seniority
- Company size filters
- Industry categories
- Skills/interests (LinkedIn)
- Keywords (Google)
- Lookalike audience seeds

---

## Mode F: Interview Synthesis

**Goal:** Extract ICP patterns from customer discovery or sales call notes.

### Step 1: Collect interview notes
Ask user to paste or describe:
- Customer interview transcripts or notes
- Sales call notes
- Win/loss interview summaries

### Step 2: Run icp_interview_synthesizer
```
Use icp_interview_synthesizer with:
- interview_notes: the raw interview content
- interview_type: "customer_discovery", "win", "loss", or "churn" (ask user)
- focus_areas: what patterns to extract (pain points, triggers, objections, etc.)
```

### Step 3: Surface key patterns
Present:
- Common pain points and triggers
- Language customers use to describe problems
- Objections and how they were handled
- Moments of "aha" or value realization
- Signals that predicted fit vs. poor fit

Offer to update `.agents/product-marketing-context.md` with the customer language patterns found.

---

## Mode G: Full ICP Sprint

Run all modes in sequence for a new product or major repositioning:

1. **Interview Synthesis** (if notes available) → extract raw patterns
2. **Define ICP** → icp_deep_dive + buyer_group_analyzer
3. **Market Sizing** → tam_sam_som_calculator
4. **Scoring Model** → icp_scoring_model
5. **Gap Analysis** → icp_gap_analysis (if existing customers exist)
6. **Activation** → lookalike_signal_generator

Deliver a complete ICP Intelligence Report saved to `.agents/icp-intelligence-report-{YYYY-MM-DD}.md`.

---

## Output Formats

After each analysis, ask how the user wants to use the results:

- **Document it** → Save to `.agents/icp-profile.md`
- **Build a deck** → Hand off to `gamma-deck-creator` skill
- **Create tasks** → Hand off to `lark-task-creator` skill
- **Run ads** → Hand off to `paid-ads` or `weavy-design-creator` skill
- **Refine messaging** → Hand off to `copywriting` or `product-marketing-context` skill

---

## Tips

- Always cross-reference findings against the product marketing context — ICP should align with positioning
- Push for specific data over generalizations: named accounts > "mid-market SaaS companies"
- When interview notes are available, run Mode F first — real customer language beats assumptions
- ICP is a hypothesis until validated with win/loss data; flag this clearly in outputs
- For GreenNode, default industry focus to: AI/ML infrastructure, GPU compute, cloud-native startups, research institutions
