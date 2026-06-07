# DIAMOND SOUL CONSTELLATION — UX COMPONENT LIBRARY SPECIFICATION (UXSpec v1.0)
*Status: Core Specification | Version: 1.0 | Date: 3 June 2026*

This specification defines the visual standards, interactive components, responsive behaviors, accessibility constraints, and micro-animations for the **Diamond Soul Constellation** frontend ecosystem. Any implementation (HTML/CSS, React, Vue, or Web Components) must adhere strictly to the visual tokens and component layouts defined here.

---

## SECTION 1 — DESIGN SYSTEM TOKENS

### 1.1 Palette & Color Variables (HSL System)
The visual architecture uses a high-contrast dark theme with glowing gemstone accents to map semantic pathways and active campaign weeks. All components must reference these core variables:

```css
:root {
    /* Base Neutral Palette */
    --bg-main: hsl(220, 25%, 5%);        /* Deep Slate black: #07090c */
    --bg-card: hsla(224, 20%, 9%, 0.65);  /* Muted Slate Card: #11131c with 65% opacity */
    --bg-nav: hsla(220, 25%, 5%, 0.85);   /* Navbar backing: #07090c with 85% opacity */
    
    /* Typography Palette */
    --text-primary: hsl(220, 15%, 96%);   /* Soft White: #f3f4f6 */
    --text-secondary: hsl(220, 10%, 75%); /* Muted Silver: #9ca3af */
    --text-muted: hsl(220, 10%, 45%);     /* Slate grey: #6b7280 */
    --border-color: hsla(0, 0%, 100%, 0.08); /* 8% White overlay border */

    /* Gemstone Accents */
    --gem-diamond: hsl(180, 75%, 55%);        /* Cyan Diamond (Core Hub / Ingestion) */
    --gem-diamond-glow: hsla(180, 75%, 55%, 0.15);
    
    --gem-amethyst: hsl(280, 60%, 65%);       /* Violet Amethyst (Somatic / Living Layers) */
    --gem-amethyst-glow: hsla(280, 60%, 65%, 0.15);
    
    --gem-emerald: hsl(150, 65%, 55%);        /* Green Emerald (Fundraiser / Kindness) */
    --gem-emerald-glow: hsla(150, 65%, 55%, 0.15);
    
    --gem-gold: hsl(45, 80%, 55%);            /* Amber Gold (Creative / Plus One) */
    --gem-gold-glow: hsla(45, 80%, 55%, 0.15);
    
    --gem-ruby: hsl(0, 75%, 55%);             /* Crimson Ruby (Security / Narrative) */
    --gem-ruby-glow: hsla(0, 75%, 55%, 0.15);

    /* Animation and Transitions */
    --transition-smooth: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}
```

### 1.2 Typography Rules
*   **Header Typeface**: `Playfair Display` (serif). Used exclusively for page headers (`<h1>`), sections (`<h2>`), and pull-quotes. Establishes a classic, dignified, narrative tone.
*   **Body Typeface**: `Outfit` or `Montserrat` (sans-serif). Used for cards, form labels, paragraph texts, and navigation. Establishes a highly legible, clean, professional tone.

```css
h1, h2, h3, h4 {
    font-family: 'Playfair Display', Georgia, serif;
    font-weight: 400;
    color: var(--text-primary);
}

body, button, input, select, textarea {
    font-family: 'Outfit', sans-serif;
    color: var(--text-primary);
    -webkit-font-smoothing: antialiased;
}
```

---

## SECTION 2 — GLOBAL SHELL & LAYOUT COMPONENTS

### 2.1 The Application Wrapper (App Shell)
A flexible flexbox or grid layout spanning `100vh` to anchor navigation at the top and a structured footer at the bottom.

```
+------------------------------------------+
|  Logo [◆ OmniStruX]         Nav Options  |  <- Sticky Header (backdrop-filter)
+------------------------------------------+
|                                          |
|                                          |
|            Main Content View             |  <- Fade-in View transition container
|                                          |
|                                          |
+------------------------------------------+
|  Copyright    ■ OmniStruX | Spec Sign    |  <- Minimal Footer
+------------------------------------------+
```

### 2.2 Navigation Menu Node
*   **Aesthetic**: Transparent background, soft border outlines on hover, highlighting the active route with a bottom accent bar using `--gem-diamond`.
*   **Transition**: `transition: var(--transition-smooth);` matching background overlays and text colors.

```css
nav a {
    color: var(--text-secondary);
    font-size: 0.9rem;
    padding: 0.4rem 0.6rem;
    border-radius: 6px;
    border: 1px solid transparent;
}
nav a:hover, nav a.active {
    color: var(--text-primary);
    background-color: rgba(255, 255, 255, 0.04);
}
nav a.active {
    border-bottom: 1.5px solid var(--gem-diamond);
    border-radius: 6px 6px 0 0;
}
```

---

## SECTION 3 — INTERACTIVE NARRATIVE COMPONENTS

