# Multi-Chat Ingestion and Sync Script
$brainRoot = "C:\Users\krist\.gemini\antigravity\brain"
$workspaceRoot = "C:\Users\krist\.gemini\antigravity\scratch\Diamondcore"
$logOutputDir = Join-Path $workspaceRoot "09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs"

# Ensure log directory exists
if (-not (Test-Path $logOutputDir)) {
    New-Item -Path $logOutputDir -ItemType Directory | Out-Null
    Write-Host "Created log output directory: $logOutputDir"
}

# Scan all conversation folders
$sessionFolders = Get-ChildItem -Path $brainRoot -Directory

Write-Host "Scanning brain directories..."
Write-Host "Found $($sessionFolders.Count) session folders."

foreach ($folder in $sessionFolders) {
    $sessionID = $folder.Name
    $transcriptPath = Join-Path $folder.FullName ".system_generated\logs\transcript.jsonl"
    
    if (-not (Test-Path $transcriptPath)) {
        Write-Host "No transcript log found for session: $sessionID" -ForegroundColor Gray
        continue
    }
    
    Write-Host "Ingesting transcript for session: $sessionID..." -ForegroundColor Cyan
    
    # Read the JSONL file and parse it in one go (incredibly fast)
    $lines = Get-Content -Path $transcriptPath -Encoding UTF8 | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($lines.Count -eq 0) { continue }
    
    $jsonArrayText = "[" + ($lines -join ",") + "]"
    try {
        $steps = $jsonArrayText | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-Host "   Failed to parse JSON for session $sessionID" -ForegroundColor Red
        continue
    }
    
    $mdPath = Join-Path $logOutputDir "chat_$sessionID.md"
    
    # Start Markdown document
    $mdHeader = @"
# Chat Session Transcript: $sessionID
*Ingested from local system log: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")*
*Conversation ID: $sessionID*

---

"@
    $mdHeader | Set-Content -Path $mdPath -Encoding UTF8
    
    $turnCount = 0
    $mdBody = New-Object System.Text.StringBuilder
    
    foreach ($step in $steps) {
        $type = $step.type
        $source = $step.source
        $content = $step.content
        
        # We focus on user inputs and model responses
        if ($type -eq "USER_INPUT" -or $source -eq "USER_EXPLICIT") {
            $turnCount++
            $userSection = @"
### 👤 USER (Step $turnCount)
$content

---
"@
            $mdBody.AppendLine($userSection) | Out-Null
        }
        elseif ($type -eq "PLANNER_RESPONSE" -or $source -eq "MODEL") {
            # Format and clean text content
            if ($content) {
                $aiSection = @"
### 🤖 ANTIGRAVITY (AI)
$content

---
"@
                $mdBody.AppendLine($aiSection) | Out-Null
            }
        }
    }
    
    $mdBody.ToString() | Add-Content -Path $mdPath -Encoding UTF8
    Write-Host "   Generated chat_$sessionID.md with $turnCount conversation turns." -ForegroundColor Green
}

Write-Host "All active and historical transcripts ingested successfully." -ForegroundColor Green
