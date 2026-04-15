---
name: slide-deck-planner
description: >
  Generate a detailed slide planning blueprint for GreenNode marketing presentations.
  Use when the GreenNode marketing team needs to plan or outline a new deck: sales pitches,
  product demos, webinars, case studies, technical reviews, battlecards, or partnership decks.
  Trigger on: "tạo dàn bài slide", "lên kế hoạch slide", "chuẩn bị deck", "slide plan",
  "pitch deck", "sales deck", "demo deck", "làm slide cho", "cần deck cho", "prepare slides",
  "plan a presentation", or any request combining GreenNode products (IDP, Cloud, GPU) with
  an industry (Banking, Insurance, Gaming, Logistics, Retail, E-commerce, F&B, Education).
  Also trigger for: "webinar", "hội thảo", "demo day", "họp với khách hàng", "campaign mới".
  Produces an actionable slide-by-slide outline plus production checklists a designer and
  content writer can use directly.
---

# Slide Type Frameworks

## How to use this file
Find the deck type requested by the user, then use its framework to populate the slide outline and checklists in your output. Adapt the exact slide count and structure to the context (shorter for internal pitches, longer for formal RFPs).

---

## TYPE 1: Pitch Deck / Sales Deck
**Purpose:** Convince a prospective customer to sign a contract or move to the next stage (POC, demo, deeper meeting).

### Standard Slide Structure (20-25 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Opening | 1-3 | Cover, Agenda (01/02/03...), GreenNode company intro (VNG Group connection, key stats) |
| Market Context | 4-6 | Industry trends (big stat + Gartner/IDC/PwC source), Pain points specific to this industry, "Every business has distinct challenges" problem matrix |
| Pivot Slide | 7 | Full-bleed statement: "The core of most [industry] challenges lies in [root cause]." + GreenNode solution promise |
| Solution Overview | 8-10 | GreenNode product intro, Architecture diagram / tech stack, Deployment options (SaaS, On-prem, Hybrid) |
| Why GreenNode | 11-12 | "Why Us" slide (5 differentiators), PAYG cost model + pricing philosophy |
| Case Studies | 13-17 | 2-3 customer case studies (challenge → solution → results with numbers) |
| Customer Logos | 18 | "Our Customers" grid by industry segment |
| Call to Action | 19-20 | Next steps (POC proposal, demo offer), Contact + team slide |

### Pre-Production Checklist
- [ ] Identify ICP (Ideal Customer Profile): company size, industry sub-segment, known pain points
- [ ] Confirm which GreenNode product is primary focus (Cloud vs IDP vs both)
- [ ] Select 2-3 case studies most relevant to this specific prospect
- [ ] Gather current industry stats (< 2 years old) from Gartner, IDC, Deloitte, PwC, or GreenNode's own data
- [ ] Confirm audience seniority level (C-level vs technical vs procurement)
- [ ] Prepare pricing framework or at least "pricing philosophy" slide (PAYG, cost savings %)
- [ ] Confirm language (EN/VN) and bilingual requirements
- [ ] Check if prospect is already in GreenNode's "NOT PUBLIC" category (VIB, TPBank, etc.)

### Content QA Checklist
- [ ] Value proposition is stated clearly in 1 sentence within first 3 slides
- [ ] At least 1 industry stat with source cited (Gartner, Deloitte, IDC, PwC, GMI, Precedence Research)
- [ ] Every claim has a number (%, VND savings, processing speed, document count)
- [ ] Pain points match exactly what this industry experiences (not generic)
- [ ] Case studies are from the same industry as the prospect (or adjacent)
- [ ] "Why GreenNode vs alternatives" is answered either explicitly or implicitly
- [ ] Clear next step / CTA on final slide

### Design QA Checklist
- [ ] Cover slide: GreenNode logo, deck title, date, prospect name/logo if known
- [ ] Agenda slide uses 01/02/03 numbering with circle-arrow icons
- [ ] Section dividers use full-bleed dark green/black background
- [ ] Pain points slide uses visual contrast (light vs dark blocks)
- [ ] Case study slides follow: logo + challenge (left) | solution + impact (right) layout
- [ ] "NOT PUBLIC" label on confidential case slides
- [ ] GreenNode logo + "a member of VNG Group" on every slide footer
- [ ] Consistent use of bright green accent for key metrics
- [ ] All images are high-resolution and industry-relevant

### Post-Delivery Checklist
- [ ] Send deck with email recap summarizing key pain points addressed
- [ ] Follow up within 48h to schedule next meeting or POC
- [ ] Log prospect feedback on which slides resonated most
- [ ] Update case study library if new results became available during meeting
- [ ] Prepare a custom cut of the deck if prospect requests specific focus area