### 3.1 Chaptered Story Manuscript Card
*   **Layout**: Container padding `2rem` (desktop) / `1.25rem` (mobile), max-width `720px` to optimize text line-length.
*   **Chapter Headings**: Text in `Playfair Display` with a `--gem-diamond` underline decoration.
*   **Copy Block**: Font size `1.125rem`, line-height `1.75` for high legibility during extended reading.

```css
.story-section-title {
    font-family: var(--font-heading);
    font-size: 1.45rem;
    color: var(--gem-diamond);
    margin: 2rem 0 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    padding-bottom: 0.25rem;
}
```

### 3.2 Pull-Quote Block (Transition Bridge)
*   **Aesthetic**: Linear gradient background blending deep purple with dark card backings. Placed at transition points where the story pivots from raw survival to design structure.
*   **Border Accents**: Left border utilizing `--gem-amethyst` to represent somatic transformation.

```css
.story-bridge-panel {
    background: linear-gradient(135deg, rgba(40, 30, 50, 0.4), rgba(15, 10, 20, 0.6));
    border: 1px solid rgba(280, 60, 65, 0.2);
    border-left: 3.5px solid var(--gem-amethyst);
    border-radius: 8px;
    padding: 1.5rem;
    margin: 2.5rem 0;
    text-align: center;
    font-style: italic;
    font-family: var(--font-heading);
    font-size: 1.2rem;
    color: #e9d5ff;
}
```

### 3.3 Premium Spoken Audio Player
*   **Layout**: Horizontal flex row for desktop, collapsing to vertical stack for mobile.
*   **Play/Pause Control**: A circular node with a transition pulse glow utilizing `--gem-diamond`.
*   **Timeline Progress Slider**: Flat, custom track with a variable width filler bar indicating playing status.

```css
.audio-player-card {
    background: linear-gradient(135deg, rgba(18, 20, 28, 0.8), rgba(9, 10, 15, 0.9));
    border-left: 3px solid var(--gem-diamond);
    border-radius: 12px;
    padding: 2rem;
}
.play-btn {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background-color: var(--gem-diamond);
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: var(--transition-smooth);
}
.play-btn:hover {
    transform: scale(1.05);
    box-shadow: 0 0 12px var(--gem-diamond-glow);
}
```

---

## SECTION 4 — ETHICAL CAPTURE & CONVERSION PATHS

### 4.1 Consent-First Inputs & Dynamic Warnings
*   **Visual Warning Box**: Semi-transparent yellow card backdrop triggered when selecting highly sensitive paths (such as requesting direct housing or mental health support).
*   **Consent Checkbox Container**: Distinct container backing, forcing users to explicitly read and toggle consent before form submission buttons unlock.

```css
.consent-container {
    background-color: rgba(255, 255, 255, 0.01);
    border: 1px solid var(--border-color);
    padding: 1rem;
    border-radius: 8px;
    margin: 1.5rem 0;
}
.checkbox-label input {
    accent-color: var(--gem-diamond);
}
```

### 4.2 Local Action CTA Buttons
To keep fundraising and support distinct, buttons use clear semantic coloring tags:
*   **Community of Kindness / Direct Donation**: GoFundMe brand green (`#00b964`).
*   **Ecosystem Routing / Portals**: Diamond Cyan (`var(--gem-diamond)`).
*   **Optional Secondary Pathways**: Muted glassmorphic grey (`rgba(255, 255, 255, 0.05)`).

---

## SECTION 5 — SOMATIC GROUNDING COMPONENTS

### 5.1 Somatic Calming Circle (The Cadence Orb)
*   **Breathing Animation Cadence (4-4-6)**:
    1.  *Inhale (4 seconds)*: Circle expands smoothly using `scale(1.8)` with transition easing.
    2.  *Hold (4 seconds)*: Circle holds shape; animation halts.
    3.  *Exhale (6 seconds)*: Circle collapses back to `scale(1.0)` with transition easing.
*   **Accent Color**: Uses gradient values from `--gem-diamond` shifting to `--gem-amethyst` (representing the somatic transition).

```css
#breath-circle {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--gem-diamond), var(--gem-amethyst));
    box-shadow: 0 0 20px var(--gem-diamond-glow);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
}
```

---

## SECTION 6 — MICRO-ANIMATIONS & INTERACTIVE STATES

### 6.1 Starry Drifting Particles (Canvas Layer)
*   **Behavior**: High-performance `<canvas>` rendering small white/cyan dust nodes drifting at slow velocities (`speedX/Y: -0.075 to 0.075`).
*   **Implementation Constraints**: Canvas must remain locked at `z-index: -1`, ignoring user click events (`pointer-events: none;`) to protect main page scrolls.

### 6.2 Glowing State Transitions
Inputs, buttons, and cards must use soft radial halos rather than sharp color changes to maintain the premium, immersive feel:

```css
.form-control:focus {
    border-color: var(--gem-diamond);
    box-shadow: 0 0 12px var(--gem-diamond-glow);
}

@keyframes pulseGlow {
    0% { text-shadow: 0 0 5px var(--gem-diamond-glow); opacity: 0.8; }
    100% { text-shadow: 0 0 15px var(--gem-diamond); opacity: 1; }
}
```
