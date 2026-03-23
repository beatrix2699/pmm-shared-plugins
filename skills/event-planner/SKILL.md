---
name: event-planner
description: Use when planning, structuring, or running any B2B tech event for GreenNode or the VNG ecosystem. Triggers on "event plan," "workshop," "sự kiện," "contest plan," "event rundown," "staff assignment," "lên kế hoạch sự kiện," or any request to organize or produce planning materials for an industry workshop, internal product demo, or community writing contest.
---

# Event Planner Skill

---

## Step 1 — Identify Event Type

Classify the event into one of three types before doing anything else:

| Type | Trigger keywords | Examples from source |
|------|-----------------|----------------------|
| **Industry Workshop** | BFSI, fintech, sector, panel, media, keynote, hotel venue | BFSI South Workshop, BFSI Securities Workshop |
| **Internal Product Workshop** | demo, internal, nội bộ, trial, feedback, product launch | vDB PostgreSQL Cluster Internal Workshop |
| **Community Contest / Campaign** | contest, writing, GitHub, community, submission, voting | CNCF Vietnam Writing Contest 2026 |

Ask if unclear.

---

## Step 2 — Populate the Master File

Every event needs a master file. Output a structured document with these sections:

### 2A. Event Header

```
TÊN SỰ KIỆN      : [Full event name]
ĐƠN VỊ TỔ CHỨC   : [Organizer(s)]
THỜI GIAN         : [Date, time range]
ĐỊA ĐIỂM          : [Venue name, room, floor, address] OR [Online platform]
SỐ LƯỢNG          : [Expected attendees + staff breakdown]
MỤC ĐÍCH CHÍNH    : [1–2 sentences: why this event exists]
NHÓM SẢN PHẨM     : [Products / solutions being featured]
ĐỐI TƯỢNG         : [Target audience — job titles, companies, sectors]
```

### 2B. Agenda / Event Rundown

Build a time-blocked agenda table:

| Thời gian | Nội dung chính | Diễn giả / Người phụ trách |
|-----------|---------------|---------------------------|

Rules:
- Registration/welcome buffer: 30 min before official start
- Opening remarks: 10 min per organization (max 2 orgs)
- Keynote / demo sessions: 20–30 min each
- Panel discussions: 30–40 min (list all panelists + moderator)
- Tea break: 15–20 min between major blocks
- Q&A / feedback session: 30–40 min (internal workshops) or integrated into panels
- Closing + networking / lunch: 30–60 min

For **Internal Workshops**, add a PRD Feedback column to each agenda item.

### 2C. Content Angles (Internal / Product Workshops)

For each product feature being showcased, document:

```
FEATURE NAME
- Demo: [What is live-demoed]
- Use Case: [Specific internal team scenario]
- PRD Feedback: [What feedback to collect]
```

Use the vDB workshop as the template:
- High-Traffic Read/Write
- Zero-Downtime Failover
- Data Protection & Backup
- Migration path
- Cost & Promotion
- Coming Soon / Roadmap

### 2D. Goals & Success Metrics

| Mục tiêu | Chi tiết | Đo lường |
|----------|----------|----------|

Minimum 4 goals. Always include:
- Attendance / sign-up target (numeric)
- Content / feedback output (what gets produced)
- Follow-up deliverable with deadline

### 2E. Timeline / Phases (Contests & Campaigns)

| Giai đoạn | Thời gian | Action chính |
|-----------|-----------|-------------|

Phases: Preparation → Launch & Comms → Submission & Review → Judging & Announcement

---

## Step 3 — Staff Assignment Plan

Output a staff table for day-of execution:

| Nhân sự (username/name) | Vị trí đứng | Nhiệm vụ chính |
|------------------------|-------------|----------------|

### Standard role map (Industry Workshop)

| Role | Responsibilities |
|------|-----------------|
| **MC lead (MKT)** | MC duties, speaker liaison, event timeline keeper. Station: near stage / AV area. Must know all speaker names and faces. Carry FAQ answers (WiFi, materials, contacts). Attire: suits or branded GreenNode wear + formal pants. No phone visible, full attention. |
| **Media / Speaker handler** | Station: near media table by entrance. Escort speakers, coordinate media requests. Push non-media questions to MC lead. |
| **Check-in AM (×2)** | Station: registration table by entrance. Check in guests, verify lunch list, remind parking sticker. Compile Excel check-in and send before 10 PM for lunch count. Hand out badges and door gifts (after tea break / at end). |
| **Photography** | Follow camera operator; capture all key moments (opening, panels, networking). |
| **Testimonial video** | Capture testimonial angles during networking / lunch. |
| **Broadcast / TV liaison** | Take care of HTV or broadcast crew exclusively. Escalate all other questions to designated handler. |
| **BD / Networking** | Circulate among AMs and customers. Primary goal: identify ICP pain points. |
| **Hosting AMs** | Greet and escort guests at both lobby (ground floor) and event floor. |

### FAQ for all front-line staff