---

## TYPE 2: Product Demo Deck
**Purpose:** Walk through product features in a live or recorded demo context; audience is technical/operations team evaluating the product.

### Standard Slide Structure (15-20 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Context | 1-3 | Cover, Agenda, Use case overview (what problem we're solving today) |
| Architecture | 4-5 | System architecture diagram, Integration options (API, on-prem, SaaS), Data flow |
| Demo Flow | 6-14 | Step-by-step screen flow (each major screen = 1 slide), Key features highlighted, Edge cases and error handling |
| Results & Benchmarks | 15-16 | Performance metrics (speed, accuracy, throughput), Comparison to previous solution |
| Implementation | 17-18 | Deployment timeline, Technical requirements, Support model |
| Q&A Setup | 19-20 | Common questions prepared, Next steps / sandbox access |

### Pre-Production Checklist
- [ ] Confirm demo environment is live and stable
- [ ] Prepare sample data from the customer's industry (banking docs, insurance claims, retail invoices, etc.)
- [ ] Define the "golden path" demo flow (most impressive sequence of steps)
- [ ] Prepare fallback screenshots in case live demo fails
- [ ] Know the key technical specs the audience cares about (accuracy %, throughput, API response time)
- [ ] Identify integration with existing systems the customer uses (SAP, Salesforce, core banking, WMS, etc.)

### Content QA Checklist
- [ ] Each demo step has a clear "so what" — what this feature solves for the customer
- [ ] Benchmarks shown are from comparable environments (not cherry-picked lab conditions)
- [ ] Architecture diagram is technically accurate and matches actual deployment
- [ ] API documentation reference included for technical evaluators
- [ ] Security and compliance posture addressed (data residency, encryption, access control)

### Design QA Checklist
- [ ] Screen captures are high-resolution (not blurry when projected)
- [ ] Annotate screenshots with callout arrows to highlight key UI elements
- [ ] Demo flow arrows/numbers show sequence clearly
- [ ] Architecture diagrams use consistent icon library (not mixed icon styles)
- [ ] Performance metrics use visual charts, not just text

### Post-Delivery Checklist
- [ ] Send recorded demo link if session was recorded
- [ ] Provide sandbox credentials or trial access if applicable
- [ ] Share technical documentation and API specs
- [ ] Schedule POC kick-off within 1-2 weeks

---

## TYPE 3: Thought Leadership / Webinar Deck
**Purpose:** Position GreenNode as an industry authority. Educate the audience on trends and challenges; product is mentioned but not sold hard. Best for top-of-funnel awareness.

### Standard Slide Structure (25-35 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Opening | 1-4 | Cover, Speaker intro, Agenda, "What we'll cover today" |
| Market Landscape | 5-10 | 3-5 key industry trends (each with big stat), Market size data and CAGR, What leading companies are doing |
| Challenge Deep Dive | 11-15 | 3-4 pain points in detail (with customer perspective), The cost of inaction, Common failed approaches |
| Solutions Framework | 16-22 | Framework for solving the problem (not just GreenNode), Where AI/Cloud fits, GreenNode's approach (natural introduction) |
| Real-World Evidence | 23-27 | 2-3 case studies (anonymized if needed), Lessons learned, Best practices |
| Takeaways & Next Steps | 28-32 | Top 5 actionable takeaways, Resources for follow-up, Q&A slide, Thank you + contact |

### Pre-Production Checklist
- [ ] Define learning objectives: what should the audience know/do after watching?
- [ ] Research audience demographics (industry, seniority, Vietnamese vs international?)
- [ ] Source industry statistics (< 2 years old, authoritative sources)
- [ ] Prepare speaker notes — these slides will be presented live, not read independently
- [ ] Plan 15-20 minute Q&A time and prepare 5 "seed" questions
- [ ] Register webinar platform and prepare registration page
- [ ] Plan post-webinar lead nurturing sequence

### Content QA Checklist
- [ ] Every trend claim has a cited source
- [ ] GreenNode product mention feels natural, not forced (max 25% of slides are product-focused)
- [ ] Case studies are told as stories, not feature lists
- [ ] Audience can take at least 3 specific actions from the content
- [ ] Content is relevant regardless of whether audience buys GreenNode

### Design QA Checklist
- [ ] Speaker headshot and bio on opening slides
- [ ] Agenda slide clearly lists what's covered and what's NOT (set expectations)
- [ ] Data visualizations are simple enough to read in 5 seconds
- [ ] Quote slides use large text with attribution
- [ ] Brand watermark visible but not distracting during screen share

