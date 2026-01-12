# Azure Confluent Kafka Platform Assessment

## 1. Executive Summary
- Scope: Azure-hosted Confluent Cloud Kafka platform
- Current state: large, significantly underutilised platform under a long-term commercial commitment
- Monthly Confluent cost: ~£12,000 (clusters + support)
- Remaining committed spend: ~£708,650 over 28 months (term: May 2025 – May 2028)
- Adoption and throughput are extremely low relative to provisioned capacity
- No Disaster Recovery (DR) capability currently enabled
- No clearly articulated strategic role for the Azure Confluent platform
- This assessment summarises key findings, financial realities, and decision options

---

## 2. Current State Overview

### 2.1 Platform & Deployment Model
- Confluent **Cloud** deployed on Azure
- Dedicated clusters (2 CKUs)
- Multi-region deployment across UK South (UKS) and UK West (UKW)
- Multi-zone availability in UKS
- DR capability previously existed in UKW but was disabled for cost reasons
- Two environments: Non-Production and Production (separate VDCs)

### 2.2 Cost & Commercials
- Total contract value: ~£806,198
- Annual committed amount: ~£97,635
- Commitment discount: ~10%
- Time elapsed: 8 of 36 months
- Remaining commitment: ~£708,650 over 28 months
- Effective monthly Confluent spend:
  - Clusters (2 CKUs, 2 clusters): ~£11,000
  - Confluent support: ~£1,120
  - Total: ~£12,000 per month
- Additional Azure costs exist for supporting infrastructure (networking, security, observability, platform services)

### 2.3 Usage & Adoption
- Limited number of active workloads
- Current use cases:
  - X
  - Y
- Potential / pipeline use cases:
  - A
  - B
- Kafka is primarily used as an event transport rather than a full streaming platform

### 2.4 Supported Patterns
- Event-based Pub/Sub
- Limited adoption of advanced Kafka patterns:
  - No CDC
  - No stream processing
  - Minimal schema-driven contracts

---

## 3. Architecture Snapshot

### 3.1 Networking
- Azure hub-and-spoke networking model
- Confluent Cloud deployed into a dedicated Azure VDC
- Connectivity via Azure Private Link (3 endpoints)
- Producers and consumers run primarily on:
  - AKS (Azure)
  - EKS (AWS)
- Cross-cloud connectivity from AWS to Azure is already established
- No on-prem connectivity (except limited lower-environment developer access)
- Ingress pattern: native Kafka only (HTTPS / REST proxy not currently enabled)

### 3.2 Client & Workload Types
- Microservices-based producers and consumers
- Containerised workloads only
- Azure services involved:
  - AKS (primary)
  - Possible limited Azure Functions usage (unconfirmed)

### 3.3 Data Characteristics
- Message size: small
- Throughput: low and steady
- Topics: ~25 in production
- Retention: typically ~1 week
- No known ordering or exactly-once processing requirements

---

## 4. Business Context & Signals

### 4.1 Business Criticality
- No confirmed customer-facing or regulatory workloads
- Kafka is not currently on a known critical business path (e.g. payments, customer journeys)
- DR capability was previously removed without identified business impact
- Platform importance appears operational rather than business-critical

### 4.2 Growth Outlook
- No committed or forecasted growth in Kafka usage over the next 12–18 months
- New use cases are opportunistic rather than strategic
- No evidence of demand that would materially change utilisation profile

### 4.3 Contract Flexibility (Current Understanding)
- Confluent Cloud commitment is assumed to be fixed for the remaining term
- Ability to reduce CKUs or downgrade non-production independently is currently unclear
- Even if CKUs are reduced, the committed spend remains payable

---

## 5. Key Findings

### 5.1 Capacity & Utilisation
- Cluster type: Dedicated (2 CKUs)
- Available partitions: ~9,000 | Used: ~55
- Available throughput: ~30,000 req/s | Used: ~125 req/s
- Available client connections: ~36,000 | Used: ~200
- Total topics: ~25
- Overall utilisation represents a very small fraction of provisioned capacity

### 5.2 Cost Reality
- Fixed Confluent commitment dominates cost profile
- Supporting Azure infrastructure costs are incremental but secondary
- Retention or minor tuning changes will not materially reduce spend
- Underutilisation is structural, not a configuration issue

### 5.3 Operating Model
- Onboarding and access management are fully manual:
  - Topic creation
  - Service account creation
  - API key generation
  - ACL assignment
- Access is centrally governed but operationally heavy
- Kafka expertise is concentrated in a small number of engineers
- Platform is perceived as “working” but not strategically leveraged

### 5.4 Resilience & Reliability
- No DR or failover capability currently enabled
- No defined SLAs or SLOs
- No backup or topic replication strategy
- Resilience posture does not align with platform scale or cost

### 5.5 Strategic Positioning
- Azure Confluent has no clearly defined role within the organisation
- Kafka is treated as basic messaging infrastructure
- Leadership focus is primarily on cost and direction rather than capability

---

## 6. Strategic Recommendations (Decision Options)

> The following options are mutually exclusive and require an explicit leadership decision.

- **Option A:** Consolidate Confluent platforms (Azure and AWS)
- **Option B:** Position Azure Confluent as a secondary / DR platform, with AWS Confluent as primary
- **Option C:** Right-size Azure Confluent to better match current and near-term demand
- **Option D:** Invest in Azure Confluent to drive Azure-native use cases and broader adoption
- **Option E:** Evaluate managed Kafka on AKS as an alternative, acknowledging increased operational ownership and risk

---

## 7. Financial Reality (Important Context)
- ~£708,650 of committed spend remains regardless of utilisation
- Right-sizing CKUs may reduce operational footprint but does not eliminate committed cost
- Any technical changes must be aligned with a clear strategic role to avoid continued inefficiency
- This is primarily a **strategic and financial decision**, not a tuning exercise

---

## 8. Conditional Improvement Areas
> Applicable only if Options C or D are selected

### 8.1 Onboarding & Automation
- Automate topic, service account, API key, and ACL provisioning
- Introduce self-service onboarding for application teams
- Extend existing Terraform CI/CD with validation and testing

### 8.2 Observability
- Centralised monitoring and alerting
- Cost and utilisation dashboards
- Producer/consumer lag and throughput visibility

### 8.3 Connectivity & Integration
- Support additional ingress patterns (e.g. HTTPS / REST proxy)
- Evaluate connector usage carefully due to cost and operational overhead
- Planned integrations (e.g. MongoDB) should align with platform strategy

### 8.4 Resilience
- Revisit DR requirements based on agreed platform role
- Align resilience investment with business criticality

---

## 9. Roadmap (Indicative)

### Short Term (0–3 months)
- Publish clear utilisation, cost, and architecture metrics
- Automate core onboarding workflows
- Support immediate use cases where justified
- Evaluate strategic options and agree a preferred direction

### Medium Term (3–9 months)
- Implement the agreed strategic option
- Deliver required changes (right-sizing, DR, integrations)
- Improve documentation, enablement, and operational maturity
