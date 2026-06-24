# Plus One AI Fashion Resale Assistant

Welcome to the **Plus One / Haus da Villa Wilde** AI Fashion Resale Assistant. This single-page application is integrated into the OmniStrux online ecosystem rollout. It is designed to guide users on capturing high-quality photographs of clothing and accessories, analyze their framing and lighting in real-time, generate sales-optimized copy for the top 5 online marketplaces, and publish listings autonomously to eBay via OAuth integrations.

## Repository Structure

The rollout code is structured inside this directory as follows:
```
ONLINEECOSYSTEMLAUNCH/
 ├── index.html           # Story, Fundraiser, Living Layers, and Plus One Wizard views
 ├── styles.css           # Core gemstone design system, terminal, and wizard styles
 ├── app.js               # Routing, grounding tools, camera controls, listing generator, & OAuth
 └── README.md            # Project documentation (This file)
```

## Implemented Features

1. **Guided Photography Assistant (Step 1)**
   - HTML5 video element interface that requests device camera permissions (with automatic fallback to local file uploading).
   - Dynamic grid alignment reticles overlaid on the capture box to guide users.
   - **Testing Mode:** A button to instantly load a 4-photo mock dataset (Front, Back, Tag, Detail) of a vintage leather biker jacket.
   - **Agent-Vision Log Console:** A simulated CLI displaying real-time feedback (silhouette centration checks, OCR tag readings, and exposure/focus diagnostics).

2. **Descriptive Signals & Form Ingestion (Step 2)**
   - Forms to refine item keywords, brand names, sizing, fits, colors, conditions, and defects/notes.

3. **Multi-Marketplace Listing Optimization (Step 3)**
   - Tailors titles, descriptions, pricing matrices, and hashtag arrays across **5 major platforms** side-by-side:
     - **eBay:** Keyword-stacked 80-character title, structured specifications grid, and custom HTML-designed template. Suggests prices and details calculated eBay seller fees.
     - **Poshmark:** Brand-centric title, USPS priority shipping notices, bundle call-to-actions, and price buffering (recovering Poshmark's 20% cut).
     - **Depop:** Trend-focused descriptions with emojis, pit-to-pit sizing, and aesthetic streetwear tags (e.g. `#vintage #y2k #grunge`).
     - **Mercari:** Friendly, bulleted description, and bundle recommendations.
     - **Vinted:** Direct sizing info, dimension measurements, and sustainable packaging notes.
   - Quick "Copy" buttons to easily copy listing blocks to your clipboard.

4. **OAuth Store Sync & Agentic Publishing (Step 4)**
   - Secure store connector using the eBay OAuth authorization modal. Stores mock/production user tokens locally in the browser.
   - **Active Listing Daemon:** A console log terminal simulating automated API deployments: uploading assets to eBay Picture Services (EPS), resolving categories, creating inventory item SKUs, and publishing listing offers.
   - **High-Fidelity Listing Preview:** Triggers a popup displaying the finished eBay listing mockup complete with the photos, pricing, specs table, and description.

## Getting Started

### Running the Application

To preview and interact with the application on your local machine:
1. Open the [index.html](file:///c:/Users/krist/.gemini/antigravity/scratch/Diamondcore/ONLINEECOSYSTEMLAUNCH/index.html) file directly in your default web browser.
2. Select **Plus One** from the navigation menu or click **Launch Listing Assistant** on the **Portfolio** tab dashboard.
3. Click the **Load Sample Clothes (Testing Mode)** button to run through the photography, listing generation, OAuth login, and eBay posting flow.

## Maintainer
Haus da Villa Wilde  
Walyalup / Fremantle, Western Australia
