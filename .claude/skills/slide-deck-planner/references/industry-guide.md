# Industry Customization Guide

## How to use this file
For the target industry, read the relevant section below. Apply the guidance to customize:
1. The messaging angle in each slide section
2. The pain points to emphasize
3. The proof points and customer references to use
4. The industry-specific data to cite
5. The visual and vocabulary choices

---

## INDUSTRY 1: BFSI — Banking, Finance, Securities, Insurance

### Core message
*"In an industry where every second of delay and every data error has real financial and regulatory consequences, GreenNode's precision and compliance-first approach make it the only AI cloud partner built for the demands of Vietnamese financial institutions."*

### Key pain points to address
- 80% unstructured data in banking workflows is manual and error-prone
- Complex regulatory requirements (NHNN Circular 09, Data Law 2024, PDPL 2025, AML compliance)
- Legacy core banking systems are hard to integrate and can't scale
- Document fraud risk (forged financial reports, loan documents, ID tampering)
- Need to process hundreds of millions of documents per year at high accuracy and speed
- Data sovereignty — must stay on-premises or in compliant Vietnamese cloud

### Key product fit
- **IDP:** Document digitization (loan applications, KYC, financial reports, VAT invoices, insurance claims), fraud detection
- **Cloud:** Hybrid/on-premises deployment for compliance, GPU cloud for AI model training, VKS for scalable document processing pipelines
- **Security:** SOC, IAM, vWAF, IDS/IPS, DLP for banking-grade protection

### Messages that resonate for Banking
- "Automate the routine; focus your team on judgment calls"
- "150M documents/year with 1,800 image/second throughput"
- "90%+ reduction in processing time for loan and credit workflows"
- "On-premises deployment to meet NHNN data residency requirements"
- "Human-in-the-loop review keeps compliance teams in control"

### Industry stats to use
- Global IDP market growing rapidly (use recent IDC or Gartner banking automation data)
- Vietnam banking sector's increasing digitization mandates from NHNN
- Average bank processes millions of documents/year manually — cost and error rates
- Digital banking transaction volumes growing >30% YoY in Vietnam

### Recommended case studies
- ACB (public): 150M docs/year, processing time -90%, saves hundreds of billions VND/year
- MSB (public): 300K records to ECM, 1,800 images/second
- VIB (NOT PUBLIC): Digitize credit processing
- TPBank (NOT PUBLIC): Financial report automation for credit assessment
- Insmart/Fuse (insurance): 700K+ files/year, 12 automated processes

### Vocabulary for BFSI
- "compliance-first", "data sovereignty", "SLA guarantee", "audit trail", "risk control"
- "human-in-the-loop", "straight-through processing (STP)", "digital onboarding"
- Vietnamese: "chuyển đổi số ngân hàng", "tự động hóa quy trình tín dụng", "kiểm soát rủi ro"

### Slides to customize
- Pain points: Lead with compliance/regulatory burden and fraud risk
- Architecture: Must show on-premises option prominently
- Case studies: Use banking references only; mark confidential ones "NOT PUBLIC"
- Why Us: Emphasize local expertise, Vietnamese regulatory knowledge, proven bank deployments

---

## INDUSTRY 2: F&B (Food & Beverage / Restaurant Chains)

### Core message
*"For F&B chains managing thousands of SKUs, hundreds of store locations, and massive invoice volumes, GreenNode IDP automates the paperwork so operations teams can focus on customer experience and margin."*

### Key pain points to address
- Manual invoice reconciliation across hundreds of stores takes enormous time
- Promotion fraud (fake invoices submitted for cashback/points programs)
- Supply chain document management (purchase orders, delivery receipts, customs docs)
- Inventory management needs real-time data from scattered POS and warehouse systems
- Seasonal peaks require rapid infrastructure scaling

### Key product fit
- **IDP:** Invoice OCR for promotion verification, purchase order processing, delivery receipt automation
- **Cloud:** Scalable infrastructure for POS systems, e-commerce platforms, delivery apps
- **Shelf Scoring:** AI shelf compliance for retail F&B distribution (TH True Milk case model)

