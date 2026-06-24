# Refractal Loop Registry: Best Practices & Pitfalls
*Version: 1.0 | Location: 00_ADMIN_AND_METHOD*

This registry functions as the shared memory layer of the **Diamond Soul Constellation** ecosystem. It documents technical, design, and somatic lessons (best practices) alongside errors, lockouts, and bugs (pitfalls) encountered during system development. By logging these learnings, future AI agents and collaborators can optimize their operations in a continuous improvement feedback loop.

---

## 1. Technical & Development Pitfalls

### A. PowerShell Variable Expansion Colon Errors
* **Problem**: In double-quoted PowerShell strings, putting a colon immediately after a variable name (e.g., `"Error copying $path: $_"`) triggers drive-reference parser errors because PowerShell interprets `$path:` as a drive path (like `C:`).
* **Mitigation**: Always wrap the variable in curly braces or escape the colon:
  ```powershell
  "Error copying ${path}: $_"
  ```

### B. Word (.docx) ZIP Header Corruptions
* **Problem**: Copying or reading `.docx` files during active sync client operations can cause zip header extraction failures, preventing zip archives from opening.
* **Mitigation**: Access files using try-catch blocks and employ structured ZipArchive extraction methods. When extracting text, use dedicated Python parsers (e.g., `python-docx` via the `uv` package manager) rather than raw binary streams.

### C. Zero-Byte Cloud-Locked Placeholders
* **Problem**: OneDrive or Google Drive sync clients can lock files locally, copying them to disk as zero-byte placeholders (such as `A-022` `diamond_soul_constellation_bible.pdf`).
* **Mitigation**: Run automated size-checking scripts (`Get-Item $file | Select-Object Length`) before trying to parse data. If a file is zero-byte, check OneDrive imports for plain-text recovered backups (e.g., `... (1).txt`).

### D. Markdown Link Backtick Breakage
* **Problem**: Surrounding markdown file links with backticks (e.g., `[`file.txt`](file://...)`) breaks link rendering in many agentic UI parsers, making the files unclickable.
* **Mitigation**: Write links in standard clean formatting:
  * *Correct*: `[file.txt](file:///absolute/path/to/file.txt)`
  * *Incorrect*: `[`file.txt`](file:///absolute/path/to/file.txt)`

---

## 2. Design & Architectural Best Practices

### A. Plain-Language Public Positioning
* **Best Practice**: Avoid leading public-facing projects with dense esoteric, metaphysical, or systems-theory vocabulary. Keep the entrance warm and civic-focused (e.g., **Living Layers Fremantle**), and introduce CareX, OmniStrux, and Gnostic ciphers only as opt-in pathways for active co-creators.

### B. Consent-First Data Ingestion
* **Best Practice**: System forms (like the Living Layers signup) must be strictly non-extractive. Every form must include:
  * Plain-text statements on what data is stored and why.
  * A clear checkbox confirming data is not sold or analyzed for advertising.
  * An immediate, single-click deletion/opt-out path.

### C. Client-Side Sovereign Storage First
* **Best Practice**: For sensitive personal logs (such as the Tarot pulls and daily alignment records of the Oracle Path), store data entirely on the user's local machine (`localStorage` or local cookies). This prevents centralized security leaks and preserves immediate data sovereignty.

---

## 3. Somatic & Energetic Best Practices

### A. Pre-Work Somatic Grounding
* **Best Practice**: Before writing code, drafting legal documents, or conducting community meetings, utilize the **Somatic Shield Protocol** (`A-034`) to ground the nervous system and clear mental clutter:
  * Complete 3 cycles of **4-4-6 breathing** (Inhale 4s, Hold 4s, Exhale 6s).
  * Tremor hands, micro-stretch the spine, and orient eyes to the horizon.
  * Step into direct sunlight for 60–120 seconds.
  * Establish the 3-meter octahedral visualization to filter out negative cognitive projections.
