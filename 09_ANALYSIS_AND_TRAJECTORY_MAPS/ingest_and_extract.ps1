# Ingestion and Text Extraction Script
$copyMap = @(
    @{
        Src = "C:\Users\krist\OneDrive\AAATHELONGITUDINALHUMANFRACTALPROJECT\Daniel Cornwell Public Record and Project Constellation Assessment.docx"
        Dest = "C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\02_OFFICIAL_AND_PROFESSIONAL_RECORDS\Daniel_Cornwell_Public_Record_Constellation_Assessment.docx"
    },
    @{
        Src = "C:\Users\krist\OneDrive\AAATHELONGITUDINALHUMANFRACTALPROJECT\Daniel Cornwell Public Record and Project Constellation Assessment.pdf"
        Dest = "C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\02_OFFICIAL_AND_PROFESSIONAL_RECORDS\Daniel_Cornwell_Public_Record_Constellation_Assessment.pdf"
    },
    @{
        Src = "C:\Users\krist\OneDrive\AAATHELONGITUDINALHUMANFRACTALPROJECT\Community_of_Kindness_Project_Plan_Draft Mark-up.pdf"
        Dest = "C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\07_COMMUNITY_AND_PUBLIC_WORK\Community_of_Kindness_Project_Plan_Draft_Markup.pdf"
    },
    @{
        Src = "C:\Users\krist\OneDrive\AAATHELONGITUDINALHUMANFRACTALPROJECT\Villa Dalmacia Grant Mark-up.pdf"
        Dest = "C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\07_COMMUNITY_AND_PUBLIC_WORK\Villa_Dalmacia_Grant_Markup.pdf"
    },
    @{
        Src = "C:\Users\krist\OneDrive\AAATHELONGITUDINALHUMANFRACTALPROJECT\Developer Continuity Charter.pdf"
        Dest = "C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\00_ADMIN_AND_METHOD\Developer_Continuity_Charter.pdf"
    }
)

function Extract-DocxText($docxPath, $txtPath) {
    try {
        $tempDir = Join-Path $env:TEMP ([Guid]::NewGuid().Guid)
        New-Item -Path $tempDir -ItemType Directory | Out-Null
        
        # Unzip docx using ZipFile which doesn't restrict extensions to .zip
        [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
        [System.IO.Compression.ZipFile]::ExtractToDirectory($docxPath, $tempDir)
        
        $xmlPath = Join-Path $tempDir "word\document.xml"
        if (Test-Path $xmlPath) {
            [xml]$xml = Get-Content $xmlPath -Raw -Encoding UTF8
            
            # Use namespace manager to query paragraphs
            $ns = New-Object Xml.XmlNamespaceManager $xml.NameTable
            $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
            
            $paragraphs = $xml.SelectNodes("//w:p", $ns)
            $text = ""
            foreach ($p in $paragraphs) {
                $tNodes = $p.SelectNodes(".//w:t", $ns)
                $pText = ""
                foreach ($t in $tNodes) {
                    $pText += $t.InnerText
                }
                if ($pText) {
                    $text += $pText + "`r`n"
                }
            }
            
            $text | Set-Content -Path $txtPath -Encoding UTF8
            Write-Host "   [DOCX Extract] Saved text to: $txtPath"
        }
        
        # Clean up temp
        Remove-Item -Path $tempDir -Recurse -Force | Out-Null
    } catch {
        Write-Host "   [DOCX Extract] Error parsing $($docxPath): $($_.Exception.Message)"
    }
}

Write-Host "=== Starting Ingestion and Text Extraction ==="

foreach ($item in $copyMap) {
    $src = $item.Src
    $dest = $item.Dest
    
    if (-not (Test-Path $src)) {
        Write-Host "Source not found or unreadable: $src"
        continue
    }
    
    $parentDir = Split-Path $dest -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -Path $parentDir -ItemType Directory | Out-Null
    }
    
    Write-Host "Copying: $(Split-Path $src -Leaf) -> $(Split-Path $dest -Leaf)"
    Copy-Item -Path $src -Destination $dest -Force
    
    $ext = [System.IO.Path]::GetExtension($dest).ToLower()
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($dest)
    $txtDest = Join-Path $parentDir ($baseName + ".txt")
    
    if ($ext -eq ".docx") {
        Extract-DocxText $dest $txtDest
    } elseif ($ext -eq ".pdf") {
        Write-Host "   [PDF Copy] PDF copied, text extraction skipped to prevent COM hangs."
    }
}

Write-Host "=== Ingestion Process Complete ==="