### Reference cases
- Adtima (enterprise/advertising platform serving F&B chains like Nestlé, Aptamil): 350+ stores, invoice processing for promotions, fraud detection

### Industry stats to use
- Vietnam F&B market growth rate (use recent government statistics or industry reports)
- Cost of manual invoice processing per store per day
- Fraud rate in promotional campaigns without automated verification

### Vocabulary for F&B
- "promotion integrity", "supply chain visibility", "store compliance", "SKU management"
- "real-time inventory", "multi-location management", "franchise operations"

---

## INDUSTRY 3: Retail (Modern Trade / Chain Stores)

### Core message
*"GreenNode is ready for scale with cloud infrastructure built to support real retail growth — from 1 store to 1,000+, from pilot to national rollout."*

### Key pain points to address
- Infrastructure can't scale with store expansion
- Customer data fragmented across GRMS, GPMS, Materials, VAT, POS systems
- Website/e-commerce overloaded during peak seasons (Tet, 9/9, 11/11, Black Friday)
- Lack of real-time store monitoring and centralized camera management
- Manual shelf inspection can't cover thousands of SKUs across hundreds of stores
- Disrupted customer experience from slow systems
- High infrastructure costs and security/compliance requirements

### Key product fit
- **Cloud:** CDN + Auto Scaling for peak traffic, PAYG (30% cost optimization), VKS for microservices
- **IDP:** Invoice processing, data validation, shelf scoring, warehouse document automation
- **VMS:** Centralized camera management for >1,000 stores nationwide
- **AI Stack:** Behavioral analysis, demand forecasting, customer analytics

### Specific solutions for Retail
- **Shelf Scoring:** >98% accuracy, <1.5 seconds — used for compliance across store networks
- **Centralized VMS:** Manage security cameras for all stores from one portal
- **Peak Season Scaling:** Auto-scaling to handle 10x traffic during promotional events
- **Data Platform:** Consolidate POS, inventory, customer data into unified data lake

### Industry stats to use
- 73% of AI-empowered retail C-level executives use AI to access new customers and scale faster (PwC)
- Retail AI market growing rapidly
- Cost of downtime during peak season (convert to VND revenue lost per hour)
- Number of display shelves a merchandiser must evaluate in one day (GreenNode uses: "thousands per day")

### Vocabulary for Retail
- "omnichannel", "unified commerce", "shelf compliance", "category management"
- "peak season readiness", "store network", "PAYG cloud", "VMS surveillance"
- Vietnamese: "chuỗi bán lẻ", "quản lý cửa hàng", "trải nghiệm khách hàng", "mùa cao điểm"

### Recommended case studies
- Shelf scoring deployments (TH True Juice example in IDP deck)
- Adtima: 350+ store operations

---

## INDUSTRY 4: E-Commerce

### Core message
*"Milliseconds matter in e-commerce. GreenNode's CDN and elastic infrastructure give you the speed, uptime, and AI capabilities to win during the moments that count most."*

### Key pain points to address
- Traffic spikes during flash sales (10x-100x normal load) crash platforms
- Fraud in promotional redemptions, fake reviews, account abuse
- Recommendation engine and personalization require massive compute
- Real-time inventory sync across warehouses and fulfillment centers
- Customer data compliance (PDPL 2025) with overseas data transfer restrictions
- Cost of cloud infrastructure is unpredictable and often wasteful

### Key product fit
- **Cloud:** CDN, Auto Scaling, VKS for containerized e-commerce platforms
- **IDP:** Invoice reconciliation, return/refund document processing
- **AI Stack:** Recommendation engines, fraud detection, demand forecasting, search optimization

### Industry stats to use
- Vietnam e-commerce market growth rate (VECOM or Google-Temasek report)
- Cost of 1 hour downtime during peak sales event (estimate in $ or VND)
- % of e-commerce companies reporting fraud-related losses

### Vocabulary for E-commerce
- "uptime SLA", "flash sale readiness", "CDN edge caching", "container auto-scaling"
- "recommendation engine", "real-time fraud detection", "checkout optimization"
- Vietnamese: "sàn thương mại điện tử", "bảo đảm uptime", "chống gian lận"

---

## INDUSTRY 5: Logistics (Supply Chain / 3PL / Transport)

