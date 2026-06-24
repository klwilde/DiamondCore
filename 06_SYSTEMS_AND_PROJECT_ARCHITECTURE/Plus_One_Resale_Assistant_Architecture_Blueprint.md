# Plus One AI Resale Assistant Architecture Blueprint

This document defines the source-of-truth system architecture, module boundaries, data contracts, and feedback-loop specifications for the **Plus One / Haus da Villa Wilde** AI Fashion Resale Assistant. It is designed to guide engineering implementation of the Lean MVP (Sprint 1) while establishing the core data schema to bootstrap future continuous model refinement.

---

## Context Diagram

The following diagram represents the system context and user journey flow, spanning from capture to multi-marketplace publishing and the closed feedback loop:

```mermaid
graph TD
    classDef client fill:#1f2937,stroke:#3b82f6,stroke-width:2px,color:#fff;
    classDef backend fill:#1f2937,stroke:#a855f7,stroke-width:2px,color:#fff;
    classDef external fill:#111827,stroke:#10b981,stroke-dasharray: 5 5,color:#9ca3af;
    classDef database fill:#111827,stroke:#eab308,stroke-width:2px,color:#e5e7eb;

    User([Reseller / Seller]) -->|1. Batch Upload/Photos| Wizard[Plus One Wizard Mobile UI]:::client
    Wizard -->|2. Local Ingestion| CVEngine[CV Diagnostic Engine]:::client
    
    subgraph "Local Offline Sandbox"
        Wizard <-->|Store Offline Action Queue| OfflineQueue[(Local DB / IndexedDB)]:::database
        CVEngine -->|Symmetry & Focus Metrics| Wizard
    end

    Wizard -->|3. Sync (Online)| CloudBackend[Plus One Backend Engine]:::backend
    
    subgraph "Core Cloud Services"
        CloudBackend -->|Query Model| VisionLLM[Vision & NLP Pipeline]:::backend
        CloudBackend -->|Store Listing & Sync Logs| PrimaryDB[(Ecosystem Database)]:::database
        CloudBackend -->|Write Event| FeedbackTable[(Feedback Table)]:::database
    end

    CloudBackend -->|4. Push Listings| eBayAPI[eBay Listing API]:::external
    CloudBackend -->|5. Push Listings| DepopStub[Depop Listing Daemon]:::external

    eBayAPI -->|6. Sale Event Webhook| CloudBackend
    DepopStub -->|7. Sale Status Query| CloudBackend
    
    CloudBackend -->|8. Log Sale + Original vs. Edit Diff| FeedbackTable
    FeedbackTable -->|9. Feed Training Pipeline| FineTuning[Model Fine-Tuning Daemon]:::backend
    FineTuning -.->|Optimize Weights| VisionLLM
```

---

## 1. Module Breakdown

The application is structured into five isolated modules to allow independent development, testing, and deployment:

### 1.1 Ingestion & Capture Module (Client-Side Mobile-First)
*   **Purpose**: Handle batch photo capture with real-time feedback and offline support.
*   **Key Services**:
    *   `CameraCaptureController`: Integrates with `navigator.mediaDevices.getUserMedia` for live camera access. Overlays grid reticles and dynamic framing bounding-boxes tailored to the photo sequence (Front $\rightarrow$ Back $\rightarrow$ Tag $\rightarrow$ Detail).
    *   `FileFallbackManager`: Fallback for local photo picking when webcam/native camera is blocked or when operating offline.
    *   `LightweightCVScanner`: Executed client-side using Canvas2D API to check image exposure (average luminance), contrast, and blur metrics (Laplacian variance approximation) before accepting the photo.
    *   `OfflineQueueManager`: Interfaces with browser-based `localStorage` / `IndexedDB` to capture listings, edit logs, and queue them for server sync when a network signal is recovered.

### 1.2 Generation & Intelligence Module (Backend/Cloud API)
*   **Purpose**: Orchestrate vision models, extract text signals, and synthesize copy templates.
*   **Key Services**:
    *   `VisionIngestPipeline`: Accepts the 4-photo payload. Submits collar-tag photos to an OCR model (extracting size and brand text) and overall garment photos to a custom clothing classifier (bootstrapped with DeepFashion/ModaNet data for silhouette/category classification).
    *   `DescriptionGenerator`: Integrates with a Large Language Model (e.g., Gemini Flash) with system instructions tailored to write high-converting listing drafts matching target marketplace aesthetics.
    *   `PriceCalculator`: Evaluates cold-start price recommendations using historically scraped sold-listings (90-day rolling window) adjusted for brand value, condition index, and fee recovery.