### Post-Delivery Checklist
- [ ] Upload recording to YouTube/website within 24h with SEO title
- [ ] Send recording + summary to all registrants (including no-shows)
- [ ] Extract 5-10 short clips for social media
- [ ] Create follow-up blog post summarizing key insights
- [ ] Tag attendees who asked questions for sales follow-up

---

## TYPE 4: Case Study Deck
**Purpose:** Build trust by demonstrating real results with real customers. Used in sales (to close hesitant prospects) or marketing (as standalone content).

### Standard Slide Structure (8-15 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Cover | 1 | Title: "[Customer] + GreenNode: [Result headline]", Customer logo prominent |
| Customer Background | 2 | Company overview: size, industry, what they do, scale of operations |
| Business Challenges | 3-4 | 3-5 pain points (specific, quantified where possible), Previous approach and why it failed |
| GreenNode Solution | 5-7 | Solution overview diagram, Key features implemented, Deployment approach |
| Results & Impact | 8-10 | Quantified outcomes (speed, cost, accuracy, volume), Before/after comparison, Customer quote |
| Why GreenNode Won | 11 | Key decision factors: technical fit, local expertise, pricing, support |
| Next Steps | 12-13 | Current expansion/upsell, Invitation to similar organizations |

### Pre-Production Checklist
- [ ] Get written approval from customer (or confirm "NOT PUBLIC" status and remove identifying info)
- [ ] Gather all quantitative results (% improvement, volume processed, cost savings, time savings)
- [ ] Secure 1-2 customer quotes from named contacts
- [ ] Get customer logo in high-res
- [ ] Verify results are recent (last 12-18 months) and accurately represent deployed state

### Content QA Checklist
- [ ] Challenge section uses customer's own words/framing (not GreenNode's interpretation)
- [ ] Results are specific and verifiable (not "significantly improved")
- [ ] Customer quote is attributed with name + title
- [ ] "Why GreenNode" reflects actual customer's stated reasons, not internal assumptions
- [ ] For "NOT PUBLIC" cases: remove company name, logo, contact details; use "A Leading Bank" etc.

### Design QA Checklist
- [ ] Customer logo on cover and header
- [ ] Results section uses bold visual: large % numbers, before/after table, or infographic
- [ ] Color scheme blends GreenNode brand with customer brand where appropriate
- [ ] "NOT PUBLIC" watermark on confidential versions

### Post-Delivery Checklist
- [ ] Publish public version on GreenNode website/blog
- [ ] Create 1-page PDF version for sales collateral
- [ ] Add to sales enablement library under correct industry tag
- [ ] Send to similar prospects as part of outreach sequences

---

## TYPE 5: Technical Architecture Deck
**Purpose:** Give technical teams (IT architects, DevOps, CTO) the confidence that GreenNode's infrastructure is solid, well-designed, and integrable with their systems.

### Standard Slide Structure (20-30 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Executive Summary | 1-2 | Architecture at a glance (1 diagram), Key technical principles |
| Infrastructure Overview | 3-6 | Physical infrastructure (data centers, redundancy, availability zones), Compute, storage, networking services, Security architecture overview, SLA and uptime guarantees |
| AI & Platform Layer | 7-10 | GPU specifications and configurations, AI Stack services, MLOps capabilities, Container platform (VKS) |
| Integration Patterns | 11-14 | API Gateway design, Connector library (ERP, WMS, TMS, banking core, insurance platforms), Data synchronization patterns, Authentication & access control (IAM, SSO, RBAC) |
| Industry-Specific Stack | 15-20 | Tech stack diagram specific to this customer's industry, Data flow diagrams, Recommended architecture for their use case |
| Security & Compliance | 21-24 | Regulatory compliance (Data Law 2024, PDPL 2025, Circular 09), Security controls (SOC, vWAF, IDS/IPS, DLP), Penetration testing and audit approach |
| Implementation | 25-28 | Migration methodology, Timeline estimate, Resource requirements, Support model |

### Pre-Production Checklist
- [ ] Understand current customer tech stack (what systems they run, what they want to integrate with)
- [ ] Know their compliance requirements (banking regulations, data residency laws, etc.)
- [ ] Prepare environment-specific architecture diagram (not generic)
- [ ] Have GreenNode infrastructure specs ready (server specs, network topology, data center locations)
- [ ] Identify technical evaluators (infrastructure team, security team, development team)

### Content QA Checklist
- [ ] All architecture diagrams are accurate and show real GreenNode topology
- [ ] SLA numbers are correct and aligned with current offering
- [ ] Security controls address specific concerns for this industry (SWIFT for banking, PDPL for all)
- [ ] Integration options match customer's actual tech stack
- [ ] Migration complexity is honestly represented