### Core message
*"GreenNode provides high-performance, flexible Cloud infrastructure designed for the speed, continuity, and intense pressure of logistics operations."*

### Key pain points to address
- Fragmented infrastructure across multiple warehouses, transport routes, partners
- Real-time processing and low latency required for tracking, route optimization, demand forecasting
- Seasonal scalability to handle peak order volumes (Tet, holiday seasons, promotions)
- Lack of suitable AI/GPU infrastructure, high costs for AI training and inference
- Difficult integration with legacy OMS, TMS, WMS systems
- High operating costs, shortage of DevOps/MLOps/AI talent
- Complex security/compliance requirements (Data Law 2024, PDPL 2025)
- Fragmented data across WMS, TMS, ERP, IoT, GPS systems

### Key product fit
- **Cloud:** GPU Cloud for AI/ML, flexible hybrid migration, PAYG 40% cost reduction
- **Network:** vStorage + API Gateway for OMS/TMS/WMS synchronization, CDN for tracking apps
- **IDP:** Warehouse document processing (receiving/shipping slips, delivery receipts, invoices, purchase orders)
- **VMS:** Centralized camera management for warehouses and storage facilities
- **AI Stack:** Demand forecasting, route optimization, ETA prediction, fraud detection, computer vision for warehouses

### Logistics tech stack (from GreenNode's reference deck)
Full stack for a leading logistics enterprise on GreenNode:
- **Data Analytics Layer:** Data Lake (GPS, IoT, WMS/TMS/OMS), ODP standardization, AI/ML services (demand forecasting, route optimization, ETA prediction, fraud detection, computer vision), BI dashboards (OTIF, cost per km, inventory)
- **Integration:** API Gateway, IoT/Fleet management (GPS, RFID, camera, sensors), 3PL connectors (carriers, customs, payment, insurance)
- **Service Quality:** Customer portal, Shipper/driver app, SLA management, Feedback analytics
- **Core Business:** OMS, TMS, WMS, Fleet management, Billing/settlement, Supply chain inventory
- **Infrastructure:** GPU Cloud, CDN, Security gateway (IAM, MFA, RBAC), IDS/IPS, DLP, 24/7 monitoring

### Industry stats to use
- 70% of large organizations will adopt AI-based supply chain forecasting by 2030 (Gartner)
- Cloud Logistics Global Market: $19.26B (2024) → $32.45B (2029) at 10.9% CAGR
- AI in Logistics Market: $17.96B (2024) → $707.75B (2034) at 25.9% CAGR (GMI/Precedence Research)
- 80% of large logistics companies investing in AI and IoT (Deloitte)
- 40% reduction in IT operating costs when logistics companies migrate to cloud

### Vocabulary for Logistics
- "SLA adherence", "OTIF (On Time In Full)", "last-mile delivery", "peak season capacity"
- "route optimization", "ETA prediction", "demand forecasting", "fleet tracking"
- "WMS/TMS/OMS integration", "3PL", "supply chain visibility"
- Vietnamese: "tối ưu vận chuyển", "quản lý kho", "dự báo nhu cầu", "SLA đảm bảo"

---

## INDUSTRY 6: Gaming

### Core message
*"For gaming companies, infrastructure is competitive advantage. GreenNode's GPU Cloud and AI Stack give game studios the performance, scale, and AI tools to build the next generation of player experiences."*

### Key pain points to address
- Launch spikes: day-1 traffic can be 100x normal load, crashes = revenue loss and reputation damage
- AI-powered game features (NPC intelligence, matchmaking, anti-cheat, recommendation) require massive GPU compute
- Player data analytics requires low-latency pipelines and large-scale compute
- Global player base with low-latency requirements across regions
- Security: DDoS attacks on game servers, account hacking, in-game fraud
- Cost unpredictability: game traffic is highly seasonal (game launches, updates, events)

### Key product fit
- **GPU Cloud:** Training AI models for NPCs, running real-time inference for game AI features
- **Cloud Compute:** Elastic game server scaling for launch peaks and live events
- **Network/CDN:** Low-latency delivery for global players, DDoS protection
- **AI Stack:** Player behavior analytics, matchmaking optimization, anti-cheat detection, recommendation systems
- **Security:** IAM, Anti-DDoS, 24/7 monitoring, vWAF for game servers