### 1.3 Sync & Publishing Module (Integrations)
*   **Purpose**: Secure store authentication and automated listing delivery.
*   **Key Services**:
    *   `OAuthBroker`: Coordinates eBay Developer App Credentials, handles token generation, state validation, refresh cycles, and secure cookie storage.
    *   `PublishingDaemon`: A transactional execution controller. Sequentially coordinates:
        1. Media upload to eBay Picture Services (EPS) or Depop CDN.
        2. Category taxonomy resolution.
        3. SKU inventory item creation.
        4. Listing offer compilation and live activation.
    *   `IntegrationStubs`: Interface wrappers for Poshmark, Mercari, and Vinted, generating clipboard-copy blocks for Sprint 1 (evolving to full API push in later sprints).

### 1.4 Price & Stock Synchronization Daemon (Background Service)
*   **Purpose**: Prevent double-selling and maintain unified inventory counts.
*   **Key Services**:
    *   `InventorySyncCoordinator`: Subscribes to platform hooks or polls listings. When a sale occurs on eBay, it triggers an auto-delisting payload to Depop (and vice versa).
    *   `PriceUpdater`: Syncs modified retail pricing across all connected platforms in real time if the seller updates parameters inside the Plus One dashboard.

### 1.5 Feedback & Learning Module (Continuous Optimization)
*   **Purpose**: Store and structure human-in-the-loop edits to drive continuous fine-tuning.
*   **Key Services**:
    *   `DeltaDiffLogger`: Calculates the difference between the AI-generated initial values (title, description, price) and the user's customized final listing values before they click publish.
    *   `SaleWebhookReceiver`: Collects sell-through events, sold prices, and sale duration metrics from marketplace APIs.
    *   `FeedbackExporter`: Standardizes the data chain (AI Gen $\rightarrow$ User Edit $\rightarrow$ Sale Outcome) into training-ready JSON datasets for automated offline model fine-tuning.

---

## 2. Lean MVP Scope (Sprint 1)

Following the prioritized strategy, Sprint 1 focuses exclusively on shipping core workflows. Non-essential automation will be managed via stubs or high-fidelity UI representations.

| Feature Area | Must-Have (Sprint 1) | Can Wait (Sprint 2+) |
| :--- | :--- | :--- |
| **Capture** | Camera stream, file fallback, batch thumbnail queue, local exposure feedback. | Studio-style background removal, AI image upscaling, shadow correction. |
| **Generation** | OCR-based size detection, brand classifier, marketplace description templates. | Fabric weave analysis, Pantone color extraction, automated catalog match. |
| **Publishing** | Real eBay OAuth auth flow, automated inventory push to eBay, Depop clipboard stub. | Full programmatic Poshmark, Mercari, and Vinted API integrations. |
| **Inventory Sync** | Live price & quantity updates on eBay via dashboard. | Multi-market automated bundling, cross-platform stock auto-deduction. |
| **Learning** | Ingestion of edits and sale webhooks to a dedicated `feedback` table. | Reinforcement-learning pricing bots, automated keyword tuning engines. |

---

## 3. Data Contracts

To ensure modularity and reliable communication between the client, backend, and external APIs, we establish the following structured data contracts:

### 3.1 Ingested Garment Payload (`IngestedGarment`)
This object represents the raw visual inputs collected by the frontend and analyzed by client-side diagnostics.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "IngestedGarment",
  "type": "object",
  "properties": {
    "garment_id": { "type": "string", "format": "uuid" },
    "timestamp": { "type": "string", "format": "date-time" },
    "device_info": {
      "type": "object",
      "properties": {
        "platform": { "type": "string" },
        "is_mobile": { "type": "boolean" }
      },
      "required": ["platform", "is_mobile"]
    },
    "images": {
      "type": "array",
      "minItems": 4,
      "maxItems": 10,
      "items": {
        "type": "object",
        "properties": {
          "photo_type": { "type": "string", "enum": ["front", "back", "tag", "detail"] },
          "data_url": { "type": "string", "pattern": "^data:image/(jpeg|png);base64," },
          "diagnostics": {
            "type": "object",
            "properties": {
              "exposure_score": { "type": "number", "minimum": 0, "maximum": 100 },
              "focus_score": { "type": "number", "minimum": 0, "maximum": 100 },
              "laplacian_variance": { "type": "number" }
            },
            "required": ["exposure_score", "focus_score"]
          }
        },
        "required": ["photo_type", "data_url", "diagnostics"]
      }
    }
  },
  "required": ["garment_id", "timestamp", "device_info", "images"]
}
```

### 3.2 Marketplace Listing Schema (`MarketplaceListing`)
The structured representation of generated listing assets tailored for specific platforms.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "MarketplaceListing",
  "type": "object",
  "properties": {
    "listing_id": { "type": "string", "format": "uuid" },
    "garment_id": { "type": "string", "format": "uuid" },
    "platform": { "type": "string", "enum": ["ebay", "depop", "poshmark", "mercari", "vinted"] },
    "generated_fields": {
      "type": "object",
      "properties": {
        "title": { "type": "string", "maxLength": 80 },
        "description": { "type": "string" },
        "suggested_price": { "type": "number" },
        "currency": { "type": "string", "default": "AUD" },
        "item_specifics": {
          "type": "object",
          "additionalProperties": { "type": "string" }
        },
        "hashtags": {
          "type": "array",
          "items": { "type": "string" }
        }
      },
      "required": ["title", "description", "suggested_price", "currency"]
    }
  },
  "required": ["listing_id", "garment_id", "platform", "generated_fields"]
}
```

### 3.3 Inventory Synchronization Record (`InventorySync`)
The source-of-truth status tracking record stored in the primary database.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "InventorySync",
  "type": "object",
  "properties": {
    "sku": { "type": "string" },
    "garment_id": { "type": "string", "format": "uuid" },
    "original_stock": { "type": "integer", "minimum": 0 },
    "current_stock": { "type": "integer", "minimum": 0 },
    "active_offers": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "platform": { "type": "string", "enum": ["ebay", "depop"] },
          "external_item_id": { "type": "string" },
          "external_status": { "type": "string", "enum": ["active", "sold", "ended"] },
          "listed_price": { "type": "number" },
          "last_synced_at": { "type": "string", "format": "date-time" }
        },
        "required": ["platform", "external_item_id", "external_status", "listed_price", "last_synced_at"]
      }
    }
  },
  "required": ["sku", "garment_id", "original_stock", "current_stock", "active_offers"]
}
```

### 3.4 Offline Sync Queue Schema (`OfflineQueueItem`)
Used to store transactional updates in client-side storage when disconnected from the network.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "OfflineQueueItem",
  "type": "object",
  "properties": {
    "queue_id": { "type": "string", "format": "uuid" },
    "action": { "type": "string", "enum": ["create_listing", "update_price", "sold_notification"] },
    "payload": { "type": "object" },
    "created_at": { "type": "string", "format": "date-time" },
    "retry_count": { "type": "integer", "default": 0 }
  },
  "required": ["queue_id", "action", "payload", "created_at"]
}
```

---

## 4. Feedback-Loop Specification

To fulfill the data-bootstrap strategy, a specialized `feedback` table is initialized in the system database from Day 1. This captures user corrections and sales velocity to systematically improve listing copy generation and pricing models.

```
                  ┌──────────────────────────────┐
                  │   AI Initial Generation      │
                  │   - Title, Price, Copy       │
                  └──────────────┬───────────────┘
                                 │
                                 ▼ (Store Initial Values)
                  ┌──────────────────────────────┐
                  │     User Review & Edit       │
                  │   - Modifies generated fields│
                  └──────────────┬───────────────┘
                                 │
                                 ▼ (Store Edited Values)
                  ┌──────────────────────────────┐
                  │    Publish Live to eBay      │
                  └──────────────┬───────────────┘
                                 │
                                 ▼ (Wait for Sale)
                  ┌──────────────────────────────┐
                  │       Webhook Event          │
                  │   - Sell Price, Days to Sell │
                  └──────────────┬───────────────┘
                                 │
                                 ▼ (Log Data Package)
                  ┌──────────────────────────────┐
                  │  Feedback Database Entry     │
                  └──────────────────────────────┘
```

### 4.1 The Feedback Database Schema