### Design QA Checklist
- [ ] Architecture diagrams use consistent iconography (cloud provider icons, standard networking symbols)
- [ ] Data flow arrows show direction clearly
- [ ] Security zone boundaries are color-coded
- [ ] Performance specs in tables, not prose
- [ ] Reference architecture labeled as "Reference" if not custom

### Post-Delivery Checklist
- [ ] Provide technical documentation alongside deck
- [ ] Schedule POC or sandbox environment setup
- [ ] Connect customer's technical team with GreenNode's solutions architect

---

## TYPE 6: Competitive Battlecard Deck
**Purpose:** Arm GreenNode sales team with knowledge to win deals against specific competitors. Internal use.

### Standard Slide Structure (15-20 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Competitive Landscape | 1-3 | Market map, Key competitors overview, Positioning matrix |
| Competitor Deep Dives | 4-12 | Per competitor: Strengths, Weaknesses, GreenNode wins when..., Common objections + responses |
| Win/Loss Analysis | 13-15 | Win patterns, Loss patterns, Deals we should walk away from |
| Handling Objections | 16-18 | Top 10 objections + scripted responses |
| Resources | 19-20 | Supporting materials, Case studies to use, Pricing reference |

### Pre-Production Checklist
- [ ] Research recent competitor announcements and pricing changes
- [ ] Gather win/loss data from CRM
- [ ] Interview recent customers who chose GreenNode over competitors
- [ ] Validate all competitor claims (avoid FUD; use verifiable facts)

### Content QA Checklist
- [ ] All competitor claims are verifiable and dated
- [ ] GreenNode's advantages are backed by real customer evidence
- [ ] Objection responses are honest (don't claim to win on dimensions where competitors are stronger)
- [ ] "When to walk away" section included (intellectual honesty builds trust)

---

## TYPE 7: Investor / Funding Deck
**Purpose:** Raise investment or secure strategic partnership at the corporate/board level.

### Standard Slide Structure (15-20 slides)
| Section | Slides | Content |
|---------|--------|---------|
| Hook | 1-2 | Cover, The Big Opportunity (1-slide market thesis) |
| Problem & Solution | 3-5 | Problem (market size, pain quantified), GreenNode Solution, Unique insight/edge |
| Product & Traction | 6-9 | Product overview, Key metrics (ARR, customers, NRR, NPS), Case studies / logos |
| Market & Competition | 10-12 | Total Addressable Market (TAM/SAM/SOM), Competitive moat, Why GreenNode wins |
| Team | 13-14 | Founding team, Key hires, VNG Group backing |
| Financials & Ask | 15-17 | Revenue model, Financial projections, Funding ask and use of proceeds |

### Pre-Production Checklist
- [ ] Have audited or reviewed financials ready
- [ ] Prepare data room in advance
- [ ] Research investor's portfolio for relevant context
- [ ] Know your unit economics (CAC, LTV, gross margin)

---

## TYPE 8: Partner / Ecosystem Deck
**Purpose:** Recruit technology partners, system integrators, or channel resellers into the GreenNode ecosystem.

### Standard Slide Structure (15-20 slides)
| Section | Slides | Content |
|---------|--------|---------|
| GreenNode Overview | 1-4 | Who GreenNode is, Market opportunity, Products portfolio, Customer base |
| Partner Opportunity | 5-8 | Why partner with GreenNode, Revenue opportunity, Co-sell motions, Joint customer success stories |
| Partner Program | 9-13 | Partner tiers and benefits, Technical enablement, Co-marketing support, Joint go-to-market playbook |
| How It Works | 14-16 | Partner onboarding process, Technical integration, Sales collaboration model |
| Next Steps | 17-18 | Partnership application, Contacts, Q&A |

### Pre-Production Checklist
- [ ] Define partner profile (SI, ISV, reseller, technology partner?)
- [ ] Identify joint customer opportunities
- [ ] Prepare partnership agreement terms (NDA, revenue share, co-marketing budget)
- [ ] Gather examples of existing successful partnerships

### Content QA Checklist
- [ ] Clear WIIFM ("What's in it for me") for partner from slide 5 onwards
- [ ] Revenue opportunity is quantified, not vague
- [ ] Technical integration complexity is honest
- [ ] Existing partner logos shown (social proof)

---

## Handoff to Gamma

**When the slide outline is complete, immediately invoke the `gamma-deck-creator` skill.**

Pass the completed outline as input. Do not wait for the user to ask — the deck creation is the automatic next step.