### Industry stats to use (from GreenNode's gaming industry deck)
- Vietnam gaming market growth rate
- Mobile gaming revenue projections for Southeast Asia
- % of game studios planning AI integration (cite industry research)
- GPU compute demand growth for AI in gaming

### Vocabulary for Gaming
- "live operations (LiveOps)", "game economy", "anti-cheat", "matchmaking"
- "server tick rate", "real-time inference", "GPU burst capacity", "DDoS protection"
- "player LTV", "retention analytics", "game launch readiness"
- Vietnamese: "game server", "hạ tầng game", "bảo vệ DDoS", "AI trong game"

---

## INDUSTRY 7: Professional Services (Consulting, Law, BPO, Audit)

### Core message
*"For professional services firms, document intelligence is a competitive moat. GreenNode IDP turns the massive volume of contracts, filings, and reports from a burden into a searchable, structured asset."*

### Key pain points to address
- Massive volumes of contracts, legal documents, financial reports processed manually
- Knowledge scattered in unstructured formats (PDFs, scanned documents, handwritten notes)
- Billing and compliance depend on accurate document extraction
- Client confidentiality and data security are paramount
- Global workforce with varying document types and languages

### Key product fit
- **IDP:** Contract analysis, financial statement extraction, document classification, audit document processing
- **Cloud:** Secure private cloud with strict access controls, VPN connectivity for distributed teams
- **AI Stack:** Document search and retrieval, automated summarization, classification

### Reference cases
- 247BPO: Tour booking/travel documents, CCCD/passport OCR, automate client list preparation

---

## INDUSTRY 8: Education / EdTech

### Core message
*"GreenNode's AI cloud helps educational institutions modernize their operations — from automated document processing to scalable learning platforms that serve thousands of students simultaneously."*

### Key pain points to address
- Manual processing of student records, transcripts, enrollment documents
- Exam proctoring and academic integrity document verification
- Scalable learning management systems that spike during enrollment and exam periods
- Limited IT budgets requiring cost-efficient cloud solutions

### Key product fit
- **IDP:** Student document processing (transcripts, certificates, ID verification), scholarship document automation
- **Cloud:** Scalable LMS hosting, GPU cloud for AI-powered personalized learning
- **AI Stack:** Student performance analytics, recommendation systems for learning paths

---

## Cross-Industry Customization Rules

### For all industries with document-heavy operations (BFSI, Logistics, Retail, F&B)
Always include in the deck:
- IDP capabilities section with relevant document types for that industry
- Fraud detection capability (document fraud is universal)
- PAYG cost savings model

### For all industries with AI/ML ambitions (Gaming, E-commerce, Logistics)
Always include:
- GPU Cloud specifications
- AI Stack services overview
- Reference architecture for their AI use case

### For all regulated industries (Banking, Insurance, Healthcare if applicable)
Always include:
- Compliance slide (Vietnam Data Law 2024, PDPL 2025, sector-specific regulations)
- On-premises deployment option
- Data residency and sovereignty statement
- VNG Group credibility as local, trusted partner

### Industry deck format comparison
| Industry | Primary Product | Lead Angle | Key Metric to Lead With |
|----------|----------------|-----------|-------------------------|
| Banking | IDP | Compliance + Speed | 1,800 img/sec, 90% time reduction |
| Insurance | IDP | Accuracy + Scale | 99% accuracy, 700K+ files/year |
| Gaming | Cloud/GPU | Performance + Scale | GPU specs, uptime SLA, DDoS protection |
| Logistics | Cloud | Operational efficiency | 40% cost reduction, PAYG, AI forecasting |
| Retail | Cloud + IDP | Scale + Store management | >1,000 stores VMS, shelf scoring 98% |
| E-commerce | Cloud | Uptime + Peak handling | CDN performance, auto-scaling SLA |
| F&B | IDP | Invoice automation | 350+ stores, fraud detection |
| Enterprise | IDP + Cloud | Automation + Integration | API integration speed, OCR accuracy |