Each entry in the `feedback` table consolidates a single item's lifecycle:

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `feedback_id` | UUID | Primary key. |
| `garment_id` | UUID | Foreign key link to the ingested item. |
| `original_ai_payload` | JSONB | Contains the initial title, description, and suggested price generated by the model. |
| `user_edited_payload` | JSONB | Contains the final title, description, and price actually published by the user. |
| `delta_metrics` | JSONB | Pre-calculated difference indexes (Levensthein distance for title/description, absolute/percentage differences for price). |
| `sale_outcome` | JSONB | Nullable. Records `sold_price`, `sale_timestamp`, `days_to_sell`, and `buyer_region` once the sale is confirmed. |
| `fine_tune_status` | VARCHAR | Track whether this record has been exported into a training dataset: `["pending", "exported", "ignored"]`. |

### 4.2 Fine-Tuning Execution Pipeline
1.  **Deltas Monitoring**: When the user edits fields in Step 2/3 of the wizard, a diff listener calculates editing coefficients. High delta scores signify sections where the AI copy fell short of human quality standards.
2.  **Performance Association**: As sales complete, the system correlates structural variables (e.g., specific keywords added by the user vs. those generated by the AI) with days-to-sell velocity.
3.  **Fine-Tuning Loop**: At the end of each monthly cycle, records marked `"pending"` with a successful sale are exported into JSONL formats (Prompt: Ingested Garment Metadata + Photo Signals $\rightarrow$ Target: User-Edited Listing Text) to re-train the underlying Vision-Language models.

---

## 5. Risk, Safeguards, & Mitigations

| Risk Area | Risk Description | Severity | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **API Rate Limits** | eBay restricts inventory creation and media upload requests. Pushing batch listings frequently could throttle server requests. | **Medium** | Implement a local client-side rate-limiter combined with a back-off queue broker on the backend API. Cache media URLs locally where applicable. |
| **Image Resolution & Focus** | Poor lighting at local markets or focus issues on collar sizing tags results in failed OCR reading and incorrect brand/size assignment. | **High** | Embed client-side exposure check during photo capture. Block the user from advancing to Step 2 if the collar tag focus metric falls below 75%. Provide manual entry override. |
| **Offline Sync Conflicts** | When running the offline queue at weekend markets, a user might sell an item offline and forget to update the status, leading to double-sales when sync reconnects. | **High** | Introduce immediate date-time stamping on local queue items. Upon network reconnection, execute an inventory verification pass before deploying offers live. |
| **Authentication Expiry** | eBay OAuth user access tokens expire every 2 hours, disrupting background synchronization and inventory polling. | **Medium** | Store secure OAuth Refresh Tokens in the database. Implement a background Cron worker that refreshes tokens every 90 minutes. |
| **User Edit Bias** | Power sellers might overwrite high-quality generated SEO listings with personal shorthand formatting, polluting the training data set. | **Low** | Establish editing thresholds. Exclude records from the training pipeline if the user's edits simplify the listing length by more than 40% or remove structured specs tables. |

---

## 6. Verification Plan

We will verify that the architecture coordinates correctly through both programmatic checks and user-flow validation:

### 6.1 Automated Verification Tests
We will execute testing suites to validate boundary conditions:
- **Rate-Limit Testing**: Verify that the sync scheduler retries calls when Mock APIs return `HTTP 429 Too Many Requests`.
- **Data Validation Tests**: Run JSON Schema validation against mocked inputs (`IngestedGarment` validation checks).
- **Offline Sync Queue Tests**: Verify that items logged in local storage survive simulated browser page reloads and process correctly once network online triggers fire.

### 6.2 Manual Staged Verification
1.  **Ingestion Verification**: Upload a fuzzy photo and check if the computer-vision log console detects the defect.
2.  **Form Extraction Verification**: Verify that reading the size tag of the biker jacket auto-populates "L" in the details form.
3.  **OAuth Connection test**: Authenticate using sandbox credentials, checking that the OAuth Broker stores session status correctly in local storage.
4.  **eBay Live Preview**: Validate that formatting, tables, and photos render correctly when creating the high-fidelity mock listing preview.

---

## 7. Next Actions (Sprint 1 Roadmap)

1.  **Database Initialisation**: Create the `ecosystem_leads` table, `feedback` table, and `inventory_sync` tables.
2.  **API Handler Integration**: Refactor the mock eBay publishing terminal in [app.js](file:///c:/Users/krist/.gemini/antigravity/scratch/Diamondcore/ONLINEECOSYSTEMLAUNCH/app.js) to accept real Developer App client keys.
3.  **Offline Queue Build**: Implement browser network listeners (`window.addEventListener('online', ...)`) to flush the local queue.
4.  **UX Polish**: Ensure the wizard fits mobile browser dimensions cleanly with smooth HSL gemstone gradients.