- Are event materials being sent? → Yes / via email post-event
- Where is [room / facility]? → [pre-fill venue layout]
- What is the WiFi? → [pre-fill]
- Who should I connect with? → [list key internal contacts]
- Water allocation: 1 bottle per registered guest already in room; new guests → contact Trinh/Vân for allocation increase

---

## Step 4 — Communication & Promotion Plan

### Industry Workshop

| Channel | Content | Timing |
|---------|---------|--------|
| Email invitations | Speaker lineup, agenda, venue | T−21 days |
| Reminder email | Logistics, parking, WiFi, agenda | T−3 days |
| Social posts | Speaker spotlights, topic teasers | T−14 to T−1 |
| Post-event | Thank you + materials | T+1 day |
| Media / press | Press release + photo gallery | T+2 days |

### Internal Workshop

| Channel | Content | Timing |
|---------|---------|--------|
| Internal announcement | Goals, promotion details, agenda | T−14 days |
| Reminder (Slack / email) | Join link, agenda, promotion slots | T−3 days |
| Post-workshop | Recording link, trial signup link, FAQ | T+1 day |
| Battle card & FAQ | For Sales/AM use when pitching external customers | T+3 days |
| Video clips | Shorts from demo + FAQ snippets | T+7 days |

### Community Contest

| Channel | Timing |
|---------|--------|
| CNCF Vietnam Page/Group | Launch day + weekly reminders |
| Cloud Native HCMC + Hanoi chapters | Launch day |
| DevOps VN / DevOps Vietnam groups | Launch + week 2 |
| Website / Hub | Always-on contest page |
| Weekly content support post | Every week during submission window |
| Featured articles (approved entries) | Rolling publish during review window |
| Winner announcement | Deadline + 2 days |

---

## Step 5 — Promotion / Incentive Block (if applicable)

When the event includes a promotional offer, document:

```
CHƯƠNG TRÌNH KHUYẾN MÃI
- Offer: [What is free / discounted]
- Value: [VND amount or % off]
- Slots: [Limited number — create urgency]
- Eligibility: [Who qualifies — internal first, then external]
- Registration: [How to sign up]
- Deadline: [Date]
```

**Internal workshop example:**
- Free 3-month trial (value: 18M VND): 4 vCPU / 8GB RAM / 100GB NVMe / 3-node HA
- 30 slots — internal teams get priority
- Free migration + HA setup included

---

## Step 6 — Contest / Submission Rules Block

For writing contests or community campaigns:

```
THỂ LỆ THAM DỰ
- Hình thức nộp bài : [GitHub PR / Google Form / Email]
- Chủ đề           : [Topic scope + priority subtopics]
- Ngôn ngữ         : [Vietnamese / English / Both]
- Độ dài           : [Word count range]
- Template         : [Link to template]
- Số bài/người     : [Max submissions per person]
- Quy trình duyệt  : [Review SLA — e.g., 3–5 business days]
- Giải thưởng      : [Prize tiers with values]
- Mục tiêu         : [Submit target | Featured target | Top prize count]
```

**Article template structure (Cloud Native / Tech case study):**
1. Bối cảnh & Vấn đề (Context) — 150–200 words
2. Giải pháp lựa chọn (Solution) — 300–400 words, include architecture diagram
3. Triển khai thực tế (Implementation) — 300–400 words, include code snippets
4. Kết quả & Bài học (Results & Lessons Learned) — 200–300 words with metrics
5. Kết luận & Tài nguyên (Conclusion) — summary + links

Total: 1,000–1,500 words. Tags: #kubernetes #cicd #cloudnative #vietnam etc.

---

## Output Format Rules

- Always output in Vietnamese unless the user asks for English
- Use the same bilingual column headers style from source files (e.g., `Thời gian | Nội dung chính | Diễn giả`)
- Times use 24h format: `09:00 – 09:30`
- Duration shown as decimal hours is NOT acceptable — always convert to clock times
- Speaker names include full title and organization: `Ông Nguyễn Văn A – Giám đốc, Công ty B`
- Venue: always include room name, floor, full hotel address

---

## Quick Reference — Event Types at a Glance

### Industry Workshop (BFSI-style)
- Venue: 4–5 star hotel ballroom
- Attendees: 60–100 guests + 10 media + 10 AM
- Format: Opening → Keynotes → Panel 1 → Tea Break → Keynotes → Panel 2 → Closing → Lunch
- Duration: 4–5 hours (morning block) + lunch
- Key outputs: Guest list Excel (updated by 10 PM day-of), badge + door gifts, media coverage

### Internal Product Workshop
- Venue: Company meeting room or Google Meet
- Attendees: Internal teams (target 3+ team sign-ups)
- Format: Opening → Live Demo → Deep Dive → Break → Promotion Announcement → Q&A → Wrap-up
- Duration: 2.5 hours
- Key outputs: Feedback summary, battle card, FAQ, recording clips, trial sign-up list

### Community Contest / Campaign
- Platform: GitHub + social channels
- Duration: 6–8 weeks
- Format: Preparation → Launch → Submission window (rolling review) → Judging → Announcement
- Key outputs: Featured articles, winner announcement, content repurposed for blog/social
