import os
import shutil
import zipfile
import xml.etree.ElementTree as ET

copy_map = [
    # A-001
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Descent to rewilderness.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\04_PERSONAL_NARRATIVE_AND_STATE_DOCUMENTS\Descent to rewilderness.docx"),
    # A-004
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\# Ionic Mirror Recovery Prompt for Drug and Alcohol Goal Setting.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\06_SYSTEMS_AND_PROJECT_ARCHITECTURE\Ionic_Mirror_Recovery_Prompt_Goal_Setting.docx"),
    # A-007
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\TimeShiftAR_DSC_Architecture_Stack_Roadmap.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\06_SYSTEMS_AND_PROJECT_ARCHITECTURE\TimeShiftAR_DSC_Architecture_Stack_Roadmap.docx"),
    # A-008
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Level Up Flyer - A6 Updated.pdf",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\05_CREATIVE_TRANSLATION\Level_Up_Flyer_Princess_Dragonblood.pdf"),
    # A-009
    (r"C:\Users\krist\OneDrive\Imports\frodois007@gmail.com - Google Drive\CORNWELLDaniel.pdf",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\02_OFFICIAL_AND_PROFESSIONAL_RECORDS\CORNWELLDaniel.pdf"),
    (r"C:\Users\krist\OneDrive\AAATHELONGITUDINALHUMANFRACTALPROJECT\Daniel Cornwell Public Record and Project Constellation Assessment.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\02_OFFICIAL_AND_PROFESSIONAL_RECORDS\Daniel_Cornwell_Public_Record_Constellation_Assessment.docx"),
    # A-010
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Comprehensive Profile Analysis Request.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\01_IDENTITY_LINEAGE\Comprehensive_Profile_Analysis_Request.docx"),
    # External AIos Chats
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Automating Projects with ChatGPT and Ion.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs\external_aios\Automating_Projects_with_ChatGPT_and_Ion.docx"),
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Chat Review and Analysis Framework.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs\external_aios\Chat_Review_and_Analysis_Framework.docx"),
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Designing Aionic Fifth-Wall Engine's Awakening.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs\external_aios\Designing_Aionic_Fifth_Wall_Engine_Awakening.docx"),
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\### Consent Model for Chat History.docx",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs\external_aios\Consent_Model_for_Chat_History.docx"),
    (r"C:\Users\krist\OneDrive\Imports\kristalcornwell@gmail.com - Google Drive\Current Working Documents\Dumpdata\Omnisyruct overview 190824 chatgpt 1st pass.txt",
     r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs\external_aios\Omnisyruct_overview_190824_chatgpt_1st_pass.txt")
]

def extract_docx_text(docx_path, txt_path):
    try:
        with zipfile.ZipFile(docx_path) as z:
            xml_content = z.read('word/document.xml')
            root = ET.fromstring(xml_content)
            ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
            paragraphs = []
            for p in root.findall('.//w:p', ns):
                texts = [t.text for t in p.findall('.//w:t', ns) if t.text]
                if texts:
                    paragraphs.append("".join(texts))
            text = "\n".join(paragraphs)
            with open(txt_path, "w", encoding="utf-8") as f:
                f.write(text)
            print(f"   [DOCX Extract] Saved text to: {txt_path}")
    except Exception as e:
        print(f"   [DOCX Extract] Error parsing {docx_path}: {e}")

def extract_pdf_text(pdf_path, txt_path):
    try:
        from pypdf import PdfReader
        reader = PdfReader(pdf_path)
        text = ""
        for idx, page in enumerate(reader.pages):
            text += f"--- Page {idx+1} ---\n"
            text += page.extract_text() or ""
            text += "\n\n"
        with open(txt_path, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"   [PDF Extract] Saved text to: {txt_path}")
    except Exception as e:
        print(f"   [PDF Extract] Error parsing {pdf_path}: {e}")

print("=== Starting Ingestion & Extraction ===")

# Ensure directories exist
os.makedirs(r"C:\Users\krist\.gemini\antigravity\scratch\Diamondcore\09_ANALYSIS_AND_TRAJECTORY_MAPS\chat_logs\external_aios", exist_ok=True)

for src, dest in copy_map:
    if not os.path.exists(src):
        print(f"Source not found: {src}")
        continue
        
    print(f"Copying: {os.path.basename(src)}")
    shutil.copy(src, dest)
    
    # Process text extraction based on file extension
    base, ext = os.path.splitext(dest)
    txt_dest = base + ".txt"
    
    if ext.lower() == ".docx":
        extract_docx_text(dest, txt_dest)
    elif ext.lower() == ".pdf":
        extract_pdf_text(dest, txt_dest)
    elif ext.lower() == ".txt":
        print(f"   [Text Copy] File already plain text: {dest}")

print("=== Ingestion Process Complete ===")
